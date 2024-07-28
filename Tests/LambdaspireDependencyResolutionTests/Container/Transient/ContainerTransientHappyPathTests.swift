
import LambdaspireDependencyResolution
import XCTest

final class ContainerTransientAlwaysANewResult : ContainerBaseTest {
    
    var count: Int = 0
    
    override func setUpBuilder(_ b: ContainerBuilder) {
        
        b.transient(TestServiceProtocol.self) {
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
        
        // Resolving at different levels should not yield the same.
        XCTAssertNotEqual(
            container.resolve(TestServiceProtocol.self).dependency.label,
            container.scope().scope().resolve(TestServiceProtocol.self).dependency.label)
        
        XCTAssertEqual(count, 35)
    }
}
