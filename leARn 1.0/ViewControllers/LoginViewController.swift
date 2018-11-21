//
//  LoginViewController.swift
//  leARn 1.0
//
//  Created by Max Ainatchi on 11/11/18.
//  Copyright © 2018 Daniel Suissa. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController {
    lazy var emailField: UITextField = {
        let field = UITextField()
        field.placeholder = "Email"
        field.textContentType = .emailAddress
        field.keyboardType = .emailAddress
        field.returnKeyType = .next
        field.autocorrectionType = .yes
        return field
    }()
    
    lazy var passwordField: UITextField = {
        let field = UITextField()
        field.placeholder = "Password"
        field.isSecureTextEntry = true
        field.returnKeyType = .done
        return field
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.setTitle("Log In", for: .normal)
        button.addTarget(self, action: #selector(self.didTapLogin), for: .touchUpInside)
        return button
    }()
    
    lazy var registerButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.blue.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.setTitle("Don't Have An Account?", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(self.didTapRegister), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        self.view.backgroundColor = .white
        
        self.view.addSubview(self.emailField)
        self.view.addSubview(self.passwordField)
        self.view.addSubview(self.loginButton)
        self.view.addSubview(self.registerButton)
        for view in self.view.subviews {
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[v]-|", options: [], metrics: nil, views: ["v": view]))
        }
        
        for field in [self.emailField, self.passwordField] {
            field.borderStyle = .roundedRect
            field.delegate = self
        }
        
        self.view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:[top]-[email(50)]-[password(50)]-[loginButton(50)]-[registerButton(50)]",
            options: [],
            metrics: nil,
            views: [
                "top": self.topLayoutGuide,
                "email": self.emailField,
                "password": self.passwordField,
                "loginButton": self.loginButton,
                "registerButton": self.registerButton
            ])
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.emailField.becomeFirstResponder()
    }
    
    @objc func didTapLogin() {
        self.resignFirstResponder()
        print("Login")
        self.present(ARViewController(), animated: true, completion: nil)
    }
    
    @objc func didTapRegister() {
        self.resignFirstResponder()
        self.present(RegisterViewController(), animated: false, completion: nil)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == self.emailField {
            self.passwordField.becomeFirstResponder()
            return false
        }
        self.didTapLogin()
        return true
    }
}
