
public protocol DependencyResolver {
    func resolve<C>() -> C
    func tryResolve<C>() -> C?
}

public extension DependencyResolver {
    func resolve<C>(_ : C.Type) -> C { resolve() }
    func tryResolve<C>(_ : C.Type) -> C? { tryResolve() }
}
