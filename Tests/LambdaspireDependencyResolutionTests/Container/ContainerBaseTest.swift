
import LambdaspireDependencyResolution
import XCTest

class ContainerBaseTest : XCTestCase {
    
    var container: Container!
    
    override func setUp() {
        let builder: ContainerBuilder = .init()
        setUpBuilder(builder)
        container = builder.build()
    }
    
    func setUpBuilder(_ b: ContainerBuilder) {
        // Override.
    }
}
