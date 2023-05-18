//
//  UserLoginViewFactory.swift
//  MVVMSwiftUI
//
//  Created by Joachim Kret on 12/05/2023.
//

import SwiftUI

struct UserLoginViewFactory {
    
    static func make(
        coordinator: UserLoginCoordinating,
        container: Container = .shared
    ) -> some View {
        let userLoginService = container.resolve(UserLoginService.self)
        let viewModel = UserLoginViewModel(coordinator: coordinator, userLoginService: userLoginService)
        return UserLoginView(viewModel: viewModel)
    }
}
