
protocol ScopeRegistry {
    func register<C, I>(_ : C.Type, _ : @escaping (DependencyResolutionScope) -> I)
}

public class ContainerBuilder : DependencyRegistry {
    
    var registrations: [ScopedRegistration] = []
    
    public init() { }
    
    private func registerTransient<C, I>(_ : C.Type, _ fn: @escaping (any DependencyResolutionScope) -> I) {
        registrations.append { r in
            r.register(C.self) { s in
                fn(s)
            }
        }
    }
    
    public func transient<I>(_ fn: @escaping () -> I) {
        registerTransient(I.self) { _ in fn() }
    }
    
    public func transient<I>(_ fn: @escaping (any DependencyResolutionScope) -> I) {
        registerTransient(I.self, fn)
    }
    
    public func transient<C>(_: C.Type, _ fn: @escaping () -> C) {
        registerTransient(C.self) { _ in fn() }
    }
    
    public func transient<C>(_: C.Type, _ fn: @escaping (any DependencyResolutionScope) -> C) {
        registerTransient(C.self, fn)
    }
    
    public func transient<I>(_: I.Type) where I : Resolvable {
        registerTransient(I.self, I.init)
    }
    
    public func transient<C, I>(_: C.Type, _ : Assigned<C, I>) where I : Resolvable {
        registerTransient(C.self, autoResolveFactory(I.self))
    }
    
    private func registerSingleton<C, I>(_ : C.Type, _ fn: @escaping (DependencyResolutionScope) -> I) {
        var instance: C?
        registrations.append { r in
            r.register(C.self) { s in
                instance = instance ?? fn(s) as! C
                return instance
            }
        }
    }
    
    public func singleton<I>(_ fn: @escaping () -> I) {
        registerSingleton(I.self) { _ in fn() }
    }
    
    public func singleton<I>(_ fn: @escaping (any DependencyResolutionScope) -> I) {
        registerSingleton(I.self, fn)
    }
    
    public func singleton<C>(_: C.Type, _ fn: @escaping () -> C) {
        registerSingleton(C.self) { _ in fn() }
    }
    
    public func singleton<C>(_: C.Type, _ fn: @escaping (any DependencyResolutionScope) -> C) {
        registerSingleton(C.self, fn)
    }
    
    public func singleton<I>(_: I.Type) where I : Resolvable {
        registerSingleton(I.self, I.init)
    }
    
    public func singleton<C, I>(_: C.Type, _ : Assigned<C, I>) {
        registerSingleton(C.self) { $0.resolve() as I }
    }
    
    public func singleton<C, I>(_: C.Type, _ : Assigned<C, I>) where I : Resolvable {
        registerSingleton(C.self, autoResolveFactory(I.self))
    }
    
    private func registerScoped<C, I>(_ : C.Type, _ fn: @escaping (DependencyResolutionScope) -> I) {
        registrations.append { r in
            var instance: C?
            r.register(C.self) { s in
                instance = instance ?? fn(s) as! C
                return instance
            }
        }
    }
    
    public func scoped<I>(_ fn: @escaping () -> I) {
        registerScoped(I.self) { _ in fn() }
    }
    
    public func scoped<I>(_ fn: @escaping (any DependencyResolutionScope) -> I) {
        registerScoped(I.self, fn)
    }
    
    public func scoped<C>(_: C.Type, _ fn: @escaping () -> C) {
        registerScoped(C.self) { _ in fn() }
    }
    
    public func scoped<C>(_: C.Type, _ fn: @escaping (any DependencyResolutionScope) -> C) {
        registerScoped(C.self, fn)
    }
    
    public func scoped<I>(_: I.Type) where I : Resolvable {
        registerScoped(I.self, I.init)
    }
    
    public func scoped<C, I>(_: C.Type, _ : Assigned<C, I>) where I : Resolvable {
        registerScoped(C.self, autoResolveFactory(I.self))
    }
    
    private func autoResolveFactory<I: Resolvable>(_ : I.Type) -> ((DependencyResolutionScope) -> I) {
        { s in
            s.tryResolve() ?? I.init(scope: s)
        }
    }
    
    public func build() -> Container {
        .init(builder: self)
    }
}

typealias ScopedRegistration = (ScopeRegistry) -> Void
