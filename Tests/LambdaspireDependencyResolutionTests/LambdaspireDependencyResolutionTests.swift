import XCTest
@testable import LambdaspireDependencyResolution

final class LambdaspireDependencyResolutionTests: XCTestCase {
    
    func testServiceLocatorBasics() throws {
        let serviceLocator: ServiceLocator = .init()
        
        serviceLocator.register(TestServiceProtocol.self, TestServiceClass.init)
        
        let singleton: TestServiceClass = .init()
        serviceLocator.register(singleton)
        
        var count: Int = 0
        serviceLocator.register(TestOtherProtocol.self) { TestOtherClass(count: count.increment()) }
        
        let resolvedSingletonByInference: TestServiceClass = serviceLocator.resolve()
        let resolvedSingletonByExplicitType = serviceLocator.resolve(TestServiceClass.self)
        
        let newInstanceResolvedByInference: TestServiceProtocol = serviceLocator.resolve()
        let newInstanceResolvedByExplitiType = serviceLocator.resolve(TestServiceProtocol.self)
        
        let unregisteredAsOptional: UnregisteredProtocol? = serviceLocator.resolve()
        
        XCTAssertIdentical(singleton, resolvedSingletonByInference)
        XCTAssertIdentical(singleton, resolvedSingletonByExplicitType)
        
        XCTAssertEqual(singleton.id, resolvedSingletonByInference.id)
        XCTAssertEqual(singleton.id, resolvedSingletonByExplicitType.id)
        
        XCTAssertNotEqual(singleton.id, newInstanceResolvedByInference.id)
        XCTAssertNotEqual(singleton.id, newInstanceResolvedByExplitiType.id)
        
        XCTAssertNotEqual(newInstanceResolvedByInference.id, newInstanceResolvedByExplitiType.id)
        
        (1...5).forEach { n in
            XCTAssertEqual(serviceLocator.resolve(TestOtherProtocol.self).count, n)
        }
        
        XCTAssertNil(unregisteredAsOptional)
    }
}

protocol TestServiceProtocol {
    var id: UUID { get }
}

class TestServiceClass : TestServiceProtocol {
    var id: UUID = .init()
}

protocol TestOtherProtocol {
    var count: Int { get }
}

class TestOtherClass : TestOtherProtocol {
    let count: Int
    
    init(count: Int) {
        self.count = count
    }
}

protocol UnregisteredProtocol { }

extension Int {
    mutating func increment() -> Self {
        self += 1
        return self
    }
}
