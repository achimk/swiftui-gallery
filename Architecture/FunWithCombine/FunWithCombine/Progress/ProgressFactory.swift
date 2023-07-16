import Foundation
import SwiftUI

struct ProgressFactory {
    static func make() -> ContentDestinationView<ProgressView, ProgressSetupView, Image> {
        let setupViewModel = ProgressSetupViewModel()
        let viewModel = ProgressViewModel(requestProvider: setupViewModel.toProgressRequest)

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
}
