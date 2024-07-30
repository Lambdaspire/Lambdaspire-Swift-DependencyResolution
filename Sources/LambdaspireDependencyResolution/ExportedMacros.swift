
import LambdaspireAbstractions

@attached(member, names: arbitrary)
@attached(extension, conformances: Resolvable)
public macro Resolvable() = #externalMacro(module: "LambdaspireDependencyResolutionMacros", type: "ResolvableMacro")
