import Foundation

public class WorkScheduler {
    public typealias WorkDispatcher = (DispatchTime, DispatchWorkItem) -> Void
    private typealias Completion = () -> Void

    private let workDispatcher: WorkDispatcher
    private var work: (@escaping Completion) -> Void = { $0() }
    private(set) var isRunning = false

    public static let defaultWorkDispatcher: WorkDispatcher = DispatchQueue.main.asyncAfter(deadline:execute:)

    public init(workDispatcher: @escaping WorkDispatcher = WorkScheduler.defaultWorkDispatcher) {
        self.workDispatcher = workDispatcher
    }

    @discardableResult
    public func schedule(at timeInterval: DispatchTimeInterval, action: @escaping () -> Void) -> Self {
        guard !isRunning else { return self }

        let previousAction = work
        let nextAction: (@escaping Completion) -> Void = { [workDispatcher] completion in
            previousAction {
                workDispatcher(.now() + timeInterval, DispatchWorkItem(block: {
                    action()
                    completion()
                }))
            }
        }

        work = nextAction
        return self
    }

    public func start() {
        guard !isRunning else {
            return
        }

        isRunning = true
        work { [weak self] in
            self?.isRunning = false
        }
    }
}
