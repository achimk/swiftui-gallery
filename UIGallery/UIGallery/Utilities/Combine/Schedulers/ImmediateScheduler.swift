import Foundation
import Combine

typealias ImmediateSchedulerOf<Scheduler> = ImmediateScheduler<Scheduler.SchedulerTimeType, Scheduler.SchedulerOptions> where Scheduler: Combine.Scheduler

class ImmediateScheduler<SchedulerTimeType, SchedulerOptions>: Scheduler where SchedulerTimeType: Strideable, SchedulerTimeType.Stride: SchedulerTimeIntervalConvertible {
    let now: SchedulerTimeType
    let minimumTolerance: SchedulerTimeType.Stride = .zero
    
    init(now: SchedulerTimeType) {
        self.now = now
    }
    
    func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
        action()
    }

    func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
        action()
    }
    
    func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
        action()
        return AnyCancellable {}
    }
}
