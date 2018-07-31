//
//  OrganizeViewController.swift
//  Movables
//
//  MIT License
//
//  Copyright (c) 2018 Eddie Chen
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit
import Firebase
import NVActivityIndicatorView

protocol OrganizeViewControllerDelegate {
    func showSubscribedTopicDetailVC(for subscribedTopic: TopicSubscribed)
}

class OrganizeViewController: UIViewController {

    var mainCoordinator: MainCoordinator!
    var mainCoordinatorDelegate: MainCoordinatorDelegate!
    var delegate: OrganizeViewControllerDelegate?
    
    var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    var activityIndicatorView: NVActivityIndicatorView!
    
    var topicsSubscribed: [TopicSubscribed]?
    
    var emptyStateView: EmptyStateView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        setupTableView()
        fetchTopicsSubscribed()
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
        emptyStateView.titleLabel.text = String(NSLocalizedString("copy.wannaOrgnize", comment: "Organize tab empty state title"))
        emptyStateView.subtitleLabel.text = String(NSLocalizedString("copy.wannaOrgnizeBody", comment: "Organize tab empty state body"))
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
        fetchTopicsSubscribed()
    }
    
    private func fetchTopicsSubscribed() {
        UserManager.shared.userDocument!.reference.collection("subscribed_topics").getDocuments { (querySnapshot, error) in
            if let error = error {
                print(error)
            } else {
                if let snapshot = querySnapshot {
                    var topicsSubscribedTemp: [TopicSubscribed] = []
                    snapshot.documents.forEach({ (docSnapshot) in
                        topicsSubscribedTemp.append(TopicSubscribed(with: docSnapshot.data()))
                    })
                    self.topicsSubscribed = topicsSubscribedTemp
                    self.activityIndicatorView.stopAnimating()
                    self.refreshControl.endRefreshing()
                    if self.topicsSubscribed!.count == 0 {
                        self.emptyStateView.isHidden = false
                    } else {
                        self.emptyStateView.isHidden = true
                    }
                    self.tableView.reloadData()
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
}

extension OrganizeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.topicsSubscribed?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "packageMoved") as! OrganizePackageMovedTableViewCell
        let subscribedTopic = self.topicsSubscribed![indexPath.row]
        
        cell.topicLabel.text = "#\(subscribedTopic.topicName)"
        cell.packageCountLabel.text = String(format: NSLocalizedString(subscribedTopic.count.packagesMoved == 1 ? "label.packageMoved" : "label.packagesMovedPlural", comment: "label text for packages moved"), subscribedTopic.count.packagesMoved)
        let unreadTotal = subscribedTopic.count.packagesMoved + subscribedTopic.count.localConversations + subscribedTopic.count.privateConversations
        cell.supplementLabel.text = String(format: NSLocalizedString(unreadTotal == 1 ? "label.countConversations" : "label.countConversationsPlural", comment: "label text for count conversations participated in"), unreadTotal)
        if unreadTotal > 0 {
            cell.supplementLabelContainerView.isHidden = false
        } else {
            cell.supplementLabelContainerView.isHidden = true
        }
        return cell
    }
}

extension OrganizeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("did select \(indexPath.row)")
        self.delegate?.showSubscribedTopicDetailVC(for: self.topicsSubscribed![indexPath.row])
    }
}
