
import LambdaspireAbstractions
import LambdaspireDependencyResolution
import XCTest

final class ContainerScopedContractResolvingSingletonImplementationReturnsSame : ContainerBaseTest {
    
    override func setUpBuilder(_ b: ContainerBuilder) {
        
        b.singleton { TestService(dependency: Dependency(label: UUID().uuidString)) }
        
        b.scoped(TestServiceProtocol.self, assigned(TestService.self))
    }
    
    func test() {
        XCTAssertEqual(
            container.resolve(TestServiceProtocol.self).dependency.label,
            container.scope().resolve(TestServiceProtocol.self).dependency.label)
    }
}

final class ContainerSingletonContractResolvingScopedImplementationReturnsSame : ContainerBaseTest {
    
    override func setUpBuilder(_ b: ContainerBuilder) {
        
        b.scoped { TestService(dependency: Dependency(label: UUID().uuidString)) }
        
        b.singleton(TestServiceProtocol.self, assigned(TestService.self))
    }
    
    func test() {
        XCTAssertEqual(
            container.resolve(TestServiceProtocol.self).dependency.label,
            container.scope().resolve(TestServiceProtocol.self).dependency.label)
    }
}

final class ContainerTransientContractResolvingScopedImplementationReturnsScoped : ContainerBaseTest {
    
    override func setUpBuilder(_ b: ContainerBuilder) {
        
        b.scoped { TestService(dependency: Dependency(label: UUID().uuidString)) }
        
        b.transient(TestServiceProtocol.self, assigned(TestService.self))
    }
    
    func test() {
        
        let sub = container.scope()
        
        XCTAssertNotEqual(
            container.resolve(TestServiceProtocol.self).dependency.label,
            sub.resolve(TestServiceProtocol.self).dependency.label)
        
        XCTAssertEqual(
            sub.resolve(TestServiceProtocol.self).dependency.label,
            sub.resolve(TestServiceProtocol.self).dependency.label)
    }
}

