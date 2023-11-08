import Combine
import Foundation

enum XXPagingState<Data> {
    enum Request {
        case load
        case loadMore
    }

    case initial
    case loading(Request)
    case success(Request, Data)
    case failure(Request, Error)
}

enum XXPageOffset {
    case available(UInt)
    case completed
}
