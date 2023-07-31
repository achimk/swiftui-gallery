import Combine
import Foundation

public typealias AnySchedulerOf<Scheduler> = AnyScheduler<Scheduler.SchedulerTimeType, Scheduler.SchedulerOptions> where Scheduler: Combine.Scheduler

public class AnyScheduler<SchedulerTimeType, SchedulerOptions>: Scheduler where SchedulerTimeType: Strideable, SchedulerTimeType.Stride: SchedulerTimeIntervalConvertible {
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

    public var now: SchedulerTimeType {
        _now()
    }

    public var minimumTolerance: SchedulerTimeType.Stride {
        _minimumTolerance()
    }

    public init<S>(_ scheduler: S) where S: Scheduler, S.SchedulerTimeType == SchedulerTimeType, S.SchedulerOptions == SchedulerOptions {
        _now = { scheduler.now }
        _minimumTolerance = { scheduler.minimumTolerance }
        _scheduleOptionsAction = scheduler.schedule
        _scheduleAfterToleranceOptionsAction = scheduler.schedule
        _scheduleAfterIntervalToleranceOptionsAction = scheduler.schedule
    }

    public func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
        _scheduleOptionsAction(options, action)
    }

    public func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
        _scheduleAfterToleranceOptionsAction(date, tolerance, options, action)
    }

    public func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
        _scheduleAfterIntervalToleranceOptionsAction(date, interval, tolerance, options, action)
    }
}

public extension Scheduler {
    func eraseToAnyScheduler() -> AnyScheduler<SchedulerTimeType, SchedulerOptions> {
        AnyScheduler(self)
    }
}

public extension AnyScheduler where SchedulerTimeType == DispatchQueue.SchedulerTimeType, SchedulerOptions == DispatchQueue.SchedulerOptions {
    static var main: AnyScheduler<SchedulerTimeType, SchedulerOptions> {
        DispatchQueue.main.eraseToAnyScheduler()
    }

    static func global(qos: DispatchQoS.QoSClass = .default) -> AnyScheduler<SchedulerTimeType, SchedulerOptions> {
        DispatchQueue.global(qos: qos).eraseToAnyScheduler()
    }

    static var immediate: AnyScheduler<SchedulerTimeType, SchedulerOptions> {
        ImmediateScheduler(now: .init(.init(uptimeNanoseconds: 1))).eraseToAnyScheduler()
    }
}
