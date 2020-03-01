import UIKit

public struct AddCurrencyPairButtonComponent: Component {
    let bundle: Bundle
    let designLibrary: DesignLibrary

    public init(bundle: Bundle, designLibrary: DesignLibrary) {
        self.bundle = bundle
        self.designLibrary = designLibrary
    }

    public func makeView() -> AddCurrencyPairButton {
        AddCurrencyPairButton(bundle: bundle, designLibrary: designLibrary)
    }

    public func render(in view: AddCurrencyPairButton) {

    }
}

public final class AddCurrencyPairButton: UIView {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(bundle: Bundle, designLibrary: DesignLibrary) {
        super.init(frame: .zero)

        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)

        self.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 56),
            imageView.heightAnchor.constraint(equalToConstant: 40),
            imageView.widthAnchor.constraint(equalToConstant: 40)
        ])

        titleLabel.textColor = designLibrary.colors.cta
        titleLabel.text = NSLocalizedString("add_currency_pair_button_title", tableName: nil, bundle: bundle, comment: "")
        imageView.image = UIImage(named: "plus", in: bundle, compatibleWith: nil)!
    }
}
