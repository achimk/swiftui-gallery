//
//  MockUsernameAvailabilityService.swift
//  MVVMSwiftUI
//
//  Created by Joachim Kret on 11/05/2023.
//

import Foundation

class MockUsernameAvailabilityService: UsernameAvailabilityService {
    var isUsernameAvailable: (String, @escaping (Bool) -> Void) -> Void = { username, completion in
        print("Check username availability for: \"\(username)\"")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(true)
        }
    }
    
    func usernameAvailable(_ username: String, completion: @escaping (Bool) -> Void) {
        isUsernameAvailable(username, completion)
    }
}
