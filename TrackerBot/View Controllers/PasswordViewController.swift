//
//  PasswordViewController.swift
//  TrackerBot
//
//  Created by Justin Wang on 10/15/18.
//  Copyright © 2018 Justin. All rights reserved.
//

import UIKit

class PasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var emailField : UITextField!
    @IBOutlet var passwordField : UITextField!
    @IBOutlet var loginButton: UIButton!
    
    var email: String = ""
    var keyboardIsUp: Bool = false
    var loginService: LoginService!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailField.text = email
        self.passwordField.delegate = self
        loginService = LoginServiceHandler(delegate: self)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func shouldMoveKeyboard(keyboardHeight: CGFloat) -> Bool {
        return (self.emailField.frame.origin.y + self.emailField.frame.size.height > self.view.frame.size.height - keyboardHeight)
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
        self.loginButton.isUserInteractionEnabled = false
        let emailText: String! = emailField.text == nil ? "" : emailField.text
        let passwordText: String! = passwordField.text == nil ? "" : passwordField.text
        loginService.login(email: emailText, password: passwordText)
    }
}

extension PasswordViewController: LoginServiceDelegate {
    func loginSuccessfull(withUser user: User, project:Project) {
        self.loginButton.isUserInteractionEnabled = true
        self.passwordField.text = ""
        let botViewController: BotViewController = BotViewController(user: user, project: project)
        present(botViewController, animated: true, completion: nil)
    }
    
    func handle(error: String) {
        self.loginButton.isUserInteractionEnabled = true
        let alert = UIAlertController(title: "Authentication Error.", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}
