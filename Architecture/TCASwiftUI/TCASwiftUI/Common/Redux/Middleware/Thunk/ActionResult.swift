import Combine
import Foundation

enum ActionResult {
    case accepted(Cancellable)
    case rejected
}
