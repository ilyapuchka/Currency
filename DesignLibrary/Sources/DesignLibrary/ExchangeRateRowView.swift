import UIKit

public struct ExchangeRateRowViewComponent: Component, DeletableComponent {
    let designLibrary: DesignLibrary
    let from: (amount: String, name: String)
    let to: (amount: String, name: String)
    let onDelete: () -> Void
    let onUpdate: (@escaping (String) -> Void) -> Void

    public init(
        designLibrary: DesignLibrary,
        from: (amount: String, name: String),
        to: (amount: String, name: String),
        onDelete: @escaping () -> Void,
        onUpdate: @escaping (@escaping (String) -> Void) -> Void
    ) {
        self.designLibrary = designLibrary
        self.from = from
        self.to = to
        self.onDelete = onDelete
        self.onUpdate = onUpdate
    }

    public func makeView() -> ExchangeRateRowView {
        ExchangeRateRowView(designLibrary: designLibrary)
    }

    public func render(in view: ExchangeRateRowView) {
        view.configure(from: from, to: to, onUpdate: onUpdate)
    }

    public func shouldDelete() -> Bool {
        return true
    }

    public func didDelete() {
        onDelete()
    }
}

public final class ExchangeRateRowView: UIView {

    static var fromLabelTextAlignment: NSTextAlignment {
        UIView.userInterfaceLayoutDirection(for: .unspecified) == .leftToRight
            ? .left
            : .right
    }

    static var toLabelTextAlignment: NSTextAlignment {
        UIView.userInterfaceLayoutDirection(for: .unspecified) == .leftToRight
            ? .right
            : .left
    }

    let fromAmountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.textAlignment = ExchangeRateRowView.fromLabelTextAlignment
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let fromNameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textAlignment = ExchangeRateRowView.fromLabelTextAlignment
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let toAmountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.textAlignment = ExchangeRateRowView.toLabelTextAlignment
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let toNameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textAlignment = ExchangeRateRowView.toLabelTextAlignment
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(designLibrary: DesignLibrary) {
        super.init(frame: .zero)

        let fromStackView = UIStackView(arrangedSubviews: [
            fromAmountLabel, fromNameLabel
        ])
        fromStackView.axis = .vertical

        let toStackView = UIStackView(arrangedSubviews: [
            toAmountLabel, toNameLabel
        ])
        toStackView.axis = .vertical

        stackView.addArrangedSubview(fromStackView)
        stackView.addArrangedSubview(toStackView)

        self.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 56)
        ])

        fromAmountLabel.textColor = designLibrary.colors.regularText
        toAmountLabel.textColor = designLibrary.colors.regularText

        fromNameLabel.textColor = designLibrary.colors.secondaryText
        toNameLabel.textColor = designLibrary.colors.secondaryText
    }

    var onUpdate: (String) -> Void = { _ in }

    public func configure(
        from: (amount: String, name: String),
        to: (amount: String, name: String),
        onUpdate: (@escaping (String) -> Void) -> Void
    ) {
        fromAmountLabel.text = from.amount
        fromNameLabel.text = from.name
        toAmountLabel.text = to.amount
        toNameLabel.text = to.name

        onUpdate { [weak self] rate in
            self?.toAmountLabel.text = rate
        }
    }
}
