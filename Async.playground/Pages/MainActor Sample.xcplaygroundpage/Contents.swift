import _Concurrency
import Foundation
import PlaygroundSupport

typealias Seconds = UInt64

func currentThread() -> Thread {
    Thread.current
}

func nanosecondsInOneSecond() -> UInt64 {
    NSEC_PER_SEC
}

func logCurrentThread(message: String? = nil) {
    log(currentThread(), message: message)
}

func log(_ thread: Thread, message: String? = nil) {
    let formatted = (message.flatMap { $0 + "\n" }) ?? ""
    print("\(formatted)Thread", thread, "is main:", thread.isMainThread)
}

func logIfChanged(_ current: Thread, message: String? = nil) {
    if current != Thread.current {
        let formatted = (message.flatMap { $0 + "\n" }) ?? ""
        print("\(formatted)Thread changed from", current, "to", Thread.current, "is main:", Thread.current.isMainThread)
    }
}

// MARK: - Tests

func testImmediate() async {
    print("Immediate:")
    let current = currentThread()
    log(current)
}

@MainActor
func testImmediatedMain() async {
    print("Immediate main:")
    let current = currentThread()
    log(current)
}

func testSleep(seconds: Seconds = 1) async {
    print("Sleep:")
    let current = currentThread()
    log(current)
    try? await Task.sleep(nanoseconds: seconds * NSEC_PER_SEC)
    logIfChanged(current)
}

// MARK: - Repository

struct User: Identifiable {
    let id: UUID
    let name: String
    let surname: String
    let address: Address

    static func stub() -> User {
        let address = Address(
            street: "Street 1",
            city: "City",
            postCode: "00-000",
            country: "PL"
        )
        return User(
            id: UUID(),
            name: "Adam",
            surname: "Adam",
            address: address
        )
    }
}

struct Address {
    let street: String
    let city: String
    let postCode: String
    let country: String
}

protocol UserRepository {
    func findUser() async -> User
}

struct MainThreadUserRepository: UserRepository {
    @MainActor
    func findUser() async -> User {
        logCurrentThread(message: "Main repository:")
        return User.stub()
    }
}

struct BackgroundThreadUserRepository: UserRepository {
    func findUser() async -> User {
        logCurrentThread(message: "Background repository:")
        return User.stub()
    }
}

protocol LoadUserDetailsHandling {
    func load() async -> User
}

struct LoadUserDetailsUseCase: LoadUserDetailsHandling {
    let repository: UserRepository

    @MainActor
    func load() async -> User {
        logCurrentThread(message: "UseCase:")
        return await repository.findUser()
    }
}

protocol FindAllUsersHandling {
    func findAll() async -> [User]
}

struct FindAllUsersUseCase: FindAllUsersHandling {
    let mainRepository: UserRepository
    let backgroundRepository: UserRepository

    @MainActor
    func findAll() async -> [User] {
        logCurrentThread(message: "1. UseCase:")
        let user1 = await mainRepository.findUser()
        logCurrentThread(message: "2. UseCase:")
        let user2 = await backgroundRepository.findUser()
        logCurrentThread(message: "3. UseCase:")
        let user3 = await mainRepository.findUser()
        logCurrentThread(message: "4. UseCase:")
        let user4 = await backgroundRepository.findUser()
        logCurrentThread(message: "5. UseCase:")
        return [user1, user2, user3, user4]
    }
}

@MainActor
func testMainThreadRepository() async {
    logCurrentThread(message: "testMainThreadRepository:")
    let repository: UserRepository = MainThreadUserRepository()
    let useCase: LoadUserDetailsHandling = LoadUserDetailsUseCase(repository: repository)
    let user = await useCase.load()
    print("Result:", user)
}

func testBackgroundThreadRepository() async {
    logCurrentThread(message: "testBackgroundThreadRepository:")
    let repository: UserRepository = BackgroundThreadUserRepository()
    let useCase: LoadUserDetailsHandling = LoadUserDetailsUseCase(repository: repository)
    let user = await useCase.load()
    print("Result:", user)
}

@MainActor
func testFindAllUsers() async {
    let useCase: FindAllUsersHandling = FindAllUsersUseCase(
        mainRepository: MainThreadUserRepository(),
        backgroundRepository: BackgroundThreadUserRepository()
    )
    let results = await useCase.findAll()
    print("Results:", results.count)
}

// MARK: - Run

Task { @MainActor in
//    await testImmediate()
//    await testImmediatedMain()
//    await testSleep()
//    await testMainThreadRepository()
//    await testBackgroundThreadRepository()
    await testFindAllUsers()

    print("done")
    PlaygroundPage.current.finishExecution()
}

PlaygroundPage.current.needsIndefiniteExecution = true
