import Combine
import Foundation

public typealias ImmediateSchedulerOf<Scheduler> = ImmediateScheduler<Scheduler.SchedulerTimeType, Scheduler.SchedulerOptions> where Scheduler: Combine.Scheduler

public class ImmediateScheduler<SchedulerTimeType, SchedulerOptions>: Scheduler where SchedulerTimeType: Strideable, SchedulerTimeType.Stride: SchedulerTimeIntervalConvertible {
    public let now: SchedulerTimeType
    public let minimumTolerance: SchedulerTimeType.Stride = .zero

    public init(now: SchedulerTimeType) {
        self.now = now
    }

    public func schedule(options _: SchedulerOptions?, _ action: @escaping () -> Void) {
        action()
    }

    public func schedule(after _: SchedulerTimeType, tolerance _: SchedulerTimeType.Stride, options _: SchedulerOptions?, _ action: @escaping () -> Void) {
        action()
    }

    public func schedule(after _: SchedulerTimeType, interval _: SchedulerTimeType.Stride, tolerance _: SchedulerTimeType.Stride, options _: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
        action()
        return AnyCancellable {}
    }
}
