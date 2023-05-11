//
//  LoadingPublisher.swift
//  MVVMSwiftUI
//
//  Created by Joachim Kret on 11/05/2023.
//

import Foundation
import Combine

enum LoadingState<Output, Failure: Error> {
    case initial
    case loading
    case success(Output)
    case completed
    case failed(Failure)
}

class LoadingPublisher<Action, Output, Failure: Error>: ObservableObject {
    typealias State = LoadingState<Output, Failure>
    
    private let createPublisher: (Action) -> AnyPublisher<Output, Failure>
    
    @Published private(set) var state: State = .initial
    
    init(createPublisher: @escaping (Action) -> AnyPublisher<Output, Failure>) {
        self.createPublisher = createPublisher
    }
    
    func send(_ action: Action, force: Bool = false) {
        
    }
}
