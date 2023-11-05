import Foundation

protocol ThunkAction: Identifiable, Action {
    associatedtype State
    func handle(dispatch: @escaping ActionDispatch, getState: @escaping () -> State) -> ActionResult
}

extension ThunkAction {
    var id: String {
        return String(describing: Self.self)
    }
}

//func makeThunkMiddleware<State>() -> Middleware<State> {
//    return { dispatch, getState in
//        return { next in
//            return { action in
//                switch action {
//                case let thunk as Thunk<State>:
//                    thunk.body(dispatch, getState)
//                default:
//                    next(action)
//                }
//            }
//        }
//    }
//}
