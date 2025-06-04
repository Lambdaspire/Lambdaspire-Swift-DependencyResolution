
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
    
    func testScopedOverrides() {
        
        let scoped = container.scope { r in
            r.singleton(TestServiceProtocol.self) {
                TestService(dependency: Dependency(label: UUID().uuidString))
            }
        }
        
        let containerService: TestServiceProtocol = container.resolve()
        
        let scopedService: TestServiceProtocol = scoped.resolve()
        
        XCTAssertNotEqual(containerService.dependency.label, scopedService.dependency.label)
        
        let scopedService2: TestServiceProtocol = scoped.resolve()
        
        XCTAssertEqual(scopedService.dependency.label, scopedService2.dependency.label)
        
        XCTAssertEqual(
            scoped.scope().resolve(TestServiceProtocol.self).dependency.label,
            scoped.scope().scope().resolve(TestServiceProtocol.self).dependency.label)
        
        let anotherScoped = container.scope { r in
            r.scoped(TestServiceProtocol.self) {
                TestService(dependency: Dependency(label: UUID().uuidString))
            }
        }
        
        let anotherScopedService: TestServiceProtocol = anotherScoped.resolve()
        
        XCTAssertNotEqual(containerService.dependency.label, scopedService.dependency.label)
        XCTAssertNotEqual(scopedService.dependency.label, anotherScopedService.dependency.label)
        
        XCTAssertNotEqual(
            anotherScoped.scope().resolve(TestServiceProtocol.self).dependency.label,
            anotherScoped.scope().scope().resolve(TestServiceProtocol.self).dependency.label)
        
        let scopedOnAScoped = anotherScoped.scope { r in
            r.singleton(TestServiceProtocol.self) {
                TestService(dependency: Dependency(label: "So many scopes."))
            }
        }
        
        let scopedOnAScopedService: TestServiceProtocol = scopedOnAScoped.resolve()
        
        XCTAssertEqual(scopedOnAScopedService.dependency.label, "So many scopes.")
        
        XCTAssertEqual(count, 1)
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
