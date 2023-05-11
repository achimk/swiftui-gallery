//
//  UsernameAvailabilityService.swift
//  MVVMSwiftUI
//
//  Created by Joachim Kret on 11/05/2023.
//

import Foundation

protocol UsernameAvailabilityService {
    func usernameAvailable(_ username: String, completion: @escaping (Bool) -> Void)
}
