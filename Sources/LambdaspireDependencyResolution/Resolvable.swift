
import LambdaspireAbstractions

public protocol Resolvable {
    init(resolver: DependencyResolver)
}

public extension DependencyResolver {
    
    func resolve<T: Resolvable>() -> T {
        autoResolve()
    }
    
    func resolve<T: Resolvable>(_ t: T.Type) -> T {
        autoResolve()
    }
    
    fileprivate func autoResolve<T: Resolvable>() -> T {
        resolve() as T? ?? T.init(resolver: self)
    }
}

public extension ServiceLocator {
    
    func resolve<T: Resolvable>() -> T {
        autoResolve()
    }
    
    func resolve<T: Resolvable>(_ t: T.Type) -> T {
        autoResolve()
    }
}

// Lamentably the most concise way I could come up for strongly-typed LSP,
// as Swift seemingly does not have the ability to enforce co-dependent generic type constraints.
// i.e. `register<TContract, TImplementation>(...) where TImplementation : TContract`
public extension DependencyRegistry where Self : DependencyResolver {
    
    // TODO: This one might be better for the Abstractions package.
    func register<T, R>(_ t: T.Type, _ factory: @escaping ((R.Type) -> R) -> T) {
        register { factory(resolve) }
    }
    
    func register<T, R: Resolvable>(_ t: T.Type, _ factory: @escaping ((R.Type) -> R) -> T) {
        register {
            factory { _ in
                autoResolve() as R
            }
        }
    }
}
