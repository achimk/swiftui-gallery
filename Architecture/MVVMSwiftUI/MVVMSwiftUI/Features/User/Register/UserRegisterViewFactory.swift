//
//  UserRegisterViewFactory.swift
//  MVVMSwiftUI
//
//  Created by Joachim Kret on 12/05/2023.
//

import SwiftUI

struct UserRegisterViewFactory {
    static func make(container: Container = .shared, coordinator: UserRegisterCoordinating) -> some View {
        let userAvailabilityService = container.resolve(UsernameAvailabilityService.self)
        let viewModel = UserRegisterViewModel(
            coordinator: coordinator,
            usernameAvailabilityService: userAvailabilityService
        )
        return UserRegisterView(viewModel: viewModel)
    }
}
