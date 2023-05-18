//
//  MVVMSwiftUIApp.swift
//  MVVMSwiftUI
//
//  Created by Joachim Kret on 11/05/2023.
//

import SwiftUI

@main
struct MVVMSwiftUIApp: App {
    
    init() {
        ApplicationDependenciesAssembly.assemble(with: .shared)
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
