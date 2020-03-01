import UIKit

public struct CurrencyRowViewComponent: Component {
    let designLibrary: DesignLibrary
    let image: UIImage
    let code: String
    let name: String

    public init(
        designLibrary: DesignLibrary,
        image: UIImage,
        code: String,
        name: String
    ) {
        self.designLibrary = designLibrary
        self.image = image
        self.code = code
        self.name = name
    }

    public func makeView() -> CurrencyRowView {
        CurrencyRowView(designLibrary: designLibrary)
    }

    public func render(in view: CurrencyRowView) {
        view.configure(image: image, code: code, name: name)
    }
}

public final class CurrencyRowView: UIView {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
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

    public init(designLibrary: DesignLibrary) {
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

    public func configure(image: UIImage, code: String, name: String) {
        imageView.image = image
        codeLabel.text = code
        nameLabel.text = name
    }
}
