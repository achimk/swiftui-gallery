//

import SwiftUI

struct ProgressSetupView: View {
    @ObservedObject var viewState: ProgressSetupViewState
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Number of steps: \(Int(viewState.numberOfSteps))")
                Slider(
                    value: $viewState.numberOfSteps,
                    in: viewState.numberOfStepsRange,
                    step: 1.0,
                    label: { Text("") },
                    minimumValueLabel: { Text("\(Int(viewState.numberOfStepsRange.lowerBound))") },
                    maximumValueLabel: { Text("\(Int(viewState.numberOfStepsRange.upperBound))") }
                )

                Spacer(minLength: 44)

                Text("Duration (sec): \(Int(viewState.stepDuration))")
                Slider(
                    value: $viewState.stepDuration,
                    in: viewState.stepDurationRange,
                    step: 1.0,
                    label: { Text("") },
                    minimumValueLabel: { Text("\(Int(viewState.stepDurationRange.lowerBound))") },
                    maximumValueLabel: { Text("\(Int(viewState.stepDurationRange.upperBound))") }
                )
            }
            .padding()
        }
        .navigationTitle("Setup")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProgressSetupView_Previews: PreviewProvider {
    static let viewModel: ProgressSetupViewModel = {
        let viewModel = ProgressSetupViewModel()
        viewModel.viewState.numberOfSteps = 5.0
        viewModel.viewState.stepDuration = 3.0
        return viewModel
    }()

    static var previews: some View {
        ProgressSetupView(viewState: viewModel.viewState)
    }
}
