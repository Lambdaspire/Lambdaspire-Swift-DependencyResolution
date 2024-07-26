
public protocol DependencyRegistry {
    
    func transient<I>(_ : @escaping () -> I)
    func transient<I>(_ : @escaping (DependencyResolutionScope) -> I)
    func transient<C>(_ : C.Type, _ : @escaping () -> C)
    func transient<C>(_ : C.Type, _ : @escaping (DependencyResolutionScope) -> C)
    func transient<I: Resolvable>(_ : I.Type)
    func transient<C, I: Resolvable>(_ : C.Type, _ : Assigned<C, I>)
    
    func singleton<I>(_ : @escaping () -> I)
    func singleton<I>(_ : @escaping (DependencyResolutionScope) -> I)
    func singleton<C>(_ : C.Type, _ : @escaping () -> C)
    func singleton<C>(_ : C.Type, _ : @escaping (DependencyResolutionScope) -> C)
    func singleton<I: Resolvable>(_ : I.Type)
    func singleton<C, I: Resolvable>(_ : C.Type, _ : Assigned<C, I>)
    
    func scoped<I>(_ : @escaping () -> I)
    func scoped<I>(_ : @escaping (DependencyResolutionScope) -> I)
    func scoped<C>(_ : C.Type, _ : @escaping () -> C)
    func scoped<C>(_ : C.Type, _ : @escaping (DependencyResolutionScope) -> C)
    func scoped<I: Resolvable>(_ : I.Type)
    func scoped<C, I: Resolvable>(_ : C.Type, _ : Assigned<C, I>)
}

public typealias Assigned<C, I> = (I.Type) -> C

public func assigned<C>(_ : C.Type) -> Assigned<C, C> {
    { _ in
        fatalError("Do not invoke. Compile-time hack only.")
    }
}
