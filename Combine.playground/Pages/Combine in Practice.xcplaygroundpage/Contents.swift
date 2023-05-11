import Combine
import Foundation

struct SubscribePublisherSample {
    
    static func execute() {
        var cancelablesBag: Set<AnyCancellable> = []
        let initialPublisher = PassthroughSubject<Int, Never>()
        let sharedPublisher = CurrentValueSubject<Int, Never>(0)
        
        initialPublisher.subscribe(sharedPublisher).store(in: &cancelablesBag)
        sharedPublisher.sink { [weak sharedPublisher] value in
            print("-> value: \(value), current shared value: \(sharedPublisher?.value.description ?? "-")")
        }.store(in: &cancelablesBag)
        
        initialPublisher.send(1)
        sharedPublisher.send(2)
        initialPublisher.send(3)
        initialPublisher.send(completion: .finished)
        initialPublisher.send(4)
        sharedPublisher.send(5)
        sharedPublisher.send(completion: .finished)
        initialPublisher.send(6)
        sharedPublisher.send(7)
    }
}

struct CompletionOfPublishersInCombineLatestSample {
    
    static func execute() {
        var cancelablesBag: Set<AnyCancellable> = []
        let input1 = PassthroughSubject<Int, Never>()
        let input2 = PassthroughSubject<Int, Never>()
        
        Publishers.CombineLatest(input1, input2)
            .map { "(\($0), \($1))"}
            .sink { value in
                print("-> value: \(value)")
            }
            .store(in: &cancelablesBag)
    
        input1.send(1)
        input2.send(2)
        input1.send(completion: .finished)
        input2.send(3)
        input1.send(4)
        input2.send(completion: .finished)
        input1.send(5)
        input2.send(6)
    }
}

struct CompletionOfSharedPublisherSample {
    
    static func execute() {
        var cancelablesBag: Set<AnyCancellable> = []
        let input = PassthroughSubject<Int, Never>()
        let shared = input.share()
        
        shared.sink { value in
            print("-> value: \(value)")
        }
        .store(in: &cancelablesBag)
        
        input.send(1)
        input.send(2)
        input.send(3)
        input.send(completion: .finished)
        input.send(4)
        input.send(5)
        
        shared.sink { value in
            print("-> finished value: \(value)")
        }
        .store(in: &cancelablesBag)
    }
}

struct FormValidationSample {
    
    class UsernameAvailabilityService {
        func usernameAvailable(_ username: String, completion: @escaping (Bool) -> Void) {
            completion(true)
        }
    }
    
    class FormViewModel {
        private let usernameAvailabilityService = UsernameAvailabilityService()
        
        @Published var username: String = ""
        func usernameChanged(_ text: String?) {
            username = text ?? ""
        }
        
        var validatedUsername: AnyPublisher<String?, Never> {
            return $username
            // Ignore debounce for test purposes
//                .debounce(for: 0.5, scheduler: RunLoop.main)
                .removeDuplicates()
                .flatMap { [usernameAvailabilityService] username in
                    return Future { promise in
                        usernameAvailabilityService.usernameAvailable(username) { isAvailable in
                            promise(.success(isAvailable ? username : nil))
                        }
                    }
                }
                .eraseToAnyPublisher()
        }
        
        @Published var password: String = ""
        func passwordChanged(_ text: String?) {
            password = text ?? ""
        }
        
        @Published var repeatPassword: String = ""
        func repeatPasswordChanged(_ text: String?) {
            repeatPassword = text ?? ""
        }
        
        var validatedPassword: AnyPublisher<String?, Never> {
            return Publishers.CombineLatest($password, $repeatPassword)
                .map { password, repeatPassword in
                    guard password == repeatPassword, password.count > 2 else {
                        return nil
                    }
                    return password
                }
                .eraseToAnyPublisher()
        }
        
        var validatedCredentials: AnyPublisher<(String, String)?, Never> {
            return Publishers.CombineLatest(validatedUsername, validatedPassword)
                .map { username, password in
                    guard let username = username, let password = password else {
                        return nil
                    }
                    return (username, password)
                }
                .eraseToAnyPublisher()
        }
    }
    
    class FormView {
        class Button {
            var isEnabled: Bool = false
        }
        
        let signupButton = Button()
        let viewModel = FormViewModel()
        var cancelablesBag: Set<AnyCancellable> = []
        
        func viewDidLoad() {
            viewModel.validatedCredentials
                .map { $0 != nil }
            // Ignore receive on main run loop for test purposes
//                .receive(on: RunLoop.main)
                .assign(to: \.isEnabled, on: signupButton)
                .store(in: &cancelablesBag)
        }
    }
    
    static func execute() {
        let form = FormView()
        form.viewDidLoad()
        
        print("-> signup is possible: \(form.signupButton.isEnabled)")
        
        form.viewModel.usernameChanged("test")
        form.viewModel.passwordChanged("pass")
        form.viewModel.repeatPasswordChanged("pass")
        
        print("-> after form fulfilment, signup is possible: \(form.signupButton.isEnabled)")
    }
}

struct AssignSelfInViewModelSample {
    
    class ViewModel: ObservableObject {
        private var cancellableSet: Set<AnyCancellable> = []
        
        // Input
        @Published var username: String = ""
        
        // Output
        @Published private(set) var isUsernameValid: Bool = false
        
        init() {
            $username
                .map { !$0.isEmpty }
                .sink(receiveValue: { [weak self] in self?.isUsernameValid = $0 })
                .store(in: &cancellableSet)
            
            
        }
        
        deinit {
            print("-> ViewModel deinit...")
        }
    }
    
    static func execute() {
        var viewModel = ViewModel()
        weak var refViewModel = viewModel
        viewModel.username = "abc"
        print("-> username: \(viewModel.username), is valid: \(viewModel.isUsernameValid)")
        viewModel = ViewModel()
        if refViewModel == nil {
            print("-> ViewModel has been released without issues")
        } else {
            print("-> Unable to release ViewModel!")
        }
    }
}


// Test Cases
//SubscribePublisherSample.execute()
//CompletionOfPublishersInCombineLatestSample.execute()
//CompletionOfSharedPublisherSample.execute()
//FormValidationSample.execute()
AssignSelfInViewModelSample.execute()
