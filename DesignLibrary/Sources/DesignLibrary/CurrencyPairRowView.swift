import UIKit

public struct CurrencyPairRowViewComponent: Component {
    let designLibrary: DesignLibrary
    let from: (amount: String, name: String)
    let to: (amount: String, name: String)

    public init(
        designLibrary: DesignLibrary,
        from: (amount: String, name: String),
        to: (amount: String, name: String)
    ) {
        self.designLibrary = designLibrary
        self.from = from
        self.to = to
    }
    public func makeView() -> CurrencyPairRowView {
        CurrencyPairRowView(designLibrary: designLibrary)
    }

    public func render(in view: CurrencyPairRowView) {
        view.configure(from: from, to: to)
    }
}

public final class CurrencyPairRowView: UIView {

    let fromAmountLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let fromNameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let toAmountLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let toNameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textAlignment = .right
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

    public func configure(
        from: (amount: String, name: String), to: (amount: String, name: String)
    ) {
        fromAmountLabel.text = from.amount
        fromNameLabel.text = from.name
        toAmountLabel.text = to.amount
        toNameLabel.text = to.name
    }
}
