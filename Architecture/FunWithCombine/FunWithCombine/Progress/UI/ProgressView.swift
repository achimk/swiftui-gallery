import SwiftUI

struct ProgressView: View {
    @ObservedObject var viewState: ProgressViewState
    let onStart: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 44) {
                Spacer(minLength: 44)

                Text("Step: \(viewState.step)")
                Text("Duration (sec): \(Int(viewState.stepDuration))")
                Text("State: \(viewState.stateName)")

                Spacer(minLength: 44)

                Button("Start", action: onStart)
                    .disabled(!viewState.canStart)
                Button("Cancel", action: onCancel)
                    .disabled(!viewState.canCancel)
            }
            .padding()
        }
        .navigationTitle("Progress")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProgressView_Previews: PreviewProvider {
    static var viewModel: ProgressViewModel = .init(manager: StepProgressManager(stepHandlerFactory: { request, delegate in
        let handler = StepProgressOperationHandler(request: request)
        handler.delegate = delegate
        return handler
    }), requestProvider: {
        StepProgressRequest(numberOfSteps: 5, stepDuration: 1.0)
    })

    static var previews: some View {
        ProgressView(
            viewState: viewModel.viewState,
            onStart: viewModel.start,
            onCancel: viewModel.cancel
        )
    }
}
