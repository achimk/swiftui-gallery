import Foundation

enum PageRequest {
    case load
    case loadMore
}

enum PagingState<Data> {
    case initial
    case loading(PageRequest)
    case success(PageRequest, Data)
    case failure(PageRequest, Error)

    var data: Data? {
        if case let .success(_, data) = self {
            return data
        }
        return nil
    }

    var error: Error? {
        if case let .failure(_, error) = self {
            return error
        }
        return nil
    }

    var pageRequest: PageRequest? {
        switch self {
        case .initial: return nil
        case let .loading(request): return request
        case let .success(request, _): return request
        case let .failure(request, _): return request
        }
    }

    func toPagingActivityStatus() -> PagingActivityStatus {
        switch self {
        case .initial: return .initial
        case .loading: return .loading
        case .success: return .success
        case .failure: return .failure
        }
    }
}

enum PagingActivityStatus: Equatable {
    case initial
    case loading
    case success
    case failure
}
