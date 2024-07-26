
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct ResolvedScopeMacro : MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext) throws -> [DeclSyntax] {
            
            guard let _ = declaration.as(StructDeclSyntax.self) else {
                context.diagnose(.init(node: node, message: ResolvedScopeMacroUsageError.notStruct))
                return []
            }
            
            return [
                #"""
                @Environment(\.scope) private var resolved_scope
                """#
            ]
        }
}

enum ResolvedScopeMacroUsageError : String, DiagnosticMessage {
    
    case notStruct = "@ResolvedScope macro is only valid on a SwiftUI View struct."
    
    var message: String { rawValue }
    
    var diagnosticID: MessageID { .init(domain: "LambdaspireDependencyResolution", id: "\(self)") }
    
    var severity: DiagnosticSeverity { .error }
}
