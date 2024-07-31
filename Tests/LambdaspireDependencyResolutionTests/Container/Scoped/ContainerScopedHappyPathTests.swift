
import LambdaspireDependencyResolution
import XCTest

final class ContainerScopedSameResultInSameScope : ContainerBaseTest {
    
    var count: Int = 0
    
    override func setUpBuilder(_ b: ContainerBuilder) {
        
        b.scoped(TestServiceProtocol.self) {
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
        
        // Resolving at root scope should yield the same.
        XCTAssertEqual(
            container.resolve(TestServiceProtocol.self).dependency.label,
            container.resolve(TestServiceProtocol.self).dependency.label)
        
        // Resolving at same non-root scope should yield the same.
        let sub = container.scope()
        XCTAssertEqual(
            sub.resolve(TestServiceProtocol.self).dependency.label,
            sub.resolve(TestServiceProtocol.self).dependency.label)
        
        // Resolving at different levels should not yield the same.
        XCTAssertNotEqual(
            container.resolve(TestServiceProtocol.self).dependency.label,
            sub.resolve(TestServiceProtocol.self).dependency.label)
        
        XCTAssertEqual(count, 24)
    }
}
