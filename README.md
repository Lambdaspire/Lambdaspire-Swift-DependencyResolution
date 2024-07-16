# Lambdaspire Swift Dependency Resolution

A lightweight IoC Container / Service Locator / Dependency Injection package for Swift.

## Usage

### High Level

Use `ServiceLocator` to register and resolve dependencies.

```swift
let serviceLocator: ServiceLocator = .init()

// There are many ways to register a dependency.
serviceLocator.register(...)

// Resolve via type inference from the left side.
let thing: SomeThing = serviceLocator.resolve()

// Resolve by specifying type on the right side.
let otherThing = serviceLocator.resolve(SomeThing.self)
```

`ServiceLocator` conforms to both `DependencyRegistry` and `DependencyResolver` from the [Abstractions package](https://github.com/Lambdaspire/Lambdaspire-Swift-Abstractions) and is likely all you'd ever need.

### Registration and Resolution

You can register dependencies in a variety of ways.

#### Singletons

Registering an instance of any type `T` creates a singleton registration for that type.
Hence, resolving `T` will always produce the singleton.

```swift
let someSingleton: SomeThing = .init()

serviceLocator.register(someSingleton)

let resolvedSingleton: SomeThing = serviceLocator.resolve()
```

You can register a singleton of type `T` as any compatible type.
Hence, resolving the base type `T` will always produce the singleton.

```swift
let someSingleton: SomeThing = .init()

serviceLocator.register(BaseThing.self, someSingleton)

let resolvedSingelton: BaseThing = serviceLocator.resolve()
```

#### Factories

Registering a closure returning any type `T` creates a dynamic registration for that type.
Hence, resolving `T` will execute the closure to produce its return value.

```swift
// A new SomeThing every time.
serviceLocator.register { SomeThing() }

var someThing: SomeThing = serviceLocator.resolve()
someThing = serviceLocator.resolve() // Another one.
someThing = serviceLocator.resolve() // Another one.
```

You can register a factory producing `T` as any compatible type.
Hence, resolving the base type `T` will execute the closure to produce its return value.

```swift
// A new SomeThing every time, resolved via BaseThing.
serviceLocator.register(BaseThing.self) { SomeThing() }

var thing: BaseThing = serviceLocator.resolve()
thing = serviceLocator.resolve() // Another one.
thing = serviceLocator.resolve() // Another one.
```

### Complex Graphs

So far we have covered how to register standalone types with simple object graphs.
Complex object graphs with hierarchies of dependencies that we want resolved require an additional step to avoid verbosity.

#### Verbosity

This is the verbose approach:

```swift
serviceLocator.register {
    ComplexObject(
        dependencyA: serviceLocator.resolve(),
        dependencyB: serviceLcoator.resolve(),
        // etc
    )
}
```

If each dependency has its own dependencies, this quickly becomes a maintenance burden and, generally, ugly.

Not good. Instead, use the `@Resolvable` macro to enable more automatic cascading resolution.

#### @Resolvable Macro

Apply the `@Resolvable` macro to any class that has dependencies.

```swift
protocol ComplexProtocol {
    var dependencyA: DependencyA { get }
    var dependencyB: DependencyB { get }
}

@Resolvable
class ComplexObject {
    let dependencyA: DependencyA
    let dependencyB: DependencyB
}
```

The macro will generate the necessary (hidden) code to enable a more idiomatic registration:

```swift
serviceLocator.register(asSelf: ComplexObject.self)

// Don't forget to register DependencyA and DependencyB appropriately.
```

You can also register the concrete implementation behind an abstraction for any `@Resolvable` class as follows:

```swift
// It's not pretty but it works.
serviceLocator.register(ComplexProtocol.self) { $0(ComplexObject.self) }
```

## Appendix

### How `@Resolvable` Works

You don't need to know this, but it might help.

`@Resolvable` enables more idiomatic IoC by synthesizing a couple of things:

1. Conformance to the `Resolvable` protocol:

```swift
@Resolvable
class MyClass { ... }

// becomes

class MyClass { ... }
extension MyClass : Resolvable { }
```

2. An initializer which accepts a `DependencyResolver` to construct itself (as per the `Resolvable` protocol's requirements).

```swift
@Resolvable
class MyClass {
    let dependency: Dependency
}

// becomes

class MyClass {
    let dependency: Dependency

    required init(resolver: DependencyResolver) {
        self.dependency = resolver.resolve()
    }
}
extension MyClass : Resolvable { }
```

If an initializer already exists, it will reuse that initializer in the generated initializer.

```swift
@Resolvable
class MyClass {
    let dependency: Dependency

    init(dependency: Dependency) {
        self.dependency = dependency
    }
}

// becomes

class MyClass {
    let dependency: Dependency

    init(dependency: Dependency) {
        self.dependency = dependency
    }

    required convenience init(resolver: DependencyResolver) {
        self.init(dependency: resolver.resolve())
    }
}
```

This presents two benefits:

1. If you don't intend to instantiate a `@Resolvable` class outside of IoC, then you don't need to declare an `init` for it as the macro will generate a comprehensive one for you. This means your classes can be more concise.

```swift
@Resolvable
class MyClass {
    let dependency: Dependency

    // No init required - the macro will create one.
}
```

2. If you do need an explicit `init` (e.g. for test mocking or more complex initialization scenarios) then you needn't sacrifice production code legibility as the macro generated code is invisible.

Once the above two things have been managed, the `ServiceLocator` will manage the cascading resolution of dependencies by doing something roughly akin to this:

```swift
func register<R: Resolvable>(_ : R.Type) {
    serviveLocator.register {
        R.init(resolver: self)
    }
}
```

i.e. a simple factory registration that invokes the static `init(resolver: DependencyResolver)` created by the macro, which in turn initializes all members by resolving them via the same `DependnecyResolver` in the same way.
