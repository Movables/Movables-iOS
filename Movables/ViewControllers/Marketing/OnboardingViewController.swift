//
//  OnboardingViewController.swift
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

class OnboardingViewController: UIViewController {

    var delegate: OnboardingViewControllerDelegate?
    var loginButton: UIButton!
    var logoImageView: UIImageView!
    var welcomeTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        loginButton = UIButton(frame: .zero)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.layer.cornerRadius = 25
        loginButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        loginButton.setTitle("Get Started", for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        loginButton.setBackgroundColor(color: Theme().keyTint, forUIControlState: .normal)
        loginButton.setBackgroundColor(color: Theme().keyTintHighlight, forUIControlState: .highlighted)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.addTarget(self, action: #selector(loginBarButtonTapped(sender:)), for: .touchUpInside)
        loginButton.clipsToBounds = true
        view.addSubview(loginButton)
        
        logoImageView = UIImageView(frame: .zero)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.image = UIImage(named: "AppIconVector")
        logoImageView.contentMode = .scaleAspectFill
        view.addSubview(logoImageView)
        
        welcomeTitle = UILabel(frame: .zero)
        welcomeTitle.translatesAutoresizingMaskIntoConstraints = false
        welcomeTitle.numberOfLines = 0
        welcomeTitle.font = UIFont.systemFont(ofSize: 30, weight: .regular)
        welcomeTitle.text = "Welcome to Movables"
        welcomeTitle.textAlignment = .center
        view.addSubview(welcomeTitle)
        
        
        NSLayoutConstraint.activate([
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 150),
            logoImageView.widthAnchor.constraint(equalToConstant: 150),
            logoImageView.topAnchor.constraint(equalTo: view.centerYAnchor, constant: -150),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            welcomeTitle.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 24),
            welcomeTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            welcomeTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),

        ])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func loginBarButtonTapped(sender: UIButton) {
        delegate?.didTapLoginButton()
    }
}

protocol OnboardingViewControllerDelegate: class {
    func didTapLoginButton()
}
