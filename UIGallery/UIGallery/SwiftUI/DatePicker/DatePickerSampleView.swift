import SwiftUI

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
                DatePicker("Date picker:", selection: $date, in: range, displayedComponents: .date)
                    .labelsHidden()

                DatePicker("Date picker:", selection: $date, in: range, displayedComponents: .date)

                DatePicker("", selection: $date, in: range, displayedComponents: .date)
                    .datePickerStyle(.graphical)

                DatePicker("", selection: $date, in: range, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)

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
