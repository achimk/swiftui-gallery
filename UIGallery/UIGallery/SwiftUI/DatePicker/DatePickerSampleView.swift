import SwiftUI
import UIKit

struct UICalendarViewAdapter: UIViewRepresentable {
    @Binding var selection: Date
    var range: ClosedRange<Date>?

    func makeUIView(context: Context) -> UIDatePicker {
        let datePicker = UIDatePicker(frame: .zero)
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.addTarget(context.coordinator, action: #selector(Coordinator.didUpdateDate(for:)), for: .valueChanged)
        return datePicker
    }

    func updateUIView(_ uiView: UIDatePicker, context _: Context) {
        uiView.date = selection
        uiView.minimumDate = range?.lowerBound
        uiView.maximumDate = range?.upperBound
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(selection: $selection)
    }

    final class Coordinator: NSObject {
        @Binding var selection: Date

        init(selection: Binding<Date>) {
            _selection = selection
            super.init()
        }

        @objc
        func didUpdateDate(for datePicker: UIDatePicker) {
            selection = datePicker.date
        }
    }
}

struct DatePickerSampleView: View {
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()

    let range: ClosedRange<Date> = {
        let day: TimeInterval = 86400
        let now = Date()
        let end = now.addingTimeInterval(day * 10)
        return now ... end
    }()

    @State private var date = Date.now
    @State private var showsPicker: Bool = false

    var body: some View {
        ScrollView {
            VStack {
                Text("SwiftUI:")
                DatePicker("", selection: $date, in: range, displayedComponents: .date)
                    .datePickerStyle(.graphical)

                Text("UIKit:")
                UICalendarViewAdapter(selection: $date, range: range)
                    .scaledToFit()

                Text("Date is \(date, formatter: dateFormatter)")
            }
            .padding()
        }
    }
}

struct DatePickerSampleView_Previews: PreviewProvider {
    static var previews: some View {
        DatePickerSampleView()
    }
}
