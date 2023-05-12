//
//  UserLoginViewModel.swift
//  MVVMSwiftUI
//
//  Created by Joachim Kret on 12/05/2023.
//

import Combine
import Foundation

enum UserLoginState {
    case idle
    case progress
    case success
    case failure
}

class UserLoginViewModel: ObservableObject {
    private let userLoginService: UserLoginService
    private var loginCancellable: AnyCancellable?
    private var cancellablesSet: Set<AnyCancellable> = []
    
    @Published var username: String = ""
    @Published var password: String = ""
    @Published private(set) var loginState: UserLoginState = .idle
    @Published private(set) var isSignInEnabled: Bool = false
    
    init(userLoginService: UserLoginService) {
        self.userLoginService = userLoginService
        makeBindings()
    }
    
    func signIn() {
        guard isSignInEnabled && loginState != .progress else {
            return
        }
        
        loginState = .progress
        let credentials = UserCredentials(username: username, password: password)
        
        loginCancellable = userLoginService.login(with: credentials)
            .sink { [weak self] in
                switch $0 {
                case .success:
                    self?.loginState = .success
                case .failure:
                    self?.loginState = .failure
                }
            }
    }
}

extension UserLoginViewModel {
    
    private func makeBindings() {
        let usernameValidator = makeUsernameValidator()
        let passwordValidator = makePasswordValidator()
        Publishers.CombineLatest(usernameValidator, passwordValidator)
            .map { $0 && $1 }
            .sink { [weak self] in self?.isSignInEnabled = $0 }
            .store(in: &cancellablesSet)
    }
    
    private func makeUsernameValidator() -> AnyPublisher<Bool, Never> {
        $username
            .map { $0.count >= 4 }
            .eraseToAnyPublisher()
    }
    
    private func makePasswordValidator() -> AnyPublisher<Bool, Never> {
        $password
            .map { $0.count >= 8 }
            .eraseToAnyPublisher()
    }
}
