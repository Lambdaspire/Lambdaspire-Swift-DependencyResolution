
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct LambdaspireDependencyResolutionMacros: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ResolvableMacro.self,
        ResolvedMacro.self,
        ResolvedScopeMacro.self
    ]
}
