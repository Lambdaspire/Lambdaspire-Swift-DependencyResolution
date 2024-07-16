

import LambdaspireAbstractions

public protocol Resolvable {
    init(resolver: DependencyResolver)
}

// Lamentably the most concise way I could come up for strongly-typed LSP,
// as Swift seemingly does not have the ability to enforce co-dependent generic type constraints.
// i.e. `register<TContract, TImplementation>(...) where TImplementation : TContract`

// TODO: It would be better if Abstractions allowed for a registration method via closure that accepted a DependencyResolver argument.
// Then the extension needn't specify the constraint on Self.

public extension DependencyRegistry where Self : DependencyResolver {
    
    func register<T, R>(_ : T.Type, _ factory: @escaping ((R.Type) -> R) -> T) {
        register {
            factory(resolve)
        }
    }
    
    func register<T, R: Resolvable>(_ : T.Type, _ factory: @escaping ((R.Type) -> R) -> T) {
        register {
            factory { _ in
                autoResolve()
            }
        }
    }
    
    func register<R: Resolvable>(asSelf r: R.Type) {
        register {
            autoResolve() as R
        }
    }
}

fileprivate extension DependencyResolver {
    func autoResolve<T: Resolvable>() -> T {
        T.init(resolver: self)
    }
}
