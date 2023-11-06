import SwiftUI

struct TransactionRowView: View {
    let title: String
    let color: Color

    init(transaction: Transaction) {
        title = transaction.name
        color = transaction.category.color
    }

    init(title: String, color: Color) {
        self.title = title
        self.color = color
    }

    var body: some View {
        HStack(alignment: .center) {
            TransactionColorView(color: color)
            Text(title)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.vertical, 24.0)
    }
}

struct TransactionRowView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionRowView(title: "Transaction", color: .pink)
    }
}
