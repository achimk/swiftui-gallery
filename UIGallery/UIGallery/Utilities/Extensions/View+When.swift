import SwiftUI

extension View {
    @ViewBuilder
    func when(_ condition: @autoclosure () -> Bool, @ViewBuilder contentBuilder: (Self) -> some View) -> some View {
        if condition() {
            contentBuilder(self)
        } else {
            self
        }
    }
}
