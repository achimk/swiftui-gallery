//
//  udefined.swift
//  MVVMSwiftUI
//
//  Created by Joachim Kret on 12/05/2023.
//

import Foundation

public func undefined<T>(_ message: String? = nil) -> T {
    fatalError(message ?? "Parameter \(T.self) not exists!")
}
