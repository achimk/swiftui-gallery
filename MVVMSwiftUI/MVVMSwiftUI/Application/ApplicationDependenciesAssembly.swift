//
//  ApplicationDependenciesAssembly.swift
//  MVVMSwiftUI
//
//  Created by Joachim Kret on 12/05/2023.
//

import Foundation

struct ApplicationDependenciesAssembly {
    
    static func assemble(with container: Container = .shared) {
        UserDependenciesAssembly.assemble(with: container)
    }
}
