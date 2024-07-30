
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(LambdaspireDependencyResolutionMacros)
import LambdaspireDependencyResolutionMacros

let testMacros: [String: Macro.Type] = [
    "Resolvable": ResolvableMacro.self
]
#endif

final class ResolvableMacroTests: XCTestCase {
    
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
            
                required convenience init(scope: DependencyResolutionScope) {
                    self.init(a: scope.resolve(), b: scope.resolve(), c: scope.resolve())
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
