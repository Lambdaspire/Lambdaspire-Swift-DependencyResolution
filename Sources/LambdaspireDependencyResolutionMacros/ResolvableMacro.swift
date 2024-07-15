
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct ResolvableMacro : MemberMacro, ExtensionMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext) throws -> [ExtensionDeclSyntax] {
            [
                try? ExtensionDeclSyntax("extension \(type.trimmed) : Resolvable { }")
            ]
            .compactMap { $0 }
        }
    
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext) throws -> [DeclSyntax] {
            
            let parameters = declaration
                .as(ClassDeclSyntax.self)?
                .memberBlock
                .members
                .compactMap { m in m.decl.as(InitializerDeclSyntax.self) }
                .first?
                .signature
                .parameterClause.parameters
                .map { p in
                    "self.\(p.firstName) = resolver.resolve()"
                } ?? []
            
            return [
                """
                required init(resolver: DependencyResolver) {
                    \(raw: parameters.joined(separator: "\n"))
                }
                """
            ]
        }
}
