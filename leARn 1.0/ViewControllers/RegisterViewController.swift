//
//  RegisterViewController.swift
//  leARn 1.0
//
//  Created by Max Ainatchi on 11/11/18.
//  Copyright © 2018 Daniel Suissa. All rights reserved.
//

import UIKit

enum Language: Int, CaseIterable {
    case spanish = 0
    case french
    case latin
    
    var title: String {
        switch self {
        case .spanish: return "Spanish"
        case .french: return "French"
        case .latin: return "Latin"
        }
    }
    
    var key: String {
        switch self {
        case .spanish: return "es"
        case .french: return "fr"
        case .latin: return "la"
        }
    }
}

class RegisterViewController: UIViewController {
    var textFields: [UITextField] = []
    lazy var nameField: UITextField = {
        let field = UITextField()
        field.placeholder = "Name"
        field.keyboardType = .asciiCapable
        field.returnKeyType = .next
        field.autocorrectionType = .yes
        return field
    }()
    
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
        field.returnKeyType = .next
        return field
    }()
    
    lazy var confirmPasswordField: UITextField = {
        let field = UITextField()
        field.placeholder = "Confirm Password"
        field.isSecureTextEntry = true
        field.returnKeyType = .done
        return field
    }()
    
    lazy var selectLanguageButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.setTitle("Select Language", for: .normal)
        button.addTarget(self, action: #selector(self.didTapSelectLanguage), for: .touchUpInside)
        return button
    }()

    var selectedLanguage: Language? = nil
    
    lazy var languageSelector: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        let doneButton = UIButton()
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(.blue, for: .normal)
        doneButton.layer.borderColor = UIColor.blue.cgColor
        doneButton.layer.borderWidth = 1
        doneButton.layer.cornerRadius = 5
        doneButton.addTarget(self, action: #selector(self.didChooseLanguage), for: .touchUpInside)
        [pickerView, doneButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[v]-|", options: [], metrics: nil, views: ["v": $0]))
        }
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[picker]-[button(60)]-|", options: [], metrics: nil, views: ["picker": pickerView, "button": doneButton]))
        view.isHidden = true
        return view
    }()
    
    lazy var registerButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.setTitle("Register", for: .normal)
        button.addTarget(self, action: #selector(self.didTapRegister), for: .touchUpInside)
        return button
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.blue.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.setTitle("Have An Account?", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(self.didTapLogin), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        self.view.backgroundColor = .white
        
        let inputs = [self.nameField, self.emailField, self.passwordField, self.confirmPasswordField, self.selectLanguageButton, self.loginButton, self.registerButton]
        inputs.forEach {
            self.view.addSubview($0)
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[v]-|", options: [], metrics: nil, views: ["v": $0]))
        }
        self.view.addSubview(self.languageSelector)
        
        for view in self.view.subviews {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        self.textFields = [self.nameField, self.emailField, self.passwordField, self.confirmPasswordField]
        for field in self.textFields {
            field.borderStyle = .roundedRect
            field.delegate = self
        }
        
        self.view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:[top]-[name(50)]-[email(50)]-[password(50)]-[confirmPassword(50)]-[selectLanguage(50)]-[registerButton(50)]-[loginButton(50)]",
            options: [],
            metrics: nil,
            views: [
                "top": self.topLayoutGuide,
                "name": self.nameField,
                "email": self.emailField,
                "password": self.passwordField,
                "confirmPassword": self.confirmPasswordField,
                "selectLanguage": self.selectLanguageButton,
                "registerButton": self.registerButton,
                "loginButton": self.loginButton
            ])
        )
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[v]|", options: [], metrics: nil, views: ["v": self.languageSelector]))
        self.languageSelector.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[picker(300)]", options: [], metrics: nil, views: ["picker": self.languageSelector]))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.nameField.becomeFirstResponder()
    }
    
    @objc func didTapSelectLanguage() {
        UIView.animate(withDuration: 2) {
            self.languageSelector.isHidden = false
        }
    }
    
    @objc func didChooseLanguage() {
        let title = self.selectedLanguage?.title ?? "Select Language"
        self.selectLanguageButton.setTitle(title, for: .normal)
        UIView.animate(withDuration: 2) {
            self.languageSelector.isHidden = true
        }
    }
    
    @objc func didTapLogin() {
        self.present(LoginViewController(), animated: false, completion: nil)
    }
    
    @objc func didTapRegister() {
        self.resignFirstResponder()
        guard self.validate() else { return }
        print("register")
        Credentials.main.register(email: self.emailField.text!, password: self.passwordField.text!, language: self.selectedLanguage!.key, displayName: self.nameField.text!) { error, user in
            guard error == nil, user != nil else {
                self.present(UIAlertController(error: error), animated: true, completion: nil)
                return
            }
            self.present(ARViewController(), animated: true, completion: nil)
        }
    }
    
    func validate() -> Bool {
        var offendingField: UIView? = nil
        let alert = UIAlertController(title: "Invalid", message: nil, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
        })
        var message: String? = nil
        if self.nameField.text?.isEmpty ?? false {
            message = "Please enter a name."
            offendingField = self.nameField
        } else if self.emailField.text?.isEmpty ?? false || !(self.emailField.text?.contains("@") ?? false) {
            message = "Please enter a valid email."
            offendingField = self.emailField
        } else if self.selectedLanguage == nil{
            message = "Please select a language."
            offendingField = self.selectLanguageButton
        } else if self.passwordField.text?.isEmpty ?? false || self.confirmPasswordField.text?.isEmpty ?? false {
            message = "Please enter a password."
            offendingField = self.passwordField.text?.isEmpty ?? true ? self.passwordField : self.confirmPasswordField
        } else if self.confirmPasswordField.text != self.passwordField.text {
            message = "Password and confirmation do not match!"
            offendingField = self.confirmPasswordField
        }
        if let message = message {
            offendingField?.becomeFirstResponder()
            alert.message = message
            self.present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if let index = self.textFields.firstIndex(of: textField),
            index + 1 < self.textFields.count {
            self.textFields[index + 1].becomeFirstResponder()
            return false
        }
        self.didTapRegister()
        return true
    }
}

extension RegisterViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Language.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Language(rawValue: row)?.title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedLanguage = Language(rawValue: row)
    }
}
