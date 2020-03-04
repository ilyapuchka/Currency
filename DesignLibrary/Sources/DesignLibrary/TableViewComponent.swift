import UIKit

public struct TableViewComponent: Component {
    let adapter: TableViewAdapter

    public init(sections: [[AnyComponent]]) {
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
        let selectedRows = view.indexPathForSelectedRow
        adapter.tableView = view
        adapter.tableView?.reloadData()

        if
            let selectedRow = selectedRows, selectedRow.row != NSNotFound,
            adapter.shouldRestoreSelectionBetweenUpdates(componentAt: selectedRow)
        {
            view.selectRow(at: selectedRow, animated: false, scrollPosition: .none)
        }
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

        let bottom = componentView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        bottom.priority = UILayoutPriority(999)

        NSLayoutConstraint.activate([
            componentView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            componentView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            componentView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            bottom,
        ])
        return componentView
    }
}

public class TableViewAdapter: NSObject, UITableViewDataSource, UITableViewDelegate {
    private(set) var sections: [[AnyComponent]] = []

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

    public func shouldRestoreSelectionBetweenUpdates(componentAt indexPath: IndexPath) -> Bool {
        let component = sections[indexPath.section][indexPath.row]
        return component.shouldPersistSelectionBetweenStateUpdates()
    }

    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let component = sections[indexPath.section][indexPath.row]
        return component.shouldSelect()
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let component = sections[indexPath.section][indexPath.row]
        component.didSelect()
    }

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let component = sections[indexPath.section][indexPath.row]
        if editingStyle == .delete {
            // first delete row "in place" and when animation is done report deletion
            // which will update the state and cause reload
            sections[indexPath.section].remove(at: indexPath.row)

            CATransaction.begin()
            CATransaction.setCompletionBlock {
                component.didDelete()
            }

            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()

            CATransaction.commit()
        }
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
