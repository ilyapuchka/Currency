import UIKit

public struct EmptyStateViewComponent: Component {
    let bundle: Bundle
    let designLibrary: DesignLibrary
    let action: () -> Void

    public init(bundle: Bundle, designLibrary: DesignLibrary, action: @escaping () -> Void) {
        self.bundle = bundle
        self.designLibrary = designLibrary
        self.action = action
    }
    
    public func makeView() -> EmptyStateView {
        EmptyStateView(bundle: bundle, designLibrary: designLibrary)
    }

    public func render(in view: EmptyStateView) {
        view.action = action
    }
}

public final class EmptyStateView: UIView {
    let button: VerticalContentButton = {
        let button = VerticalContentButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 8
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 8,
            leading: 8,
            bottom: 8,
            trailing: 8
        )
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.setContentCompressionResistancePriority(.required, for: .vertical)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(bundle: Bundle, designLibrary: DesignLibrary) {
        super.init(frame: .zero)

        stackView.addArrangedSubview(button)
        stackView.addArrangedSubview(subtitleLabel)

        self.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
        ])

        button.button.titleLabel?.textColor = designLibrary.colors.cta
        button.button.setTitle(NSLocalizedString("add_currency_pair_button_title", tableName: nil, bundle: bundle, comment: ""), for: .normal)
        button.button.setTitleColor(designLibrary.colors.cta, for: .normal)
        button.button.setTitleColor(designLibrary.colors.cta.withAlphaComponent(0.5), for: .highlighted)
        button.button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

        button.imageView.image = UIImage(named: "plus", in: bundle, compatibleWith: nil)!

        subtitleLabel.text = NSLocalizedString("add_currency_pair_button_subtitle", tableName: nil, bundle: bundle, comment: "")
        subtitleLabel.textColor = designLibrary.colors.secondaryText
    }

    var action: () -> Void = {}

    @objc func buttonTapped() {
        action()
    }
}

final class VerticalContentButton: UIView {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let button: UIButton = {
        let button = UIButton()
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        button.setContentHuggingPriority(.required, for: .vertical)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 8
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)

        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(button)

        self.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 60),
            imageView.widthAnchor.constraint(equalToConstant: 60)
        ])

        let tapRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(tappedImage(_:)))
        tapRecognizer.minimumPressDuration = 0
        imageView.addGestureRecognizer(tapRecognizer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func tappedImage(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if case .began = gestureRecognizer.state {
            button.isHighlighted = true
        } else {
            if case .ended = gestureRecognizer.state {
                button.isHighlighted = false
                if stackView.bounds.contains(gestureRecognizer.location(in: stackView)) {
                    button.sendActions(for: .touchUpInside)
                }
            }
        }
    }
}
