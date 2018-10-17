//
//  ViewController.swift
//  TrackerBot
//
//  Created by Justin Wang on 9/26/18.
//  Copyright © 2018 Justin. All rights reserved.
//

import UIKit
import CoreData
import WebKit

class LoginViewController: UIViewController, UITextFieldDelegate, WKNavigationDelegate, LoginServiceDelegate {

    @IBOutlet var webView : WKWebView!
    @IBOutlet var emailField : UITextField!
    @IBOutlet var loginButton: UIButton!
    var loginService: LoginService!
    var keyboardIsUp: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailField.delegate = self
        self.loginService = LoginServiceHandler(delegate: self)
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
        self.advanceDependingOnLoginStrategy(email: emailText)
    }
    
    func loginSuccessfull(withUser user: User, project: Project) {
        self.loginButton.isUserInteractionEnabled = true
        let botViewController: BotViewController = BotViewController(user: user, project: project)
        present(botViewController, animated: true, completion: nil)
    }
    
    func handle(error: String) {
        self.loginButton.isUserInteractionEnabled = true
        let alert = UIAlertController(title: "Authentication Error.", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func advanceSSOLogin(email: String, redirect_url: String) {
        var url: URL? = self.createOrUpdateRelayStateWithAppLink(urlString: redirect_url)
        print(url?.absoluteString)
        //launch webview with this url
        print("sso")
        
        webView.navigationDelegate = self
        webView.load(URLRequest(url: url!))
        webView.isHidden = false
    }
    
    func advanceBasicLogin(email: String) {
        //see which loginservice the user uses and then maybe segue or maybe do sso
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PasswordViewController") as! PasswordViewController
        self.navigationController?.pushViewController(controller, animated: false)
        controller.email = email
        self.loginButton.isUserInteractionEnabled = true
    }
    
    func advanceDependingOnLoginStrategy(email:String) {
        var allowedChars : CharacterSet = CharacterSet(charactersIn: ".@")
        allowedChars.invert()
        allowedChars.formIntersection(CharacterSet.urlQueryAllowed)
        let path: String = "area_51/login_strategies/"
        let host: String = "www.pivotaltracker.com"
        let urlString: String = "https://" + host + "/services/" + path + email.addingPercentEncoding(withAllowedCharacters: allowedChars)!
        let url: URL = URL(string: urlString)!
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Yes", forHTTPHeaderField: "X-Tracker-Use-UTC")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let appVersion: String = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
        request.addValue("iOS " + appVersion, forHTTPHeaderField: "X-Tracker-Client")
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            guard let data = data else { return }
            var json: Dictionary<String, Any> = Dictionary()
            do {
                json = try (JSONSerialization.jsonObject(with: data, options: [])) as! Dictionary<String, Any>
            } catch {
                DispatchQueue.main.async {
                    //error parsing json do something here
                }
            }
            DispatchQueue.main.async {
                if((json["login_method"] as! String) == "standard") {
                    self.advanceBasicLogin(email: email)
                } else if ((json["login_method"] as! String) == "saml") {
                    self.advanceSSOLogin(email: email, redirect_url: (json["saml_config"] as! Dictionary<String, String>)["redirect_url"]!)
                }
            }
        }
        
        task.resume()
    }
    
    func createOrUpdateRelayStateWithAppLink(urlString: String) -> URL? {
        var components : URLComponents = URLComponents(string: urlString)!
        components.scheme = "https"
        var queryItems : Array<URLQueryItem> = components.queryItems!
        var relayStateItem : URLQueryItem = queryItems.first(where:{$0.name == "RelayState"})!
        var hostname : String = "www.pivotaltracker.com"
        if (relayStateItem != nil) {
            var relayState : String = relayStateItem.value!
            relayState.remove(at: String.Index(encodedOffset: relayState.count - 1))
            relayState.append(",\"applink\":\"" + "pivotaltracker" + "://api_token/\"")
            relayState.append(",\"return_to\":\"https://" + hostname + "/auth/saml/\"")
            queryItems[queryItems.firstIndex(of: relayStateItem)!] = URLQueryItem(name: "RelayState", value: relayState)
            components.queryItems = queryItems
            return components.url!
        }
        return nil
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        var url : URL = navigationAction.request.url!
        if (url.scheme == "pivotaltracker") {
            let linkString = url.absoluteString
            let scheme = "pivotaltracker"
            let validAPIRegex = try! NSRegularExpression(pattern: "^\(scheme)://api_token/(.+)", options: [])
            let apiTokenLinkMatch = validAPIRegex.firstMatch(in: linkString, range: NSMakeRange(0, linkString.characters.count))
            if apiTokenLinkMatch != nil {
                var token = linkString
                let range = token.range(of: "\(scheme)://api_token/")!
                token.replaceSubrange(range, with: "")
                self.loginService.login(apiToken: token)
            }
            webView.isHidden = true
            decisionHandler(WKNavigationActionPolicy.cancel)
        } else {
            decisionHandler(WKNavigationActionPolicy.allow)
        }
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(URLSession.AuthChallengeDisposition.performDefaultHandling, nil)
    }
}
