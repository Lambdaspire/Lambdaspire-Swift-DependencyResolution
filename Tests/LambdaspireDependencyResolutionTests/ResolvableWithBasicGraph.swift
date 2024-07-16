
import LambdaspireLogging
import LambdaspireAbstractions
import XCTest
@testable import LambdaspireDependencyResolution

final class ResolvableWithSimpleGraph: XCTestCase {
    
    func test_ResolveResolvableAsSelf() throws {
        
        let a: ResolvableTestDependencyA = .init()
        let b: ResolvableTestDependencyB = .init()
        let c: ResolvableTestDependencyC = .init()
        
        let serviceLocator: ServiceLocator = .init()
        
        serviceLocator.register(a)
        serviceLocator.register(b)
        serviceLocator.register(c)
        
        serviceLocator.register(asSelf: ResolvableTestRoot.self)
        
        let root: ResolvableTestRoot = serviceLocator.resolve()
        
        XCTAssertEqual(root.a.id, a.id)
        XCTAssertEqual(root.b.id, b.id)
        XCTAssertEqual(root.c.id, c.id)
    }
    
    func test_ResolveResolvableViaRegisteredAbstraction() throws {
        
        let a: ResolvableTestDependencyA = .init()
        let b: ResolvableTestDependencyB = .init()
        let c: ResolvableTestDependencyC = .init()
        
        let serviceLocator: ServiceLocator = .init()
        
        serviceLocator.register(a)
        serviceLocator.register(b)
        serviceLocator.register(c)
        
        serviceLocator.register(ResolvableTestRootProtocol.self) { $0(ResolvableTestRoot.self) }
        
        let root: ResolvableTestRootProtocol = serviceLocator.resolve()
        
        XCTAssertEqual(root.a.id, a.id)
        XCTAssertEqual(root.b.id, b.id)
        XCTAssertEqual(root.c.id, c.id)
    }
}

fileprivate protocol ResolvableTestRootProtocol {
    var a: ResolvableTestDependencyA { get }
    var b: ResolvableTestDependencyB { get }
    var c: ResolvableTestDependencyC { get }
}


@Resolvable
fileprivate class ResolvableTestRoot : ResolvableTestRootProtocol {
    
    let a: ResolvableTestDependencyA
    let b: ResolvableTestDependencyB
    let c: ResolvableTestDependencyC
    
    init(a: ResolvableTestDependencyA, b: ResolvableTestDependencyB, c: ResolvableTestDependencyC) {
        self.a = a
        self.b = b
        self.c = c
    }
}

fileprivate class ResolvableTestDependency {
    let id: UUID
    
    init(id: UUID = .init()) {
        self.id = id
    }
}

fileprivate class ResolvableTestDependencyA : ResolvableTestDependency {}

fileprivate class ResolvableTestDependencyB : ResolvableTestDependency {}

fileprivate class ResolvableTestDependencyC : ResolvableTestDependency {}
