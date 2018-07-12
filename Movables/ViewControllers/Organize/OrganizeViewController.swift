//
//  OrganizeViewController.swift
//  Movables
//
//  Created by Eddie Chen on 6/6/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit
import Firebase
import NVActivityIndicatorView

struct OrganizeTopic {
    var tag: String
    var packagesMoved: [PackageMoved]
    var unreadTotal: Int
    var lastActivity: Date
    
    init(tag: String, packagesMoved: [PackageMoved], unreadTotal: Int, lastActivity: Date) {
        self.tag = tag
        self.packagesMoved = packagesMoved
        self.unreadTotal = unreadTotal
        self.lastActivity = lastActivity
    }
}

protocol OrganizeViewControllerDelegate {
    func showOrganizeDetailVC(for organizeTopic: OrganizeTopic)
}

class OrganizeViewController: UIViewController {

    var mainCoordinator: MainCoordinator!
    var mainCoordinatorDelegate: MainCoordinatorDelegate!
    var delegate: OrganizeViewControllerDelegate?
    
    var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    var activityIndicatorView: NVActivityIndicatorView!
    
    var packagesMoved: [PackageMoved]?
    var organizeTopics: [OrganizeTopic]? {
        didSet {
            self.activityIndicatorView.stopAnimating()
            self.refreshControl.endRefreshing()
            if organizeTopics!.count == 0 {
                emptyStateView.isHidden = false
            } else {
                emptyStateView.isHidden = true
            }
            self.tableView.reloadData()
        }
    }
    
    var emptyStateView: EmptyStateView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        setupTableView()
        fetchpackagesMoved()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func setupTableView(){
        tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 250
        tableView.separatorStyle = .none
        tableView.register(OrganizePackageMovedTableViewCell.self, forCellReuseIdentifier: "packageMoved")
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTableView(sender:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        activityIndicatorView = NVActivityIndicatorView(frame: .zero, type: .ballScale, color: Theme().textColor, padding: 0)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.startAnimating()
        tableView.backgroundView = activityIndicatorView
        
        emptyStateView = EmptyStateView(frame: .zero)
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.titleLabel.text = "Wanna organize?"
        emptyStateView.subtitleLabel.text = "Move a package first."
        emptyStateView.actionButton.isHidden = true
        emptyStateView.isHidden = true
        view.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            activityIndicatorView.heightAnchor.constraint(equalToConstant: 50),
            activityIndicatorView.widthAnchor.constraint(equalToConstant: 50),
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    @objc private func refreshTableView(sender: UIRefreshControl) {
        sender.beginRefreshing()
        fetchpackagesMoved()
    }
    
    private func fetchpackagesMoved() {
        let db = Firestore.firestore()
        db.collection("users").document("\(Auth.auth().currentUser!.uid)").collection("packages_moved").getDocuments { (querySnapshot, error) in
            if let error = error {
                print(error)
            } else {
                if let snapshot = querySnapshot {
                    var packagesMovedTemp: [PackageMoved] = []
                    snapshot.documents.forEach({ (docSnapshot) in
                        packagesMovedTemp.append(PackageMoved(dict: docSnapshot.data()))
                    })
                    self.packagesMoved = packagesMovedTemp
                    self.processPackagesMoved()
                } else {
                    print("snapshot is nil")
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func processPackagesMoved() {
        guard let packagesMoved = self.packagesMoved else { return }
        // sort into dict by tag name first
        var packagesByTagTemp:[String: [PackageMoved]] = [:]
        for package in packagesMoved {
            if let packages = packagesByTagTemp[package.tag.name] {
                // key already exists
                var newPackages: [PackageMoved] = []
                newPackages.append(contentsOf: packages)
                newPackages.append(package)
                packagesByTagTemp[package.tag.name] = newPackages
            } else {
                // key doesn't exist
                packagesByTagTemp.updateValue([package], forKey: package.tag.name)
            }
        }
        var organizeTopicsTemp:[OrganizeTopic] = []
        for taggedPackages in packagesByTagTemp {
            var unreadTotal = 0
            var lastActivity = Date(timeIntervalSince1970: 0)
            for packageMoved in taggedPackages.value {
               unreadTotal += packageMoved.packageMovedCount.unreadTotal
                if packageMoved.movedDate > lastActivity {
                    lastActivity = packageMoved.movedDate
                }
            }
            organizeTopicsTemp.append(OrganizeTopic(tag: taggedPackages.key, packagesMoved: taggedPackages.value, unreadTotal: unreadTotal, lastActivity: lastActivity))
        }
        self.organizeTopics = organizeTopicsTemp.sorted(by: { $0.unreadTotal > $1.unreadTotal })
    }
}

extension OrganizeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.organizeTopics?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "packageMoved") as! OrganizePackageMovedTableViewCell
        let organizeTopic = self.organizeTopics![indexPath.row]
        
        cell.topicLabel.text = "#\(organizeTopic.tag)"
        cell.packageCountLabel.text = String(format: NSLocalizedString(organizeTopic.packagesMoved.count == 1 ? "label.packageMoved" : "label.packagesMovedPlural", comment: "label text for packages moved"), organizeTopic.packagesMoved.count)
        cell.supplementLabel.text = "\(organizeTopic.unreadTotal)"
        cell.supplementLabelContainerView.backgroundColor = Theme().mapStampTint
        if organizeTopic.unreadTotal <= 0 {
            cell.supplementLabelContainerView.isHidden = true
        }
        return cell
    }
}

extension OrganizeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("did select \(indexPath.row)")
        self.delegate?.showOrganizeDetailVC(for: self.organizeTopics![indexPath.row])
    }
}
