
import LambdaspireAbstractions
import LambdaspireDependencyResolution
import XCTest

final class ContainerSingletonAlwaysTheSameResultAndOnlyResolvesOnce : ContainerBaseTest {
    
    var count: Int = 0
    
    override func setUpBuilder(_ b: ContainerBuilder) {
        
        b.singleton(TestServiceProtocol.self) {
            self.count += 1
            return TestService(dependency: Dependency(label: UUID().uuidString))
        }
    }
    
    func test() {
        
        // Resolve a few times in various scopes, including root.
        (0...10).forEach { _ in
            _ = container.resolve(TestServiceProtocol.self)
            _ = container.scope().resolve(TestServiceProtocol.self)
            _ = container.scope().scope().resolve(TestServiceProtocol.self)
        }
        
        // Resolving at different levels should yield the same.
        XCTAssertEqual(
            container.resolve(TestServiceProtocol.self).dependency.label,
            container.scope().scope().resolve(TestServiceProtocol.self).dependency.label)
        
        XCTAssertEqual(count, 1)
    }
}

final class ContainerSingletonUsingContractWithFixedImplementation : ContainerBaseTest {
    
    override func setUpBuilder(_ b: ContainerBuilder) {
        b.singleton(TestServiceProtocol.self) {
            TestService(dependency: Dependency(label: "TestServiceProtocolDependency"))
        }
    }
    
    func test() {
        XCTAssertEqual(
            container.resolve(TestServiceProtocol.self).dependency.label,
            "TestServiceProtocolDependency")
    }
}

final class ContainerSingletonUsingContractWithFixedImplementationWithResolvedDependency : ContainerBaseTest {
    
    override func setUpBuilder(_ b: ContainerBuilder) {
        
        b.singleton(TestServiceProtocol.self) { s in
            TestService(dependency: s.resolve())
        }
        
        b.singleton(DependencyProtocol.self) {
            Dependency(label: "TestServiceProtocolDependency")
        }
    }
    
    func test_Singleton_UsingContractWithFixedImplementationWithResolvedDependency() {
        XCTAssertEqual(
            container.resolve(TestServiceProtocol.self).dependency.label,
            "TestServiceProtocolDependency")
    }
}

final class ContainerSingletonUsingContractWithResolvedImplementation : ContainerBaseTest {
    
    override func setUpBuilder(_ b: ContainerBuilder) {
        
        b.singleton(TestServiceProtocol.self, assigned(TestService.self))
        
        b.singleton(TestService.self) { s in
            TestService(dependency: s.resolve())
        }
        
        b.singleton(DependencyProtocol.self) {
            Dependency(label: "TestServiceProtocolDependency")
        }
    }
    
    func test() {
        XCTAssertEqual(
            container.resolve(TestServiceProtocol.self).dependency.label,
            "TestServiceProtocolDependency")
    }
}
 
final class ContainerSingletonConciseRegistrationWithResolvable : ContainerBaseTest {
    
    override func setUpBuilder(_ b: ContainerBuilder) {
        
        b.singleton(TestServiceProtocol.self, assigned(ResolvableTestService.self))
        
        b.singleton(DependencyProtocol.self, assigned(Dependency.self))
        
        b.singleton { Dependency(label: "TestServiceProtocolDependency") }
    }
    
    func test() {
        XCTAssertEqual(
            container.resolve(TestServiceProtocol.self).dependency.label,
            "TestServiceProtocolDependency")
    }
}

final class ContainerSingletonOverrideResolvable : ContainerBaseTest {
    
    override func setUpBuilder(_ b: ContainerBuilder) {
        
        b.singleton(TestServiceProtocol.self, assigned(ResolvableTestService.self))
        
        b.singleton(ResolvableTestService.self) { s in
            .init(dependency: Dependency(label: "Override"))
        }
        
        b.singleton(DependencyProtocol.self, assigned(Dependency.self))
        
        b.singleton { Dependency(label: "TestServiceProtocolDependency") }
    }
    
    func test() {
        XCTAssertEqual(
            container.resolve(TestServiceProtocol.self).dependency.label,
            "Override")
    }
}
 
final class ContainerSingletonResolvableAsSelf : ContainerBaseTest {
    
    override func setUpBuilder(_ b: ContainerBuilder) {
        
        b.singleton(ResolvableTestService.self)
        
        b.singleton {
            Dependency(label: "VeryUnusual") as DependencyProtocol
        }
    }
    
    func test() {
        XCTAssertEqual(
            container.resolve(ResolvableTestService.self).dependency.label,
            "VeryUnusual")
    }
}
