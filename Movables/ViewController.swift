//
//  ViewController.swift
//  Movables
//
//  Created by Eddie Chen on 3/22/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBAction func signupEmailButtonTapped(_ sender: Any) {
        Auth.auth().createUser(withEmail: emailTextField.text ?? "", password: passwordTextField.text ?? "") { (user, error) in
            if error != nil {
                print(error!)
            } else {
                print(user!)
                self.performSegue(withIdentifier: "signedIn", sender: self)
            }
        }
    }

    @IBAction func signupAnonymouslyButtonTapped(_ sender: Any) {
        Auth.auth().signInAnonymously { (user, error) in
            if error != nil {
                print(error!)
            } else {
                print(user!)
                self.performSegue(withIdentifier: "signedIn", sender: self)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        emailTextField.text = ""
        passwordTextField.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
