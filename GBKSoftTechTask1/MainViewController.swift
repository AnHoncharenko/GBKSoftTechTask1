//
//  MainViewController.swift
//  GBKSoftTechTask1
//
//  Created by Anton Honcharenko on 19.11.2020.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var data: [StoredContactsItem] = []
    var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Contacts"
        fetchData()
        refreshControl.attributedTitle = NSAttributedString(string: "Refresh")
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.addSubview(refreshControl)
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "ContactCell", bundle: .main)
        tableView.register(nib, forCellReuseIdentifier: "ContactCell")
        let rightBarItem = UIBarButtonItem(title: "remove all", style: .done, target: self, action: #selector(removeAll))
        navigationItem.rightBarButtonItem = rightBarItem
        let leftBarItem = UIBarButtonItem(title: "Load", style: .done, target: self, action: #selector(fetchData))
        navigationItem.leftBarButtonItem = leftBarItem
        NotificationCenter.default.addObserver(self, selector: #selector(fetchData), name: .contactDidEdited, object: nil)
    }

    @objc func removeAll() {
        StoredContacts.shared.clear()
        data.removeAll()
        tableView.reloadData()
    }

    @objc func refreshData() {
        StoredContacts.shared.clear()
        fetchData()
    }
    
    @objc func fetchData() {
        StoredContacts.shared.all(completion: {
            self.data = $0 ?? []
            if self.data.isEmpty {
                StoredContacts.shared.loadContacts().done({
                    self.fetchData()
                })
            }
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
        })
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactCell
        cell.setInfo(model: data[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let removeContact = data[indexPath.row]
            StoredContacts.shared.clearFor(removeContact.firstName)
            data.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension MainViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        DetailsViewController.present(on: self, model: data[indexPath.row], calback: { model in
            StoredContacts.shared.clearFor(model.firstName)
            self.data.removeAll(where: { $0.uuid == model.uuid })
            self.tableView.reloadData()
        })
    }
}
