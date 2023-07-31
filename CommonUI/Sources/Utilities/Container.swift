import Foundation

public final class Container {
    public typealias Resolver = (Container) -> Any

    private var resolversByTypes: [String: Resolver] = [:]

    public static let shared = Container()

    public init() {}

    public func register<T>(_: T.Type, resolver: @escaping (Container) -> T) {
        let key = String(describing: T.self)
        resolversByTypes[key] = resolver
    }

    public func resolve<T>(_: T.Type, otherwise: (() -> T)? = nil) -> T {
        let key = String(describing: T.self)

        guard let resolver = resolversByTypes[key] else {
            return otherwise?() ?? undefined("Unregistered resolver for \(key) type!")
        }

        return resolver(self) as? T ?? undefined("Unable to resolve \(T.self)!")
    }
}
