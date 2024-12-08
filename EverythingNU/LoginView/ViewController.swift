import UIKit
import FirebaseAuth
import FirebaseFirestore

class ViewController: UIViewController {
    
    let loginPage = LoginScreen()
    
    var currentUser:FirebaseAuth.User?
    
    let childProgressView = ProgressSpinnerViewController()
    
    override func loadView() {
        view = loginPage
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        title = "EverythingNU"
        
        loginPage.buttonLogin.addTarget(self, action: #selector(onButtonLoginTapped), for: .touchUpInside)
        loginPage.buttonSignUp.addTarget(self, action: #selector(onButtonSignUpTapped), for: .touchUpInside)
        
        if let currentUser = Auth.auth().currentUser {
            print("User is already logged in: \(currentUser.email ?? "No Email")")
            self.currentUser = Auth.auth().currentUser
            self.redirectToEventList()
        }
        
    }
    
    
    @objc func onButtonLoginTapped(){
        
        self.showActivityIndicator()
        
        if let unWrappedEmail = loginPage.textFieldEmail.text, !unWrappedEmail.isEmpty {
            
            if let unWrappedPassword = loginPage.textFieldPassword.text, !unWrappedPassword.isEmpty {
                
                login(email: unWrappedEmail, password: unWrappedPassword)
                
            } else {
                showDetailsInAlert(errorMessage: "Username is empty")
                self.hideActivityIndicator()
            }
            
        } else {
            showDetailsInAlert(errorMessage: "Email is empty")
            self.hideActivityIndicator()
        }
        
    }
    
    @objc func onButtonSignUpTapped(){
        
        // Navigate control to sign up screen with an option to go back. default.
        print("Going into the register screen")
        self.navigationController?.pushViewController(RegisterViewController(), animated: true)
        
    }
    
    // Firestore Login
    func login(email: String, password: String){
        
        // Call the Firestore sign in API
        // Will use showAlert function in validation
        
        Auth.auth().signIn(withEmail: email, password: password, completion: {(result, error) in
            if error == nil{
                // Remove the buffering
                self.hideActivityIndicator()
                print("Login Success !!!!!!!!")
                self.currentUser = Auth.auth().currentUser
                self.redirectToEventList()
            }else{
                self.showDetailsInAlert(errorMessage: "Username or the password might be wrong!!")
                self.hideActivityIndicator()
            }
            
        })
        
    }
    
    func redirectToEventList() {
        let homeViewController = HomeViewController()
        homeViewController.currentUser = self.currentUser
        self.navigationController?.pushViewController(homeViewController, animated: true)
    }
    
    func showDetailsInAlert(errorMessage: String){
        let alert = UIAlertController(title: "Error!", message: "\(errorMessage)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }

}


