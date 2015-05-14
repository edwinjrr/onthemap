//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Edwin Rodriguez on 4/23/15.
//  Copyright (c) 2015 Edwin Rodriguez. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var headerTextLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: BorderedButton!
    @IBOutlet weak var debugTextLabel: UILabel!
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    
    var session: NSURLSession!
    var facebookAccessToken: String!
    var backgroundGradient: CAGradientLayer? = nil
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Get the shared URL session */
        session = NSURLSession.sharedSession()
        
        /* Configure the UI */
        self.configureUI()
        
        self.facebookLoginButton.delegate = self
        
       /* Check for existing Facebook Access Tokens */
       if (FBSDKAccessToken.currentAccessToken() != nil) {
            self.loadingView(true)
            self.facebookAccessToken = FBSDKAccessToken.currentAccessToken().tokenString as String
            self.loginWithFacebook(facebookAccessToken)
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardDismissRecognizer()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardDismissRecognizer()
    }
    
    // MARK: - Keyboard Fixes
    
    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // MARK: - Login with Udacity's credentials.
    
    @IBAction func loginButtonTouch(sender: AnyObject) {
        
        self.view.endEditing(true) //Hide the keyboard when the user press login.
        
        //Checking for internet connection first.
        if Reachability.isConnectedToNetwork() == true {
            
            if usernameTextField.text.isEmpty {
                //self.loadingView(false)
                debugTextLabel.text = "Username field is empty!"
            } else if passwordTextField.text.isEmpty {
                //self.loadingView(false)
                debugTextLabel.text = "Password field is empty!"
            } else {
                self.loadingView(true) //Show the user that the app is working with the request made.
                Client.sharedInstance().postSessionWithUdacityCredentials(self.usernameTextField.text, password: self.passwordTextField.text) { (success, error) in
                    if success {
                        self.loadingView(false)
                        self.completeLogin()
                    }
                    else {
                        self.loadingView(false)
                        self.displayError(error)
                    }
                }
            }
            
        } else {
            self.loadingView(false)
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    //Take the FacebookAccessToken, get the udacity's public user data and complete the login.
    func loginWithFacebook(accessToken: String) {
        Client.sharedInstance().postSessionWithFacebookAuthentication(accessToken) { (success, error) in
            if success {
                self.loadingView(false)
                self.completeLogin()
            }
            else {
                self.displayError(error)
            }
        }
    }
    
    //Show the user that the app is working with his request, disabling the login button and showing "Loading..." in the debugTextLabel.
    func loadingView(state: Bool) {
        dispatch_async(dispatch_get_main_queue(), {
            if state {
                self.loginButton.enabled = false
                self.loginButton.alpha = 0.50
                self.debugTextLabel.text = "Loading..."
            }
            else {
                self.loginButton.enabled = true
                self.loginButton.alpha = 1.0
                self.debugTextLabel.text = ""
            }
        })
    }
    
    //When the authentication/Authorization is completed, the user gets access to the TabBarViewController.
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            self.debugTextLabel.text = ""
            self.usernameTextField.text = ""
            self.passwordTextField.text = ""
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("OnTheMapTabBarController") as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
    
    //Link to the sign-up page of Udacity.
    @IBAction func signUp(sender: AnyObject) {
        let app = UIApplication.sharedApplication()
        app.openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)
    }
    
    //Shows an error message in the debugTextLabel.
    func displayError(errorString: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            if let errorString = errorString {
                self.debugTextLabel.text = errorString
            }
        })
    }
    
    //Getting the final look of the view.
    func configureUI() {
        
        /* Configure background gradient */
        self.view.backgroundColor = UIColor.clearColor()
        let colorTop = UIColor(red: 0.99, green: 0.60, blue: 0.16, alpha: 1.0).CGColor
        let colorBottom = UIColor(red: 0.99, green: 0.44, blue: 0.13, alpha: 1.0).CGColor
        self.backgroundGradient = CAGradientLayer()
        self.backgroundGradient!.colors = [colorTop, colorBottom]
        self.backgroundGradient!.locations = [0.0, 1.0]
        self.backgroundGradient!.frame = view.frame
        self.view.layer.insertSublayer(self.backgroundGradient, atIndex: 0)
        
        /* Configure email textfield */
        let emailTextFieldPaddingViewFrame = CGRectMake(0.0, 0.0, 13.0, 0.0);
        let emailTextFieldPaddingView = UIView(frame: emailTextFieldPaddingViewFrame)
        usernameTextField.leftView = emailTextFieldPaddingView
        usernameTextField.leftViewMode = .Always
        usernameTextField.attributedPlaceholder = NSAttributedString(string: usernameTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        /* Configure password textfield */
        let passwordTextFieldPaddingViewFrame = CGRectMake(0.0, 0.0, 13.0, 0.0);
        let passwordTextFieldPaddingView = UIView(frame: passwordTextFieldPaddingViewFrame)
        passwordTextField.leftView = passwordTextFieldPaddingView
        passwordTextField.leftViewMode = .Always
        passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])

        /* Configure debug text label */
        debugTextLabel.font = UIFont(name: "AvenirNext-Medium", size: 20)
        debugTextLabel.textColor = UIColor.whiteColor()
        
        /* Configure tap recognizer */
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        
    }
    
    //MARK: - FBSDKLoginButtonDelegate Methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {

        if ((error) != nil)
        {
            //Nothing to do here.
        }
        else if result.isCancelled {
            // Nothing to do here.
        }
        else {
            self.loadingView(true)
            self.facebookAccessToken = FBSDKAccessToken.currentAccessToken().tokenString as String
            self.loginWithFacebook(facebookAccessToken)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        // Nothing to do here.
    }
    
}

