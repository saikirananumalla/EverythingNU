import UIKit

class LoginScreen: UIView {

    var contentWrapper:UIScrollView!
    var textFieldEmail: UITextField!
    var textFieldPassword: UITextField!
    var buttonLogin: UIButton!
    var buttonSignUp: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        
        setupContentWrapper()
        textFieldEmail = setupTextField(placeholder: "Email", topAnchor: contentWrapper.topAnchor, keyboardType: .emailAddress)
        textFieldPassword = setupTextField(placeholder: "Password", topAnchor: textFieldEmail.bottomAnchor, keyboardType: .default)
        textFieldPassword.isSecureTextEntry = true
        buttonLogin = setupbuttonField(name: "Login", topAnchor: textFieldPassword.bottomAnchor, constant: 16)
        buttonSignUp = setupbuttonField(name: "New User? Sign Up", topAnchor: safeAreaLayoutGuide.bottomAnchor, constant: -32)
    }
    
    func setupContentWrapper(){
        contentWrapper = UIScrollView()
        contentWrapper.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(contentWrapper)
        
        NSLayoutConstraint.activate([
            contentWrapper.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            contentWrapper.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            contentWrapper.widthAnchor.constraint(equalTo:self.safeAreaLayoutGuide.widthAnchor),
            contentWrapper.heightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.heightAnchor)
        ])
    }
    
    
    func setupTextField(placeholder: String, topAnchor: NSLayoutYAxisAnchor, keyboardType: UIKeyboardType = .alphabet) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = keyboardType
        contentWrapper.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            textField.centerXAnchor.constraint(equalTo: contentWrapper.centerXAnchor),
            textField.widthAnchor.constraint(equalTo: contentWrapper.widthAnchor, multiplier: 0.9)
        ])
        
        return textField
    }
    
    func setupbuttonField(name: String, topAnchor: NSLayoutYAxisAnchor, constant: CGFloat) -> UIButton{
        let buttonField = UIButton(type: .system)
        buttonField.setTitle(name, for: .normal)
        buttonField.translatesAutoresizingMaskIntoConstraints = false
        contentWrapper.addSubview(buttonField)
        
        NSLayoutConstraint.activate([
            buttonField.topAnchor.constraint(equalTo: topAnchor, constant: constant),
            buttonField.centerXAnchor.constraint(equalTo: contentWrapper.centerXAnchor)
        ])
        
        return buttonField
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
