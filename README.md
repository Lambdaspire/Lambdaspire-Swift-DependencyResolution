# Lambdaspire Swift Dependency Resolution

A lightweight IoC Container / Service Locator / Dependency Injection package for Swift.

Inspired by Autofac and the modern .NET SDK.

## Usage

### High Level

Use `ContainerBuilder` to to register dependencies and build a `Container`.

The `ContainerBuilder` type conforms to `DependencyRegistry` from the Abstractions package, and the `Container` type conforms to the `DependencyResolver` protocol. Ideally, use these abstractions in your code rathern than the concrete container types.

Register dependencies as one of:
- Transient: A new instance every time the dependency is resolved.
- Scoped: A common instance every time the dependency is resolved in the same scope.
- Singleton: A globally common instance every time the dependency is resolved.

Use `Container` to resolve dependencies as per the registrations.

```swift
let builder: ContainerBuilder = .init()

builder.transient(SomeStatelessService.self)
builder.scoped(SomeContextuallyStatefulService.self)
builder.singleton(SomeGloballyStatefulService.self)

let container = builder.build()
```

### Scopes

The `DependencyResolutionScope` protocol defines means to resolve dependencies and to create a new scope.

The `DependencyResolver` protocol extends this protocol, and therefore the `Container` type conforms to it.

Dependencies registered as `scoped` act as singletons within that scope.

```swift
let builder: ContainerBuilder = .init()

builder.scoped { TodoList() }

let container = builder.build()

let rootList: TodoList = container.resolve()
rootList.add("Demonstrate Scoped Dependencies")
rootList.print() // Will print one item.

let scope = container.scope()

let scopedList: TodoList = scope.resolve()
scopedList.print() // Will print zero items.
```

### Registration as Self

The simplest way to register dependencies is as self. That is, if you have some concrete type `OpenIdConnectAuthenticationService` and you want to resolve it as such, you can register and resolve like this:

```swift
let builder: ContainerBuilder = .init()

builder.transient(OpenIdConnectAuthenticationService.self)

let container = builder.build()

let openIdAuth: OpenIdConnectAuthenticationService = container.resolve()
```

While convenient, and in some cases totally fine, this violates the [Dependency Inversion principle](https://en.wikipedia.org/wiki/Dependency_inversion_principle) in [SOLID](https://en.wikipedia.org/wiki/SOLID) which states that implementation details should depend on abstractions.

### Registration as Abstraction

To register and resolve dependencies in a SOLID fashion, you can register concrete implementations behind abstractions and resolve via said abstractions. To do this with our authentication example above, we might introduce a protocol `AuthenticationService` which `OpenIdConnectAuthenticationService` conforms to. We would then depend on that protocol abstraction instead of the concrete class.

```swift
let builder: ContainerBuilder = .init()

builder.transient(AuthenticationService.self, assigned(OpenIdConnectAuthenticationService.self))

let container = builder.build()

let auth: AuthenticationService = container.resolve()
```

This means that, perhaps for testing purposes or if your authentication story changes, you can substitute in an alternative implementation.

```swift
// builder.transient(AuthenticationService.self, assigned(OpenIdConnectAuthenticationService.self))
builder.transient(AuthenticationService.self, assigned(MockAuthenticationService.self))
``` 

Abstractions needn't be protocols. The concrete type must simply inherit from / conform to the abstract type. 

### Registration Methods

The `DependencyRegistry` protocol has 7 methods per registration type (transient, singleton, scoped):

```swift
func transient<I>(_ : @escaping () -> I)
func transient<I>(_ : @escaping (DependencyResolutionScope) -> I)
func transient<C>(_ : C.Type, _ : @escaping () -> C)
func transient<C>(_ : C.Type, _ : @escaping (DependencyResolutionScope) -> C)
func transient<C, I>(_ : C.Type, _ : Assigned<C, I>)
func transient<I: Resolvable>(_ : I.Type)
func transient<C, I: Resolvable>(_ : C.Type, _ : Assigned<C, I>)

// Repeat for singleton and scoped.
```

We'll cover each method, subbing in `register` instead of `transient` or the like.

#### 1. Implementation Factory

##### Definition

```swift
func register<I>(_ : @escaping () -> I)
```

Registers an inferred type `I` using a function returning that type.

##### Usage

```swift
builder.register { Implementation() }
// ...
let r: Implementation = container.resolve()
```

Note that the parameter is simply a function, so you could also use the type's static `init` function if you prefer the parenthetical style over the closure braces:

```swift
builder.register(Implementation.init)
// ...
let r: Implementation = container.resolve()
```

#### 2. Implementation Factory with Scope Parameter

##### Definition

```swift
func register<I>(_ : @escaping (DependencyResolutionScope) -> I)
```

Registers an inferred type `I` using a function parameterised by the current scope.

##### Usage

```swift
builder.register { scope in
    Implementation(dependency: scope.resolve())
}
// ...
let r: Implementation = container.resolve()
```

#### 3. Contract Factory

##### Definition

```swift
func register<C>(_ : C.Type, _ : @escaping () -> C)
```

Registers a specified type `C` using a function that may return any `C` (typically a sub-type).

##### Usage

```swift
builder.register(Contract.self) { Implementation() }
// ...
let r: Contract = container.resolve()
```

Again, if you prefer the parenthetical style, you can do something like this (where applicable):

```swift
builder.register(Contract.self, Implementation.init)
// ...
let r: Contract = container.resolve()
```

#### 4. Contract Factory with Scope Parameter

##### Definition

```swift
func register<C>(_ : C.Type, _ : @escaping (DependencyResolutionScope) -> C)
```

Registers a specified type `C` using a function parameterised by the current scope.

##### Usage

```swift
builder.register(Contract.self) { scope in
    Implementation(dependency: scope.resolve())
}
// ...
let r: Contract = container.resolve()
```

#### 5. Contract as Implementation by Types

##### Definition

```swift
func register<C, I>(_ : C.Type, _ : Assigned<C, I>)
```

Registers a specified type `C` against a specified, compatible type `I`.

##### Usage

```swift
builder.register(Implementation.init)
builder.register(Contract.self, assigned(Implementation.self))
// ...
let r: Contract = container.resolve()
```

Note the unfortunate compiler hack, `assigned(...)`, which enforces type compatibility.

Note also that, because `Contract` is registered against the `Implementation` type (rather than a method of instantiation), a method for instantiating `Implementation` must also be registered. This need is mitigated by `Resolvable` types and is demonstrated specifically in number 7.

#### 6. Resolvable Implementation by Type

##### Definition

```swift
func register<I: Resolvable>(_ : I.Type)
```

Registers a specified type `I` where `I` conforms to `Resolvable`.

The `Resolvable` protocol and `@Resolvable` macro are described in detail later.

##### Usage

```swift
@Resolvable
class ResolvableImplementation {
    // ...
}

// ...

builder.register(ResolvableImplementation.self)
// ...
let r: ResolvableImplementation = container.resolve()
```

Note the use of the `@Resolvable` attribute on the class declaration.

Note also the absence of a need to specify an instantiation method; the type can be registered merely as itself without specifying some function to produce an instance of it.

#### 7. Contract as Resolvable Implementation by Types

##### Definition

```swift
func register<C, I: Resolvable>(_ : C.Type, _ : Assigned<C, I>)
```

Registers a specified type `C` against a specified, compatible type `I` where `I` conforms to `Resolvable`.

##### Usage

```swift
protocol Contract {
    // ...
}

@Resolvable
class ResolvableImplementation : Contract {
    // ...
}

// ...

builder.register(Contract.self, assigned(ResolvableImplementation.self))
// ...
let r: Contract = container.resolve()
```

## About `@Resolvable`

The `Resolvable` protocol is defined in Abstractions and simply defines an initializer that accepts a scope.

```swift
public protocol Resolvable {
    init(scope: DependencyResolutionScope)
}
```

This package defines an accompanying macro, `@Resolvable`, that can be applied to any type so that the required initializer can be auto-generated. This enables a more idiomatic style of cascading dependency resolution without manually declaring and maintaining initializers. This is particularly useful for complex dependency graphs.

### Example

#### Not Ideal Approach

Imagine you have an authentication system implemented like below:

```swift
class AuthContext : ObservableObject {
    
    @Published private(set) var user: Loadable<User> = .notLoaded
    
    private let auth: AuthService
    
    init(auth: AuthService) {
        self.auth = auth
    }
    
    func signIn() {
        user = .loading
        Task {
            do {
                user = .loaded(try await auth.signIn())
            } catch {
                user = .failed(error)
            }
        }
    }
}

protocol AuthService {
    func signIn() async throws -> User
}

class OktaAuthService : AuthService {

    init(config: OktaConfig) {
        OktaLibrary.configure(config)
    }

    func signIn() async throws -> User {
        OktaUserMapper.map(try await OktaLibrary.signIn())
    }
}
```

To wire all this up as is in a `Container`, we could do something like this:

```swift
let builder: ContainerBuilder = .init()

builder.singleton { scope in
    AuthContext(auth: scope.resolve()
}

builder.transient(AuthService.self) { scope in
    OktaAuthService(config: OktaConfig.fromBundle)
}

let container = builder.build()
```

It's okay, but the "Factory with Scope Parameter" methods are a verbose way to resolve complex dependency graphs (i.e. when dependencies have dependencies which have dependencies which have dependencies... etc). It also means the registration code requires ongoing maintenance as initializers change shape.

For example, if `AuthContext` becomes dependent on additional services:

```swift
class AuthContext : ObservableObject {
    // ...
    
    private let analytics: AnalyticsService
    private let cache: CacheService
    
    // ...
}
```

Then the registration must be manually updated:

```swift
// ...

builder.singleton { scope in
    AuthContext(
        auth: scope.resolve(), 
        analytics: scope.resolve(),
        cache: scope.resolve())
}

// ...
```

It's a simple change, but this quickly becomes tiresome as a codebase evolves, and ugly as the dependencies grow in number. It's clear from the repetition that there is room for automation.

#### More Ideal Approach

Instead, define your classes like this:

```swift
@Resolvable
class AuthContext : ObservableObject {
    
    @Published private(set) var user: Loadable<User> = .notLoaded
    
    private let auth: AuthService
    
    init(auth: AuthService) {
        self.auth = auth
    }
    
    func signIn() {
        user = .loading
        Task {
            do {
                user = .loaded(try await auth.signIn())
            } catch {
                user = .failed(error)
            }
        }
    }
}

protocol AuthService {
    func signIn() async throws -> User
}

@Resolvable
class OktaAuthService : AuthService {

    init(config: OktaConfig) {
        OktaLibrary.configure(config)
    }

    func signIn() async throws -> User {
        OktaUserMapper.map(try await OktaLibrary.signIn())
    }
}
```

Register the dependency graph like this:

```swift
let builder: ContainerBuilder = .init()

builder.singleton(AuthContext.self)

builder.transient(AuthService.self, assigned(OktaAuthService))

builder.transient(OktaConfig.fromBundle)

let container = builder.build()
```

This way, even as dependencies increase in number, our registrations need not change. It's more concise, easier to read, and requires much less maintenance as the codebase evolves.
