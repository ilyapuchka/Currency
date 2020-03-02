import UIKit
import DesignLibrary

public struct TableViewComponent: Component {
    let adapter: TableViewAdapter

    init(sections: [[AnyComponent]]) {
        self.adapter = TableViewAdapter(sections: sections)
    }

    public func makeView() -> UITableView {
        let tableView = UITableView()
        tableView.separatorColor = .clear
        tableView.estimatedRowHeight = 56
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }

    public func render(in view: UITableView) {
        adapter.tableView = view
        adapter.tableView?.reloadData()
    }
}

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
        if let componentView = contentView.subviews.first, type(of: componentView) == component.viewType {
            return componentView
        }

        contentView.subviews.first?.removeFromSuperview()
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

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let component = sections[indexPath.section][indexPath.row]
        component.didSelect()
    }

    var tableView: UITableView? {
        didSet {
            tableView?.delegate = self
            tableView?.dataSource = self
        }
    }

    public init(sections: [[AnyComponent]]) {
        self.sections = sections
        super.init()
    }
}
