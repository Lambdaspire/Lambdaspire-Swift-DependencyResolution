
import LambdaspireDependencyResolution

protocol TestServiceProtocol {
    var dependency: DependencyProtocol { get }
}

class TestService : TestServiceProtocol {
    let dependency: DependencyProtocol
    
    init(dependency: DependencyProtocol) {
        self.dependency = dependency
    }
}

@Resolvable
class ResolvableTestService : TestServiceProtocol {
    let dependency: DependencyProtocol
    
    init(dependency: DependencyProtocol) {
        self.dependency = dependency
    }
}

protocol DependencyProtocol {
    var label: String { get }
}

class Dependency : DependencyProtocol {
    
    let label: String
    
    init(label: String) {
        self.label = label
    }
}
