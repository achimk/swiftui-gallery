//
//  UserCoordinatorView.swift
//  MVVMSwiftUI
//
//  Created by Joachim Kret on 12/05/2023.
//

import SwiftUI

protocol UserLoginCoordinating {
    func presentRegisterScreen()
}

protocol UserRegisterCoordinating {
    func presentLoginScreen()
}

class UserCoordinator: ObservableObject, UserLoginCoordinating, UserRegisterCoordinating {
    enum Scene {
        case login
        case register
    }

    @Published private(set) var currentScene: Scene = .login

    func presentLoginScreen() {
        currentScene = .login
    }

    func presentRegisterScreen() {
        currentScene = .register
    }
}

struct UserCoordinatorView: View {
    @ObservedObject var coordinator: UserCoordinator

    var body: some View {
        switch coordinator.currentScene {
        case .login:
            UserLoginViewFactory.make(coordinator: coordinator)
        case .register:
            UserRegisterViewFactory.make(coordinator: coordinator)
        }
    }
}

struct UserCoordinatorView_Previews: PreviewProvider {
    static var previews: some View {
        let coordinator = UserCoordinator()
        UserCoordinatorView(coordinator: coordinator)
    }
}
