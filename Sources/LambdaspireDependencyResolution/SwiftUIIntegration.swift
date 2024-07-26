
import SwiftUI

public extension View {
    func resolving(from scope: DependencyResolutionScope) -> some View {
        environment(\.scope, scope)
    }
}

public extension EnvironmentValues {
    var scope: DependencyResolutionScope {
        get { self[DependencyResolutionScopeKey.self] }
        set { self[DependencyResolutionScopeKey.self] = newValue }
    }
}

public struct DependencyResolutionScopeKey : EnvironmentKey {
    public static let defaultValue: DependencyResolutionScope = .empty
}

public extension DependencyResolutionScope where Self == EmptyScope {
    static var empty: DependencyResolutionScope { EmptyScope() }
}

public class EmptyScope : DependencyResolutionScope {
    
    public let id: String = "EmptyScope-\(UUID())"
    
    public func resolve<C>() -> C {
        fatalError("Cannot resolve in EmptyScope.")
    }
    
    public func resolve<C>(_: C.Type) -> C {
        resolve()
    }
    
    public func tryResolve<C>() -> C? {
        nil
    }
    
    public func tryResolve<C>(_: C.Type) -> C? {
        tryResolve()
    }
    
    public func scope() -> DependencyResolutionScope {
        self
    }
}
