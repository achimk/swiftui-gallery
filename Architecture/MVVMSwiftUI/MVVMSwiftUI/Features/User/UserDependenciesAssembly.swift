//
//  UserDependenciesAssembly.swift
//  MVVMSwiftUI
//
//  Created by Joachim Kret on 12/05/2023.
//

import Foundation

class UserDependenciesAssembly {

    static func assemble(with container: Container) {
        container.register(UserLoginService.self, resolver: { _ in MockUserLoginService() })
        container.register(UsernameAvailabilityService.self, resolver: { _ in MockUsernameAvailabilityService() })
    }
}
