import UIKit

public struct CurrencyRowViewComponent: Component, SelectableComponent {
    let designLibrary: DesignLibrary
    let image: UIImage?
    let code: String
    let name: String
    let isEnabled: Bool
    let action: () -> Void

    public init(
        designLibrary: DesignLibrary,
        image: UIImage?,
        code: String,
        name: String,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.designLibrary = designLibrary
        self.image = image
        self.code = code
        self.name = name
        self.isEnabled = isEnabled
        self.action = action
    }

    public func makeView() -> CurrencyRowView {
        CurrencyRowView(designLibrary: designLibrary)
    }

    public func render(in view: CurrencyRowView) {
        view.configure(image: image, code: code, name: name, isEnabled: isEnabled)
    }

    public func didSelect() {
        action()
    }

    public func shouldSelect() -> Bool {
        isEnabled
    }
}

public final class CurrencyRowView: UIView {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .lightGray
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = .lightGray
        imageView.clipsToBounds = true
        return imageView
    }()

    let codeLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.required, for: .vertical)
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

    let designLibrary: DesignLibrary

    public init(designLibrary: DesignLibrary) {
        self.designLibrary = designLibrary

        super.init(frame: .zero)

        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(codeLabel)
        stackView.addArrangedSubview(nameLabel)

        self.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 56),
            imageView.heightAnchor.constraint(equalToConstant: 24),
            imageView.widthAnchor.constraint(equalToConstant: 24),
        ])

        codeLabel.textColor = designLibrary.colors.secondaryText
        nameLabel.textColor = designLibrary.colors.regularText
    }

    public func configure(image: UIImage?, code: String, name: String, isEnabled: Bool) {
        imageView.image = image
        codeLabel.text = code
        nameLabel.text = name

        if isEnabled {
            nameLabel.textColor = designLibrary.colors.regularText
            imageView.alpha = 1.0
        } else {
            nameLabel.textColor = designLibrary.colors.secondaryText
            imageView.alpha = 0.5
        }
    }
}
