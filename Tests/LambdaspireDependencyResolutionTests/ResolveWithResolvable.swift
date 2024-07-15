
import LambdaspireLogging
import LambdaspireAbstractions
import XCTest
@testable import LambdaspireDependencyResolution

final class ResolveWithResolvableTests: XCTestCase {
    
    override class func setUp() {
        Log.setLogger(PrintLogger())
    }
    
    func test_ResolveResolvableAsIsDoesNotRequireRegistry() throws {
        
        let a: ResolvableTestDependencyA = .init()
        let b: ResolvableTestDependencyB = .init()
        let c: ResolvableTestDependencyC = .init()
        
        let serviceLocator: ServiceLocator = .init()
        
        serviceLocator.register(a)
        serviceLocator.register(b)
        serviceLocator.register(c)
        
        let root: ResolvableTestRoot = serviceLocator.resolve()
        
        XCTAssertEqual(root.a.id, a.id)
        XCTAssertEqual(root.b.id, b.id)
        XCTAssertEqual(root.c.id, c.id)
    }
    
    func test_ResolveResolvableAsAbstraction() throws {
        
        let a: ResolvableTestDependencyA = .init()
        let b: ResolvableTestDependencyB = .init()
        let c: ResolvableTestDependencyC = .init()
        
        let serviceLocator: ServiceLocator = .init()
        
        serviceLocator.register(a)
        serviceLocator.register(b)
        serviceLocator.register(c)
        
        serviceLocator.register(ResolvableTestRootProtocol.self, ResolvableTestRoot.self)
        
        let root: ResolvableTestRootProtocol = serviceLocator.resolve()
        
        XCTAssertEqual(root.a.id, a.id)
        XCTAssertEqual(root.b.id, b.id)
        XCTAssertEqual(root.c.id, c.id)
    }
}

protocol ResolvableTestRootProtocol {
    var a: ResolvableTestDependencyA { get }
    var b: ResolvableTestDependencyB { get }
    var c: ResolvableTestDependencyC { get }
}

@Resolvable
class ResolvableTestRoot : ResolvableTestRootProtocol {
    
    let a: ResolvableTestDependencyA
    let b: ResolvableTestDependencyB
    let c: ResolvableTestDependencyC
    
    init(a: ResolvableTestDependencyA, b: ResolvableTestDependencyB, c: ResolvableTestDependencyC) {
        self.a = a
        self.b = b
        self.c = c
    }
}

class ResolvableTestDependency {
    let id: UUID
    
    init(id: UUID = .init()) {
        self.id = id
    }
}

class ResolvableTestDependencyA : ResolvableTestDependency {}

class ResolvableTestDependencyB : ResolvableTestDependency {}

class ResolvableTestDependencyC : ResolvableTestDependency {}
