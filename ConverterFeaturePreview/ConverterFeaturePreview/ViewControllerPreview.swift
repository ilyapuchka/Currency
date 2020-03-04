#if canImport(SwiftUI) && DEBUG
import SwiftUI
import ConverterFeature
import DesignLibrary

struct StubViewModel: RootViewModelProtocol {
    typealias State = RootState
    typealias UserAction = RootEvent.UserAction

    func sendAction(_ action: RootEvent.UserAction) {
    }

    func observeState(_ observer: @escaping (RootState) -> Void) {
    }
}

@available(iOS 13.0, *)
class ViewController_Preview: PreviewProvider {
  static var previews: some View {
      UIViewControllerPreview {
        UIStoryboard(name: "Preview", bundle: Bundle.init(for: Self.self))
            .instantiateInitialViewController { coder in
                let bundle = Bundle(for: Self.self)
                let designLibrary = DesignLibrary(bundle: bundle)

                let vc = RootViewController(
                    coder: coder,
                    viewModel: StubViewModel(),
                    config: RootViewController.Config.init(bundle: bundle, designLibrary: designLibrary)
                    )!

                let state = RootState.init(rates: [
                ], pairs: [
                ], status: .isLoaded,
                   observeUpdates: { _ in { _, _ in } })
                vc.render(state: state, sendAction: { _ in })
//                vc.update(sections: [
//                    [
//                        AddCurrencyPairButtonComponent(bundle: bundle, designLibrary: designLibrary).asAnyComponent(),
//                        CurrencyRowViewComponent(
//                            designLibrary: designLibrary,
//                            image: UIImage(named: "EUR", in: bundle, compatibleWith: nil)!,
//                            code: "EUR",
//                            name: "Euro").asAnyComponent()
//                    ]
//                ])
                return vc
        }!
      }.previewLayout(.sizeThatFits)
  }
}
#endif
