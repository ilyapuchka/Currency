import UIKit
import DesignLibrary

public class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.item == 0 {
            let cell = UITableViewCell.init(style: .default, reuseIdentifier: "add_button")
            let row = AddCurrencyPairButton(bundle: bundle, designLibrary: designLibrary)

            row.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(row)
            NSLayoutConstraint.activate([
                row.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor),
                row.leadingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.leadingAnchor),
                row.bottomAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.bottomAnchor),
                row.topAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.topAnchor),
            ])

            return cell
        } else {
            let cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
            let row = CurrencyRowView(designLibrary: designLibrary)
            row.configure(image: UIImage(named: "EUR", in: bundle, compatibleWith: nil)!, code: "AAA", name: "very very long name very very long name very very long name very very long name very very long name very very long name very very long name very very long name very very long name very very long name very very long name ")

            row.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(row)
            NSLayoutConstraint.activate([
                row.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor),
                row.leadingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.leadingAnchor),
                row.bottomAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.bottomAnchor),
                row.topAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.topAnchor),
            ])

            return cell        }
    }

    let tableView = UITableView()
    let bundle: Bundle
    let designLibrary: DesignLibrary

    public init(bundle: Bundle, designLibrary: DesignLibrary) {
        self.bundle = bundle
        self.designLibrary = designLibrary
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder, bundle: Bundle, designLibrary: DesignLibrary) {
        self.bundle = bundle
        self.designLibrary = designLibrary
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue

        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        tableView.separatorColor = .clear

        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 56
        tableView.rowHeight = UITableView.automaticDimension
        view.addSubview(tableView)
    }
}
