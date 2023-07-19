import Foundation

typealias TimerInvalidate = () -> Void
typealias TimerScheduler = (TimeInterval, @escaping () -> Void) -> TimerInvalidate

final class ProgressTimer {
    private var timer: Timer?

    deinit {
        invalidate()
    }

    func schedule(with timeInterval: TimeInterval, block: @escaping () -> Void) {
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { _ in block() }
    }

    func invalidate() {
        timer?.invalidate()
        timer = nil
    }
}

extension ProgressTimer {
    static func schedule(with timeInterval: TimeInterval, block: @escaping () -> Void) -> TimerInvalidate {
        let timer = ProgressTimer()
        timer.schedule(with: timeInterval, block: block)
        return timer.invalidate
    }
}
