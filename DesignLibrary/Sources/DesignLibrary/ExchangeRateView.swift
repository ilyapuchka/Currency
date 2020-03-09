import UIKit

public struct ExchangeRateViewComponent: Component, DeletableComponent {
    let designLibrary: DesignLibrary
    let from: (amount: String, description: String)
    let to: (amount: String, description: String)
    let accessibilityLabel: String

    let onDelete: () -> Void
    let onRateUpdate: ExchangeRateView.OnRateUpdate

    public init(
        designLibrary: DesignLibrary,
        from: (amount: String, description: String),
        to: (amount: String, description: String),
        accessibilityLabel: String,
        onDelete: @escaping () -> Void,
        onRateUpdate: @escaping ExchangeRateView.OnRateUpdate
    ) {
        self.designLibrary = designLibrary
        self.from = from
        self.to = to
        self.accessibilityLabel = accessibilityLabel
        self.onDelete = onDelete
        self.onRateUpdate = onRateUpdate
    }

    public func makeView() -> ExchangeRateView {
        ExchangeRateView(designLibrary: designLibrary)
    }

    public func render(in view: ExchangeRateView) {
        view.configure(
            from: from,
            to: to,
            accessibilityLabel: accessibilityLabel,
            onRateUpdate: onRateUpdate
        )
    }

    public func didDelete() {
        onDelete()
    }
}

public final class ExchangeRateView: UIView {

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
        label.textAlignment = ExchangeRateView.fromLabelTextAlignment
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let fromDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textAlignment = ExchangeRateView.fromLabelTextAlignment
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let toAmountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.textAlignment = ExchangeRateView.toLabelTextAlignment
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let toDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textAlignment = ExchangeRateView.toLabelTextAlignment
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 8
        return stackView
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(designLibrary: DesignLibrary) {
        super.init(frame: .zero)

        let fromStackView = UIStackView(arrangedSubviews: [
            fromAmountLabel, fromDescriptionLabel
        ])
        fromStackView.axis = .vertical

        let toStackView = UIStackView(arrangedSubviews: [
            toAmountLabel, toDescriptionLabel
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

        fromDescriptionLabel.textColor = designLibrary.colors.secondaryText
        toDescriptionLabel.textColor = designLibrary.colors.secondaryText

        isAccessibilityElement = true
        accessibilityTraits = .updatesFrequently
    }

    public typealias OnRateUpdate = (@escaping (String, String) -> Void) -> Void

    public func configure(
        from: (amount: String, description: String),
        to: (amount: String, description: String),
        accessibilityLabel: String,
        onRateUpdate: OnRateUpdate
    ) {
        fromAmountLabel.text = from.amount
        fromDescriptionLabel.text = from.description
        toAmountLabel.text = to.amount
        toDescriptionLabel.text = to.description
        self.accessibilityLabel = accessibilityLabel

        onRateUpdate { [weak self] rate, accessibilityLabel in
            self?.toAmountLabel.text = rate
            self?.accessibilityLabel = accessibilityLabel
        }
    }
}
