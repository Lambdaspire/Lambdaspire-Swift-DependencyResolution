
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

enum ResolvableMacroUsageError : String, DiagnosticMessage {
    
    case notClass = "@Resolvable macro must be applied to a class."
    
    var message: String { rawValue }
    
    var diagnosticID: MessageID { .init(domain: "LambdaspireDependencyResolution", id: "\(self)") }
    
    var severity: DiagnosticSeverity { .error }
}

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
            
            // If there is an existing init, the required init will be a convenience init that calls that initializer with resolver.resolve() for all arguments.
            
            let classDecl = declaration
                .as(ClassDeclSyntax.self)
            
            guard let classDecl else {
                context.diagnose(.init(node: node, message: ResolvableMacroUsageError.notClass))
                return []
            }
            
            
            // 1. Try to use an existing initializer.
            
            let existingInit = classDecl
                .memberBlock
                .members
                .compactMap { m in m.decl.as(InitializerDeclSyntax.self) }
                .first
            
            if let existingInit {
                
                let arguments = existingInit
                    .signature
                    .parameterClause
                    .parameters
                    .map { p in
                        "\(p.firstName): scope.resolve()"
                    }
                    
                return [
                    """
                    required convenience init(scope: DependencyResolutionScope) {
                        self.init(\(raw: arguments.joined(separator: ", ")))
                    }
                    """
                ]
            }
            
            // 2. In lieu of an existing initializer, attempt to create a simple, naive one that initializes all appropriate members.
            // It may not be sufficient.
            
            let assignments = classDecl
                .memberBlock
                .members
                .compactMap { m in m.decl.as(VariableDeclSyntax.self) }
                .compactMap { v in v.bindings.first }
                .filter { b in
                    // Must have no accessor ( get or set ) at all, for now.
                    b.accessorBlock == nil &&
                    // Must not be initialized inline.
                    b.initializer == nil
                }
                .map { b in
                    b.pattern
                }
                .map { name in
                    "self.\(name) = scope.resolve()"
                }
            
            return [
                """
                required init(scope: DependencyResolutionScope) {
                    \(raw: assignments.joined(separator: "\n"))
                }
                """
            ]
        }
}
