import Combine
import Foundation

final class TestTimerScheduler {
    private(set) var records: [TimerRecord] = []

    func schedule(
        with timeInterval: TimeInterval,
        callback: @escaping () -> Void
    ) -> Cancellable {
        let record = TimerRecord(
            timeInterval: timeInterval,
            callback: callback
        )
        records.append(record)
        return AnyCancellable {
            record.cancel()
        }
    }

    @discardableResult
    func fire() -> TimerRecord? {
        guard let record = records.first else {
            return nil
        }
        records.remove(at: 0)
        record.run()
        return record
    }
}

extension TestTimerScheduler {
    class TimerRecord {
        private let timeInterval: TimeInterval
        private let callback: () -> Void
        private(set) var isCancelled: Bool = false

        init(
            timeInterval: TimeInterval,
            callback: @escaping () -> Void
        ) {
            self.timeInterval = timeInterval
            self.callback = callback
        }

        func run() {
            if !isCancelled {
                callback()
            }
        }

        func cancel() {
            isCancelled = true
        }
    }
}
