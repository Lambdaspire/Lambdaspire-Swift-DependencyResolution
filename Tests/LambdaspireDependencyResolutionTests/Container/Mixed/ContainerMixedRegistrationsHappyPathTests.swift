
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
