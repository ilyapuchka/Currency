#if canImport(SwiftUI) && DEBUG
import SwiftUI
import ConverterFeature

@available(iOS 13.0, *)
struct UIViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
    let viewController: ViewController

    init(_ builder: @escaping () -> ViewController) {
        viewController = builder()
    }

    // MARK: - UIViewControllerRepresentable
    func makeUIViewController(context: Context) -> ViewController {
        viewController
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {

    }
}

@available(iOS 13.0, *)
struct ViewController_Preview: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreview {
            UIStoryboard(name: "Preview", bundle: nil)
                .instantiateInitialViewController { coder in
                    let vc = ViewController(coder: coder)!
                    return vc
                }!
        }
    }
}
#endif
