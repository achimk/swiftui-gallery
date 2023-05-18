//
//  UserLoginService.swift
//  MVVMSwiftUI
//
//  Created by Joachim Kret on 12/05/2023.
//

import Combine

struct UserCredentials {
    let username: String
    let password: String
}

enum UserLoginError: Error {
    case invalidCredentials
    case unknownErrorOccured
}

protocol UserLoginService {
    func login(with credentials: UserCredentials) -> AnyPublisher<Result<Void, UserLoginError>, Never>
}
