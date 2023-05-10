import Combine
import Foundation

// Utils

enum AnyError: Swift.Error {
    case withInfo(String)
    case generic(Error)
    case unknown
}

@discardableResult
func handle<T, E: Error>(_ anyPublisher: AnyPublisher<T, E>, title: String = "") -> Cancellable {
    print("Create sink: \(title)")
    return anyPublisher.sink { completion in
        switch completion {
        case .finished:
            print("-> finished")
        case .failure(let error):
            print("-> failure: \(error)")
        }
    } receiveValue: { value in
        print("-> value: \(value)")
    }
}

// Types Scenarios

struct TypesScenarios {
    
    func makePassthroughSubject() -> PassthroughSubject<Int, Error> {
        return PassthroughSubject()
    }
    
    func makeCurrentValueSubject(value: Int = 0) -> CurrentValueSubject<Int, Error> {
        return CurrentValueSubject(value)
    }
    
    func makeFuture(result: Result<Int, Error> = .success(1)) -> Future<Int, Error> {
        return Future { promise in
            promise(result)
        }
    }
}


var cancellables: Set<AnyCancellable> = []
let typesScenarios = TypesScenarios()

let passthroughSubject = typesScenarios.makePassthroughSubject()
handle(passthroughSubject.eraseToAnyPublisher()).store(in: &cancellables)
passthroughSubject.send(1)
passthroughSubject.send(2)
passthroughSubject.send(3)
passthroughSubject.send(completion: .failure(AnyError.unknown))
passthroughSubject.send(4)

let currentValueSubject = typesScenarios.makeCurrentValueSubject()
handle(currentValueSubject.eraseToAnyPublisher(), title: "CurrentValueSubject").store(in: &cancellables)
currentValueSubject.send(1)
currentValueSubject.send(2)
currentValueSubject.send(3)
currentValueSubject.send(completion: .finished)
currentValueSubject.send(4)

handle(typesScenarios.makeFuture().eraseToAnyPublisher())
handle(typesScenarios.makeFuture(result: .failure(AnyError.unknown)).eraseToAnyPublisher())


