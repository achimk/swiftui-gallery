import Combine

struct ConcatenateSample {
    
    static func execute() {
        var cancellables: Set<AnyCancellable> = []
        let loading = PassthroughSubject<Int, Never>()
        let finished = PassthroughSubject<Int, Never>()
        let concat = Publishers.Concatenate(prefix: loading, suffix: finished)
        
        concat.sink { value in
            print("-> value: \(value)")
        }
        .store(in: &cancellables)
        
        
        loading.send(1)
        loading.send(2)
        loading.send(3)
        loading.send(completion: .finished)
        
        finished.send(4)
        finished.send(completion: .finished)
        
    }
}

ConcatenateSample.execute()
