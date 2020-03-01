import UIKit
import DesignLibrary

class ComponentCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
        self.selectedBackgroundView = selectedBackgroundView
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func mount(component: AnyComponent) -> UIView {
        let componentView = component.makeView()
        componentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(componentView)
        NSLayoutConstraint.activate([
            componentView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            componentView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            componentView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            componentView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
        ])
        return componentView
    }
}

public class TableViewAdapter: NSObject, UITableViewDataSource, UITableViewDelegate {
    private var sections: [[AnyComponent]] = []

    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let component = sections[indexPath.section][indexPath.row]
        let reuseIdentifier = String(reflecting: component.componentType)

        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? ComponentCell else {
            tableView.register(ComponentCell.self, forCellReuseIdentifier: reuseIdentifier)
            return self.tableView(tableView, cellForRowAt: indexPath)
        }
        component.render(in: cell.mount(component: component))
        return cell
    }

    let tableView: UITableView

    public init(with tableView: UITableView) {
        self.tableView = tableView
        super.init()
        tableView.delegate = self
        tableView.dataSource = self
    }

    public func update(sections: [[AnyComponent]]) {
        self.sections = sections
        tableView.reloadData()
    }
}


public class TableViewController: UIViewController {
    let tableView = UITableView()
    lazy var adapter = TableViewAdapter(with: tableView)

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public func update(sections: [[AnyComponent]]) {
        self.adapter.update(sections: sections)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        tableView.separatorColor = .clear

        tableView.estimatedRowHeight = 56
        tableView.rowHeight = UITableView.automaticDimension

        view.addSubview(tableView)
    }
}
