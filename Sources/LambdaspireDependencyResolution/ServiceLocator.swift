
import LambdaspireAbstractions

public class ServiceLocator : DependencyRegistry, DependencyResolver {
    
    var registrations: [String : () -> Any] = [:]
    
    public init() { }
    
    public func register<T>(_ singleton: T) {
        register(T.self) { singleton }
    }
    
    public func register<T>(_ : T.Type, _ singleton: T) {
        register(T.self) { singleton }
    }
    
    public func register<T>(_ factory: @escaping () -> T) {
        register(T.self, factory)
    }
    
    public func register<T>(_ : T.Type, _ factory: @escaping () -> T) {
        registrations[key(T.self)] = factory
    }
    
    public func resolve<T>() -> T {
        resolve(T.self)
    }
    
    public func resolve<T>(_ : T.Type) -> T {
        guard let resolved = tryResolve(T.self) else {
            Log.error(
                "Failed to resolve dependency of type {Type} from registrations {Registrations}.",
                (
                    type: T.self,
                    registrations: registrations.keys.map { $0 }
                ))
            // Not ideal, but don't want to require the pollution of `try!` everywhere.
            fatalError("Failed to resolve.")
        }
        
        return resolved
    }
    
    func tryResolve<T>(_ : T.Type) -> T? {
        registrations[key(T.self)]?() as? T
    }
    
    private func key<T>(_ : T.Type) -> String {
        .init(describing: T.self)
    }

}
