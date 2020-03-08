import UIKit

public struct AddCurrencyPairViewComponent: Component, SelectableComponent {
    let bundle: Bundle
    let designLibrary: DesignLibrary
    let action: () -> Void
    let isSelected: Bool

    public init(
        bundle: Bundle,
        designLibrary: DesignLibrary,
        isSelected: Bool = false,
        action: @escaping () -> Void
    ) {
        self.bundle = bundle
        self.designLibrary = designLibrary
        self.isSelected = isSelected
        self.action = action
    }

    public func makeView() -> AddCurrencyPairView {
        AddCurrencyPairView(bundle: bundle, designLibrary: designLibrary)
    }

    public func render(in view: AddCurrencyPairView) {
        
    }

    public func didSelect() {
        action()
    }

    public func shouldSelect() -> Bool {
        return true
    }

    public func shouldPersistSelectionBetweenStateUpdates() -> Bool {
        return isSelected
    }
}

public final class AddCurrencyPairView: UIView {
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
        titleLabel.text = NSLocalizedString("add_currency_pair_button_title", bundle: bundle, comment: "")
        imageView.image = designLibrary.assets.plus

        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = titleLabel.text
    }
}
