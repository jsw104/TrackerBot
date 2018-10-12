//
//  ViewController.swift
//  TrackerBot
//
//  Created by Justin Wang on 9/26/18.
//  Copyright © 2018 Justin. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var emailField : UITextField!
    @IBOutlet var passwordField : UITextField!
    var loginService: LoginService!
    var keyboardIsUp: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailField.delegate = self
        self.passwordField.delegate = self
        loginService = LoginServiceHandler(delegate: self)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func shouldMoveKeyboard(keyboardHeight: CGFloat) -> Bool {
        return (self.passwordField.frame.origin.y + self.passwordField.frame.size.height > self.view.frame.size.height - keyboardHeight)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if keyboardIsUp == true { return }
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if(shouldMoveKeyboard(keyboardHeight: keyboardSize.height)) {
                self.view.frame.origin.y -= keyboardSize.height
                keyboardIsUp = true
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if keyboardIsUp == false { return }
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if(shouldMoveKeyboard(keyboardHeight: keyboardSize.height)) {
                self.view.frame.origin.y += keyboardSize.height
                keyboardIsUp = false
            }
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        let emailText: String! = emailField.text == nil ? "" : emailField.text
        let passwordText: String! = passwordField.text == nil ? "" : passwordField.text
        loginService.login(email: emailText, password: passwordText)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension LoginViewController: LoginServiceDelegate {
    func loginSuccessfull(withUser user: User) {
        self.emailField.text = ""
        self.passwordField.text = ""
        let botViewController: BotViewController = BotViewController(user: user)
        present(botViewController, animated: true, completion: nil)
    }
    
    func handle(error: String) {
        dismissKeyboard()
        let alert = UIAlertController(title: "Authentication Error.", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}
