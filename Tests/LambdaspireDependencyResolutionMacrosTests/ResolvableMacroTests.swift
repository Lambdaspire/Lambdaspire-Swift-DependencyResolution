
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(LambdaspireDependencyResolutionMacros)
import LambdaspireDependencyResolutionMacros

let testMacros: [String: Macro.Type] = [
    "Resolvable": ResolvableMacro.self,
    "Resolved": ResolvedMacro.self,
    "ResolvedScope": ResolvedScopeMacro.self
]
#endif

final class ResolvableMacroTests: XCTestCase {
    
    func test_ResolvedAndResolvedScope() { // TODO: Rename
        #if canImport(LambdaspireDependencyResolutionMacros)
        assertMacroExpansion(
            #"""
            @ResolvedScope
            struct TestView : View {
                @Resolved var a: Int
                @Resolved private var b: Bool
            
                var body: some View {
                    Text("Test")
                }
            }
            """#,
            expandedSource: #"""
            struct TestView : View {
                var a: Int {
                    get {
                        guard let resolved_a else {
                            let r: Int = resolved_scope.resolve()
                            resolved_a = r
                            return r
                        }
                        return resolved_a
                    }
                }

                @State private var resolved_a: Int? = nil
                private var b: Bool {
                    get {
                        guard let resolved_b else {
                            let r: Bool = resolved_scope.resolve()
                            resolved_b = r
                            return r
                        }
                        return resolved_b
                    }
                }

                @State private var resolved_b: Bool? = nil

                var body: some View {
                    Text("Test")
                }
            
                @Environment(\.scope) private var resolved_scope
            }
            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func test_ResolvableMacro_ProducesResolvableExtensionAndConformingInitializer() throws {
        #if canImport(LambdaspireDependencyResolutionMacros)
        assertMacroExpansion(
            #"""
            @Resolvable
            class Test {
            
                let a: Int
                let b: Bool
                let c: String
            
                init(a: Int, b: Bool, c: String) {
                    self.a = a
                    self.b = b
                    self.c = c
                }
            }
            """#,
            expandedSource: #"""
            class Test {
            
                let a: Int
                let b: Bool
                let c: String
            
                init(a: Int, b: Bool, c: String) {
                    self.a = a
                    self.b = b
                    self.c = c
                }
            
                required convenience init(resolver: DependencyResolver) {
                    self.init(a: resolver.resolve(), b: resolver.resolve(), c: resolver.resolve())
                }
            }
            
            extension Test : Resolvable {
            }
            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
