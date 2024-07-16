import XCTest
import LambdaspireAbstractions
@testable import LambdaspireDependencyResolution

final class LambdaspireDependencyResolutionTests: XCTestCase {
    
    func test_ServiceLocatorBasics() throws {
        
        let serviceLocator: ServiceLocator = .init()
        
        serviceLocator.register(TestServiceProtocol.self, TestServiceClass.init)
        
        let singleton: TestServiceClass = .init()
        serviceLocator.register(singleton)
        
        var count: Int = 0
        serviceLocator.register(TestOtherProtocol.self) { TestOtherClass(count: count.increment()) }
        
        let subTypeSingleton: SubType = .init()
        serviceLocator.register(subTypeSingleton)
        serviceLocator.register(BaseType.self) { $0(SubType.self) }
        
        let resolvedSingletonByInference: TestServiceClass = serviceLocator.resolve()
        let resolvedSingletonByExplicitType = serviceLocator.resolve(TestServiceClass.self)
        
        let newInstanceResolvedByInference: TestServiceProtocol = serviceLocator.resolve()
        let newInstanceResolvedByExplitiType = serviceLocator.resolve(TestServiceProtocol.self)
        
        let subTypeAsBaseType: BaseType = serviceLocator.resolve()
        
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
        
        XCTAssertIdentical(subTypeAsBaseType as! SubType, subTypeSingleton)
        
        XCTAssertNil(unregisteredAsOptional)
    }
}

fileprivate protocol TestServiceProtocol {
    var id: UUID { get }
}

fileprivate class TestServiceClass : TestServiceProtocol {
    var id: UUID = .init()
}

fileprivate protocol TestOtherProtocol {
    var count: Int { get }
}

fileprivate class TestOtherClass : TestOtherProtocol {
    let count: Int
    
    init(count: Int) {
        self.count = count
    }
}

fileprivate protocol BaseType { }

fileprivate class SubType : BaseType {
    let id: UUID
    
    init(id: UUID = .init()) {
        self.id = id
    }
}

fileprivate protocol UnregisteredProtocol { }

fileprivate extension Int {
    mutating func increment() -> Self {
        self += 1
        return self
    }
}
