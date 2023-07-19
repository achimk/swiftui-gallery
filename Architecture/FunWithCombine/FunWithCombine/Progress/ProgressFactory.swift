import Foundation
import SwiftUI

struct ProgressFactory {
    enum Strategy {
        case operation
        case asyncTask
    }

    let strategy: Strategy

    func make() -> ContentDestinationView<ProgressView, ProgressSetupView, Image> {
        let manager = makeManager(for: strategy)
        let setupViewModel = ProgressSetupViewModel()
        let viewModel = ProgressViewModel(
            manager: manager,
            requestProvider: setupViewModel.toProgressRequest
        )

        return ContentDestinationView(
            content: {
                ProgressView(
                    viewState: viewModel.viewState,
                    onStart: viewModel.start,
                    onCancel: viewModel.cancel
                )
            }, destination: {
                ProgressSetupView(
                    viewState: setupViewModel.viewState
                )
            }, label: {
                Image(systemName: "gearshape")
            }
        )
    }

    private func makeManager(for strategy: Strategy) -> StepProgressManager {
        StepProgressManager { request, delegate in
            switch strategy {
            case .operation:
                let handler = StepProgressOperationHandler(request: request)
                handler.delegate = delegate
                return handler
            case .asyncTask:
                let handler = StepProgressTaskHandler(request: request)
                handler.delegate = delegate
                return handler
            }
        }
    }
}
