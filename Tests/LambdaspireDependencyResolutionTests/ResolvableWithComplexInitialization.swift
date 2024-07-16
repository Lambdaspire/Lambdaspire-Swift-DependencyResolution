
import LambdaspireLogging
import LambdaspireAbstractions
import XCTest
@testable import LambdaspireDependencyResolution

final class ResolvableWithComplexInitialization: XCTestCase {
    
    override class func setUp() {
        Log.setLogger(PrintLogger())
    }
    
    func test_FindsAnAppropriateInitializer() throws {
        
        let serviceLocator: ServiceLocator = .init()
        
        let singleton: Dependency = .init(label: "Singleton")
        serviceLocator.register(singleton)
        
        serviceLocator.register(asSelf: Test.self)
        
        let resolved: Test = serviceLocator.resolve()
        
        XCTAssertIdentical(resolved.injectedLet, singleton)
        XCTAssertIdentical(resolved.injectedVar, singleton)
        XCTAssertIdentical(resolved.injectedPrivateVar, singleton)
        
        XCTAssertEqual(resolved.initializedInInitializerNotViaArguments.label, "Init")
        XCTAssertEqual(resolved.initializedInline.label, "Inline")
        XCTAssertEqual(resolved.lazyMember.label, "Lazy")
        XCTAssertEqual(resolved.inlineGet.label, "Inline get")
    }
}

@Resolvable
fileprivate class Test {
    
    let injectedLet: Dependency
    var injectedVar: Dependency
    fileprivate var injectedPrivateVar: Dependency
//    weak var injectedWeakVar: Dependency? // TODO: Optional<T> is not supported atm.
    
    var initializedInInitializerNotViaArguments: Dependency
    
    let initializedInline: Dependency = .init(label: "Inline")
    
    lazy var lazyMember: Dependency = { .init(label: "Lazy") }()
    
    var inlineGet: Dependency { .init(label: "Inline get") }
    
    init(injectedVar: Dependency, injectedLet: Dependency, injectedPrivateVar: Dependency) {
        self.injectedLet = injectedLet
        self.injectedVar = injectedVar
        self.injectedPrivateVar = injectedPrivateVar
        self.initializedInInitializerNotViaArguments = .init(label: "Init")
    }
}

@Resolvable
fileprivate class TestNoExplicitInit {
    let injected: Dependency
}

fileprivate class Dependency {
    let label: String
    
    init(label: String) {
        self.label = label
    }
}
