
@attached(member, names: arbitrary)
@attached(extension, conformances: Resolvable)
public macro Resolvable() = #externalMacro(module: "LambdaspireDependencyResolutionMacros", type: "ResolvableMacro")

@attached(peer, names: arbitrary)
@attached(accessor, names: named(get), named(set))
public macro Resolved() = #externalMacro(module: "LambdaspireDependencyResolutionMacros", type: "ResolvedMacro")

@attached(member, names: arbitrary)
public macro ResolvedScope() = #externalMacro(module: "LambdaspireDependencyResolutionMacros", type: "ResolvedScopeMacro")
