//
//  UserRegisterViewModel.swift
//  MVVMSwiftUI
//
//  Created by Joachim Kret on 11/05/2023.
//

import Combine
import Foundation

class UserRegisterViewModel: ObservableObject {
    private let coordinator: UserRegisterCoordinating
    private let usernameAvailabilityService: UsernameAvailabilityService
    private var cancellableSet: Set<AnyCancellable> = []

    // Inputs
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var repeatPassword: String = ""

    // Outputs
    @Published private(set) var isUsernameLengthValid: Bool = false
    @Published private(set) var isUsernameAvailable: Bool = false
    @Published private(set) var isPasswordLengthValid: Bool = false
    @Published private(set) var isPasswordCapitalLetterValid: Bool = false
    @Published private(set) var isPasswordConfirmValid: Bool = false
    @Published private(set) var isSignUpEnabled: Bool = false

    init(
        coordinator: UserRegisterCoordinating,
        usernameAvailabilityService: UsernameAvailabilityService
    ) {
        self.coordinator = coordinator
        self.usernameAvailabilityService = usernameAvailabilityService

        let usernameLengthValidator = makeUsernameLenghtValidator()
        usernameLengthValidator
            .map { $0 != nil }
            .sink { [weak self] in self?.isUsernameLengthValid = $0 }
            .store(in: &cancellableSet)

        let usernameValidator = makeUsernameAvailableValidator(for: usernameLengthValidator)
        usernameValidator
            .sink { [weak self] in self?.isUsernameAvailable = $0 }
            .store(in: &cancellableSet)

        makePasswordLengthValidator()
            .sink { [weak self] in self?.isPasswordLengthValid = $0 }
            .store(in: &cancellableSet)

        makePasswordCapitalLetterValidator()
            .sink { [weak self] in self?.isPasswordCapitalLetterValid = $0 }
            .store(in: &cancellableSet)

        makePasswordConfirmValidator()
            .sink { [weak self] in self?.isPasswordConfirmValid = $0 }
            .store(in: &cancellableSet)

        makeSignUpCredentials()
            .map { $0 != nil }
            .sink { [weak self] in self?.isSignUpEnabled = $0 }
            .store(in: &cancellableSet)
    }

    func signIn() {
        coordinator.presentLoginScreen()
    }

    private func makeUsernameLenghtValidator() -> AnyPublisher<String?, Never> {
        $username
            .map { $0.count >= 4 ? $0 : nil }
            .eraseToAnyPublisher()
    }

    private func makeUsernameAvailableValidator(for input: AnyPublisher<String?, Never>) -> AnyPublisher<Bool, Never> {
        input
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .flatMap { [usernameAvailabilityService] username in
                if let username {
                    return Just(username)
                        .flatMap { username in
                            Future { promise in
                                usernameAvailabilityService.usernameAvailable(username) { isAvailable in
                                    promise(.success(isAvailable))
                                }
                            }
                        }
                        .eraseToAnyPublisher()
                } else {
                    return Just(false)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    private func makePasswordLengthValidator() -> AnyPublisher<Bool, Never> {
        $password
            .map { $0.count >= 8 }
            .eraseToAnyPublisher()
    }

    private func makePasswordCapitalLetterValidator() -> AnyPublisher<Bool, Never> {
        $password
            .map {
                $0.range(of: "[A-Z]", options: .regularExpression) != nil
            }
            .eraseToAnyPublisher()
    }

    private func makePasswordConfirmValidator() -> AnyPublisher<Bool, Never> {
        Publishers.CombineLatest($password, $repeatPassword)
            .map {
                !$0.isEmpty && ($0 == $1)
            }
            .eraseToAnyPublisher()
    }

    private func makeSignUpCredentials() -> AnyPublisher<(String, String)?, Never> {
        let usernameValidated = Publishers.CombineLatest($isUsernameLengthValid, $isUsernameAvailable)
            .map { $0 && $1 }

        let passwordValidated = Publishers.CombineLatest3($isPasswordLengthValid, $isPasswordCapitalLetterValid, $isPasswordConfirmValid)
            .map { $0 && $1 && $2 }

        return Publishers.CombineLatest(usernameValidated, passwordValidated)
            .map { $0 && $1 }
            .map { [username, password] isValid in
                isValid ? (username, password) : nil
            }
            .eraseToAnyPublisher()
    }
}
