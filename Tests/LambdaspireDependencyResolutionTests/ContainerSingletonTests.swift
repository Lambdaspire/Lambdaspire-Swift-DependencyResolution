
import LambdaspireDependencyResolution
import XCTest

final class ContainerSingletonTests: XCTestCase {
    
    func test_Singleton_AlwaysTheSameResultAndOnlyResolvesOnce() {
        
        let b: ContainerBuilder = .init()
        
        var count: Int = 0
        b.singleton(TestServiceProtocol.self) {
            count += 1
            return TestService(dependency: Dependency(label: UUID().uuidString))
        }
        
        let container = b.build()
        
        (0...10).forEach { _ in
            _ = container.resolve(TestServiceProtocol.self)
            _ = container.scope().resolve(TestServiceProtocol.self)
            _ = container.scope().scope().resolve(TestServiceProtocol.self)
        }
        
        XCTAssertEqual(
            container.resolve(TestServiceProtocol.self).dependency.label,
            container.scope().scope().resolve(TestServiceProtocol.self).dependency.label)
        
        XCTAssertEqual(count, 1)
    }
    
    func test_Singleton_UsingContractWithFixedImplementation() {
        
        let b: ContainerBuilder = .init()
            
        b.singleton(TestServiceProtocol.self) {
            TestService(dependency: Dependency(label: "TestServiceProtocolDependency"))
        }
            
        let container = b.build()
        
        XCTAssertEqual(
            container.resolve(TestServiceProtocol.self).dependency.label,
            "TestServiceProtocolDependency")
    }
    
    func test_Singleton_UsingContractWithFixedImplementationWithResolvedDependency() {
        
        let b: ContainerBuilder = .init()
            
        b.singleton(TestServiceProtocol.self) { s in
            TestService(dependency: s.resolve())
        }
        
        b.singleton(DependencyProtocol.self) {
            Dependency(label: "TestServiceProtocolDependency")
        }
            
        let container = b.build()
        
        XCTAssertEqual(
            container.resolve(TestServiceProtocol.self).dependency.label,
            "TestServiceProtocolDependency")
    }
    
    func test_Singleton_UsingContractWithResolvedImplementation() {
        
        let b: ContainerBuilder = .init()
            
        b.singleton(TestServiceProtocol.self, assigned(TestService.self))
        
        b.singleton(TestService.self) { s in
            TestService(dependency: s.resolve())
        }
        
        b.singleton(DependencyProtocol.self) {
            Dependency(label: "TestServiceProtocolDependency")
        }
            
        let container = b.build()
        
        XCTAssertEqual(
            container.resolve(TestServiceProtocol.self).dependency.label,
            "TestServiceProtocolDependency")
    }
    
    func test_Singleton_ConciseRegistrationWithResolvable() {
        
        let b: ContainerBuilder = .init()
            
        b.singleton(TestServiceProtocol.self, assigned(ResolvableTestService.self))
        
        b.singleton(DependencyProtocol.self, assigned(Dependency.self))
        
        b.singleton { Dependency(label: "TestServiceProtocolDependency") }
            
        let container = b.build()
        
        XCTAssertEqual(
            container.resolve(TestServiceProtocol.self).dependency.label,
            "TestServiceProtocolDependency")
    }
    
    func test_Singleton_OverrideResolvable() {
        
        let b: ContainerBuilder = .init()
        
        b.singleton(TestServiceProtocol.self, assigned(ResolvableTestService.self))
        
        b.singleton(ResolvableTestService.self) { s in
            .init(dependency: Dependency(label: "Override"))
        }
        
        b.singleton(DependencyProtocol.self, assigned(Dependency.self))
        
        b.singleton { Dependency(label: "TestServiceProtocolDependency") }
            
        let container = b.build()
        
        XCTAssertEqual(
            container.resolve(TestServiceProtocol.self).dependency.label,
            "Override")
    }
    
    func test_Singelton_ResolvableAsSelf() {
        
        let b: ContainerBuilder = .init()
        
        b.singleton(ResolvableTestService.self)
        
        b.singleton {
            Dependency(label: "VeryUnusual") as DependencyProtocol
        }
        
        let container = b.build()
        
        XCTAssertEqual(
            container.resolve(ResolvableTestService.self).dependency.label,
            "VeryUnusual")
    }
}

fileprivate protocol TestServiceProtocol {
    var dependency: DependencyProtocol { get }
}

fileprivate class TestService : TestServiceProtocol {
    let dependency: DependencyProtocol
    
    init(dependency: DependencyProtocol) {
        self.dependency = dependency
    }
}

@Resolvable
fileprivate class ResolvableTestService : TestServiceProtocol {
    let dependency: DependencyProtocol
    
    init(dependency: DependencyProtocol) {
        self.dependency = dependency
    }
}

fileprivate protocol DependencyProtocol {
    var label: String { get }
}

fileprivate class Dependency : DependencyProtocol {
    
    let label: String
    
    init(label: String) {
        self.label = label
    }
}

fileprivate class ComplexDependency {
    let dependnecyA: DependencyProtocol
    let dependencyB: DependencyProtocol
    
    init(dependnecyA: DependencyProtocol, dependencyB: DependencyProtocol) {
        self.dependnecyA = dependnecyA
        self.dependencyB = dependencyB
    }
}
