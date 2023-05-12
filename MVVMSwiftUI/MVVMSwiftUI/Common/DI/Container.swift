//
//  Container.swift
//  MVVMSwiftUI
//
//  Created by Joachim Kret on 12/05/2023.
//

import Foundation

final class Container {
    
    typealias Resolver = (Container) -> Any
    
    private var resolversByTypes: [String: Resolver] = [:]
    
    static let shared = Container()
    
    init() { }
    
    func register<T>(_ type: T.Type, resolver: @escaping (Container) -> T) {
        let key = String(describing: T.self)
        resolversByTypes[key] = resolver
    }
    
    func resolve<T>(_ type: T.Type, otherwise: (() -> T)? = nil) -> T {
        let key = String(describing: T.self)
        
        guard let resolver = resolversByTypes[key] else {
            return otherwise?() ?? undefined("Unregistered resolver for \(key) type!")
        }
        
        return resolver(self) as? T ?? undefined("Unable to resolve \(T.self)!")
    }
}
