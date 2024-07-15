
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
        T.init(resolver: self)
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

public extension DependencyRegistry where Self : DependencyResolver {
    
    // TODO: This is an absolute cheat and does not enforce TI implements TC.
    func register<TC, TI: Resolvable>(_ contract: TC.Type, _ implementation: TI.Type) {
        register(TC.self) {
            autoResolve() as TI as! TC
        }
    }
}
