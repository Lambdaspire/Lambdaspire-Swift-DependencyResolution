
import SwiftUI

protocol DependencyResolverr {
    func resolve<C>() -> C
    func resolve<C>(_ : C.Type) -> C
}

protocol Resolvablee {
    init(scope: DependencyResolutionScope)
}

protocol DependencyRegistryy {
    
    // Transient
    func transient<I>(_ : @escaping () -> I)
    func transient<I>(_ : @escaping (DependencyResolutionScope) -> I)
    func transient<C>(_ : C.Type, _ : @escaping () -> C)
    func transient<C>(_ : C.Type, _ : @escaping (DependencyResolutionScope) -> C)
    func transient<I: Resolvablee>(_ : I.Type)
    func transient<C, I: Resolvablee>(_ : C.Type, _ : Assigned<C, I>)
    
    // Singleton
    func singleton<I>(_ : @escaping () -> I)
    func singleton<I>(_ : @escaping (DependencyResolutionScope) -> I)
    func singleton<C>(_ : C.Type, _ : @escaping () -> C)
    func singleton<C>(_ : C.Type, _ : @escaping (DependencyResolutionScope) -> C)
    func singleton<I: Resolvablee>(_ : I.Type)
    func singleton<C, I: Resolvablee>(_ : C.Type, _ : Assigned<C, I>)
    
    // Scoped
    func scoped<I>(_ : @escaping () -> I)
    func scoped<I>(_ : @escaping (DependencyResolutionScope) -> I)
    func scoped<C>(_ : C.Type, _ : @escaping () -> C)
    func scoped<C>(_ : C.Type, _ : @escaping (DependencyResolutionScope) -> C)
    func scoped<I: Resolvablee>(_ : I.Type)
    func scoped<C, I: Resolvablee>(_ : C.Type, _ : Assigned<C, I>)
}

typealias Assigned<C, I> = (I.Type) -> C
func assigned<C>(_ : C.Type) -> Assigned<C, C> { { _ in
    fatalError("Do not use. Compile-time hack only.")
} }

typealias RegistrationKey = String
typealias Registration = (DependencyResolutionScope) -> Any
typealias ScopedRegistration = (SecretRegistryApi) -> Void

protocol SecretRegistryApi {
    func register<C, I>(_ : C.Type, _ : @escaping (DependencyResolutionScope) -> I)
}

func key<T>(_ : T.Type) -> String {
    .init(describing: T.self)
}

class ContainerBuilder {
    
    var registrations: [ScopedRegistration] = []
    
    private func registerTransient<C, I>(_ : C.Type, _ fn: @escaping (any DependencyResolutionScope) -> I) {
        registrations.append { r in
            r.register(C.self) { s in
                fn(s)
            }
        }
    }
    
    func transient<I>(_ fn: @escaping () -> I) {
        registerTransient(I.self) { _ in fn() }
    }
    
    func transient<I>(_ fn: @escaping (any DependencyResolutionScope) -> I) {
        registerTransient(I.self, fn)
    }
    
    func transient<C>(_: C.Type, _ fn: @escaping () -> C) {
        registerTransient(C.self) { _ in fn() }
    }
    
    func transient<C>(_: C.Type, _ fn: @escaping (any DependencyResolutionScope) -> C) {
        registerTransient(C.self, fn)
    }
    
    func transient<I>(_: I.Type) where I : Resolvablee {
        registerTransient(I.self, I.init)
    }
    
    func transient<C, I>(_: C.Type, _ : Assigned<C, I>) where I : Resolvablee {
        registerTransient(C.self, I.init)
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
    
    func singleton<I>(_ fn: @escaping () -> I) {
        registerSingleton(I.self) { _ in fn() }
    }
    
    func singleton<I>(_ fn: @escaping (any DependencyResolutionScope) -> I) {
        registerSingleton(I.self, fn)
    }
    
    func singleton<C>(_: C.Type, _ fn: @escaping () -> C) {
        registerSingleton(C.self) { _ in fn() }
    }
    
    func singleton<C>(_: C.Type, _ fn: @escaping (any DependencyResolutionScope) -> C) {
        registerSingleton(C.self, fn)
    }
    
    func singleton<I>(_: I.Type) where I : Resolvablee {
        registerSingleton(I.self, I.init)
    }
    
    func singleton<C, I>(_: C.Type, _ : Assigned<C, I>) where I : Resolvablee {
        registerSingleton(C.self, I.init)
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
    
    func scoped<I>(_ fn: @escaping () -> I) {
        registerScoped(I.self) { _ in fn() }
    }
    
    func scoped<I>(_ fn: @escaping (any DependencyResolutionScope) -> I) {
        registerScoped(I.self, fn)
    }
    
    func scoped<C>(_: C.Type, _ fn: @escaping () -> C) {
        registerScoped(C.self) { _ in fn() }
    }
    
    func scoped<C>(_: C.Type, _ fn: @escaping (any DependencyResolutionScope) -> C) {
        registerScoped(C.self, fn)
    }
    
    func scoped<I>(_: I.Type) where I : Resolvablee {
        registerScoped(I.self, I.init)
    }
    
    func scoped<C, I>(_: C.Type, _ : Assigned<C, I>) where I : Resolvablee {
        registerScoped(C.self, I.init)
    }
    
    func build() -> Container {
        .init(builder: self)
    }
}

class Container : SecretRegistryApi, DependencyResolutionScope {
    
    var registrations: [RegistrationKey : Registration] = [:]
    
    let id: UUID = .init()
    
    private let builder: ContainerBuilder
    
    init(builder: ContainerBuilder) {
        self.builder = builder
        
        builder.registrations.forEach { $0(self) }
    }
    
    func register<C, I>(_: C.Type, _ fn: @escaping (any DependencyResolutionScope) -> I) {
        registrations[key(C.self)] = fn
    }
    
    func resolve<C>() -> C {
        guard let resolved = (registrations[key(C.self)] ?? { _ in nil })(self) else {
            fatalError()
        }
        return resolved as! C
    }
    
    func resolve<C>(_: C.Type) -> C {
        resolve()
    }
    
    // TODO: Not certain.
    
    func scope<A>(_: A) -> any DependencyResolutionScope {
        Container(builder: builder)
    }
    
    func scope<A>(_: A, _ fn: (any DependencyResolutionScope) -> Void) {
        fn(Container(builder: builder))
    }
}

protocol Contract { }
class ImplementationBasic : Contract {
    init() { fatalError() }
    init(dependency: ImplementationBasic) { fatalError() }
}
class ImplementationComplex : Contract, Resolvablee {
    required convenience init(scope: any DependencyResolutionScope) { fatalError() }
    init() { fatalError() }
    init(dependency: ImplementationComplex) { fatalError() }
}

func log(_ x: String) {
    print(x)
}

class Other : Resolvablee {
    required init(scope: any DependencyResolutionScope) {
        fatalError()
    }
}

func theApiIWant() {
    
    let containerBuilder: ContainerBuilder = .init()
    
    // Transient
    
    // - Factories
    // -- As Self
    containerBuilder.transient(ImplementationBasic.init)
    containerBuilder.transient { scope in
        log("Resolved")
        return ImplementationBasic(dependency: scope.resolve())
    }
    // -- As Contract
    containerBuilder.transient(Contract.self, ImplementationBasic.init)
    containerBuilder.transient(Contract.self) { scope in
        log("Resolved")
        return ImplementationBasic(dependency: scope.resolve())
    }
    
    // - Type (requires cascade resolution)
    // -- As Self
    containerBuilder.transient(ImplementationComplex.self)
    // -- As Contract
    containerBuilder.transient(Contract.self, assigned(ImplementationComplex.self))
    
    // Singleton
    
    // - Factories
    // -- As Self
    containerBuilder.singleton(ImplementationBasic.init)
    containerBuilder.singleton { scope in
        log("Resolve")
        return ImplementationBasic(dependency: scope.resolve())
    }
    // -- As Contract
    containerBuilder.singleton(Contract.self, ImplementationBasic.init)
    containerBuilder.singleton(Contract.self) { scope in
        log("Resolve")
        return ImplementationBasic(dependency: scope.resolve())
    }
    
    // - Type (requires cascade resolution)
    // -- As Self
    containerBuilder.singleton(ImplementationComplex.self)
    // -- As Contract
    containerBuilder.singleton(Contract.self, assigned(ImplementationComplex.self))

    // Scoped
    
    // - Factories
    // -- As Self
    containerBuilder.scoped(ImplementationBasic.init)
    containerBuilder.scoped { scope in
        log("Resolve")
        return ImplementationBasic(dependency: scope.resolve())
    }
    // -- As Contract
    containerBuilder.scoped(Contract.self, ImplementationBasic.init)
    containerBuilder.scoped(Contract.self) { scope in
        log("Resolve")
        return ImplementationBasic(dependency: scope.resolve())
    }
    
    // - Type (requires cascade resolution)
    // -- As Self
    containerBuilder.scoped(ImplementationComplex.self)
    // -- As Contract
    containerBuilder.scoped(Contract.self, assigned(ImplementationComplex.self))
    
    let container = containerBuilder.build()
    
    // Scope object
    let scope = container.scope(SomeScopeArgs())
    let resolvedInScope: X = scope.resolve()
    
    log("\(resolvedInScope)")
    
    // Scope closure
    container.scope(SomeScopeArgs()) { scope in
        let resolvedInClosureScope: X = scope.resolve()
        log("\(resolvedInClosureScope.self)")
    }
    
    let innerScope = scope.scope(SomeScopeArgs())
    
    let resolvedInInnerScope: X = innerScope.resolve()
    log("\(resolvedInInnerScope)")
}

// Injecting into SwiftUI

func getAppContainer() -> Container {
    fatalError()
}

extension View {
    func resolving(from scope: DependencyResolutionScope) -> some View {
        environment(\.scope, scope)
    }
}

struct MyApp : App {
    
    private let container = getAppContainer()
    
    var body: some Scene {
        WindowGroup {
            MyRootView()
                .resolving(from: container)
        }
    }
}

struct MyRootView : View {
    
    @Environment(\.scope) private var scope
    
    var body: some View {
        MyDependentView()
            .resolving(from: scope)
    }
}

class X : Resolvablee {
    required init(scope: any DependencyResolutionScope) {
        fatalError()
    }
}

@propertyWrapper
struct Resolved<T> {
    
    var wrappedValue: T
    
    init(wrappedValue: T = justGet()) {
        self.wrappedValue = wrappedValue
    }
}

func justGet<T>() -> T {
    fatalError()
}

@ResolvedScope
struct MyDependentView : View {
    
    @Resolved var x: X
    @Resolved var otherX: X
    
    var body: some View {
        Text("Blah")
    }
}

extension EnvironmentValues {
    var scope: DependencyResolutionScope {
        get { self[DependencyResolutionScopeKey.self] }
        set { self[DependencyResolutionScopeKey.self] = newValue }
    }
}

struct DependencyResolutionScopeKey : EnvironmentKey {
    static let defaultValue: DependencyResolutionScope = .empty
}

extension DependencyResolutionScope where Self == EmptyScope {
    static var empty: DependencyResolutionScope { EmptyScope() }
}

class EmptyScope : DependencyResolutionScope {
    
    let id: UUID = .init(uuidString: "00000000-0000-0000-0000-000000000000")!
    
    func resolve<C>() -> C {
        fatalError("Cannot resolve in EmptyScope.")
    }
    
    func resolve<C>(_: C.Type) -> C {
        resolve()
    }
    
    func scope<A>(_: A) -> DependencyResolutionScope {
        self
    }
    
    func scope<A>(_: A, _ fn: (any DependencyResolutionScope) -> Void) {
        fn(self)
    }
    
    struct EmptyScopeError : Error { }
}

protocol DependencyResolutionScope : DependencyResolverr {
    
    var id: UUID { get }
    
    func scope<A>(_ : A) -> DependencyResolutionScope
    func scope<A>(_ : A, _ fn: (DependencyResolutionScope) -> Void)
}

struct SomeScopeArgs { }
