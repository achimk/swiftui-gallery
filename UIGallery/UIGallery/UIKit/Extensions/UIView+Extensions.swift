#if canImport(UIKit)
    import UIKit

    public extension UIView {
        typealias Anchors = (
            top: NSLayoutConstraint,
            leading: NSLayoutConstraint,
            bottom: NSLayoutConstraint,
            trailing: NSLayoutConstraint
        )

        @discardableResult
        func addAndFill(_ subview: UIView, insets: UIEdgeInsets = .zero) -> Anchors {
            subview.translatesAutoresizingMaskIntoConstraints = false

            addSubview(subview)

            let anchors: Anchors
            anchors.top = subview.topAnchor.constraint(equalTo: topAnchor, constant: insets.top)
            anchors.leading = subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left)
            anchors.bottom = subview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: insets.bottom)
            anchors.trailing = subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: insets.right)

            NSLayoutConstraint.activate([
                anchors.top,
                anchors.leading,
                anchors.bottom,
                anchors.trailing,
            ])

            return anchors
        }
    }
#endif
