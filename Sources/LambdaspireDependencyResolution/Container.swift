
import LambdaspireAbstractions
import Foundation

public class Container : ScopeRegistry, DependencyResolutionScope {
    
    public let id: String

    private var registrations: [RegistrationKey : Registration] = [:]
    
    private let builder: ContainerBuilder
    
    public init(id: String = "\(UUID())", builder: ContainerBuilder) {
        self.id = id
        self.builder = builder
        
        builder.registrations.forEach { $0(self) }
    }
    
    func register<C, I>(_: C.Type, _ fn: @escaping (any DependencyResolutionScope) -> I) {
        registrations[key(C.self)] = fn
        registrations[key(Optional<C>.self)] = fn
    }
    
    public func resolve<C>() -> C {
        guard let resolved = tryResolve(C.self) else {
            fatalError("Cannot resolve \(C.self)")
        }
        return resolved
    }
    
    public func resolve<C>(_: C.Type) -> C {
        resolve()
    }
    
    public func tryResolve<C>() -> C? {
        (registrations[key(C.self)] ?? { _ in nil })(self) as? C
    }
    
    public func tryResolve<C>(_: C.Type) -> C? {
        tryResolve()
    }
    
    public func scope() -> any DependencyResolutionScope {
        Container(id: "\(id)_\(UUID())", builder: builder)
    }
    
    public func scope(build: (DependencyRegistry) -> Void) -> any DependencyResolutionScope {
        
        let scopeBuilder: ContainerBuilder = .init()
        
        build(scopeBuilder)
        
        let combinedBuilder = builder.combine(scopeBuilder)
        
        return Container(id: "\(id)_\(UUID())", builder: combinedBuilder)
    }
}

typealias RegistrationKey = String

typealias Registration = (DependencyResolutionScope) -> Any

func key<T>(_ : T.Type) -> RegistrationKey { .init(describing: T.self) }

extension ContainerBuilder {
    func combine(_ other: ContainerBuilder) -> ContainerBuilder {
        .init(registrations: registrations + other.registrations)
    }
}
