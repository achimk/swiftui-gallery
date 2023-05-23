import Foundation

extension AnyScheduler where SchedulerTimeType == DispatchQueue.SchedulerTimeType, SchedulerOptions == DispatchQueue.SchedulerOptions {
    
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
