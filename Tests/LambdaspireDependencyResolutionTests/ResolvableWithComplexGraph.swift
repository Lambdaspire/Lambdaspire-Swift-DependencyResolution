
import LambdaspireLogging
import LambdaspireAbstractions
import XCTest
@testable import LambdaspireDependencyResolution

final class ResolvableWithComplexGraph: XCTestCase {
    
    override class func setUp() {
        Log.setLogger(PrintLogger())
    }
    
    func test_ResolveResolvableWithComplexGraph() throws {
        
        let serviceLocator: ServiceLocator = .init()
        
        serviceLocator.register(ComplexTestRootProtocol.self) { $0(ComplexTestRoot.self) }
        serviceLocator.register(ComplexTestLevel1Protocol.self) { $0(ComplexTestLevel1.self) }
        serviceLocator.register(ComplexTestLevel2Protocol.self) { $0(ComplexTestLevel2.self) }
        serviceLocator.register(ComplexTestLevel3Protocol.self) { $0(ComplexTestLevel3.self) }
        
        let rootViaRegisteredAbstraction: ComplexTestRootProtocol = serviceLocator.resolve()
        let rootViaAutoResolution: ComplexTestRoot = serviceLocator.resolve()
        
        XCTAssertEqual(rootViaRegisteredAbstraction.level1.level2.level3.theEnd, "Sweet")
        XCTAssertEqual(rootViaAutoResolution.level1.level2.level3.theEnd, "Sweet")
    }
}

fileprivate protocol ComplexTestRootProtocol {
    var level1: ComplexTestLevel1Protocol { get }
}

fileprivate protocol ComplexTestLevel1Protocol {
    var level2: ComplexTestLevel2Protocol { get }
}

fileprivate protocol ComplexTestLevel2Protocol {
    var level3: ComplexTestLevel3Protocol { get }
}

fileprivate protocol ComplexTestLevel3Protocol {
    var theEnd: String { get }
}

@Resolvable
fileprivate class ComplexTestRoot : ComplexTestRootProtocol {
    
    let level1: ComplexTestLevel1Protocol
    
    init(level1: ComplexTestLevel1Protocol) {
        self.level1 = level1
    }
}

@Resolvable
fileprivate class ComplexTestLevel1 : ComplexTestLevel1Protocol {
    
    let level2: ComplexTestLevel2Protocol
    
    init(level2: ComplexTestLevel2Protocol) {
        self.level2 = level2
    }
}

@Resolvable
fileprivate class ComplexTestLevel2 : ComplexTestLevel2Protocol {
    
    let level3: ComplexTestLevel3Protocol
    
    init(level3: ComplexTestLevel3Protocol) {
        self.level3 = level3
    }
}

@Resolvable
fileprivate class ComplexTestLevel3 : ComplexTestLevel3Protocol {
    
    let theEnd: String = "Sweet"
}
