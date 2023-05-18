//
//  MockUserLoginService.swift
//  MVVMSwiftUI
//
//  Created by Joachim Kret on 12/05/2023.
//

import Combine
import Foundation

class MockUserLoginService: UserLoginService {
    var generateLoginCredentialsResult: (UserCredentials) -> AnyPublisher<Result<Void, UserLoginError>, Never> = { _ in
        Just<Result<Void, UserLoginError>>(.success(()))
            .delay(for: 0.5, scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func login(with credentials: UserCredentials) -> AnyPublisher<Result<Void, UserLoginError>, Never> {
        return generateLoginCredentialsResult(credentials)
    }
}
