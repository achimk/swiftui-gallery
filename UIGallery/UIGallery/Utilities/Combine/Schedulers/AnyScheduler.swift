import Combine
import Foundation

typealias AnySchedulerOf<Scheduler> = AnyScheduler<Scheduler.SchedulerTimeType, Scheduler.SchedulerOptions> where Scheduler: Combine.Scheduler

class AnyScheduler<SchedulerTimeType, SchedulerOptions>: Scheduler where SchedulerTimeType: Strideable, SchedulerTimeType.Stride: SchedulerTimeIntervalConvertible {
    private let _minimumTolerance: () -> SchedulerTimeType.Stride
    private let _now: () -> SchedulerTimeType
    private let _scheduleOptionsAction: (SchedulerOptions?, @escaping () -> Void) -> Void
    private let _scheduleAfterToleranceOptionsAction: (
        SchedulerTimeType,
        SchedulerTimeType.Stride,
        SchedulerOptions?,
        @escaping () -> Void
    ) -> Void
    private let _scheduleAfterIntervalToleranceOptionsAction: (
        SchedulerTimeType,
        SchedulerTimeType.Stride,
        SchedulerTimeType.Stride,
        SchedulerOptions?,
        @escaping () -> Void
    ) -> Cancellable
    
    var now: SchedulerTimeType {
        return _now()
    }
    
    var minimumTolerance: SchedulerTimeType.Stride {
        return _minimumTolerance()
    }

    init<S>(_ scheduler: S) where S: Scheduler, S.SchedulerTimeType == SchedulerTimeType, S.SchedulerOptions == SchedulerOptions {
        self._now = { scheduler.now }
        self._minimumTolerance = { scheduler.minimumTolerance }
        self._scheduleOptionsAction = scheduler.schedule
        self._scheduleAfterToleranceOptionsAction = scheduler.schedule
        self._scheduleAfterIntervalToleranceOptionsAction = scheduler.schedule
    }
    
    func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
        _scheduleOptionsAction(options, action)
    }
    
    func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
        _scheduleAfterToleranceOptionsAction(date, tolerance, options, action)
    }
    
    func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
        _scheduleAfterIntervalToleranceOptionsAction(date, interval, tolerance, options, action)
    }
}
