import Foundation
import FirebaseAuth
import FirebaseFirestore


extension RegisterViewController{
    
    func registerNewAccount() {
        showActivityIndicator()
        
        if let name = registerView.textFieldName.text, !name.isEmpty,
           let email = registerView.textFieldEmail.text, !email.isEmpty, isValidEmail(email),
           let password = registerView.textFieldPassword.text, !password.isEmpty, let confirmPassword = registerView.textFieldConfirmPassword.text, !confirmPassword.isEmpty, password.elementsEqual(confirmPassword){
            
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if error == nil, let userId = result?.user.uid {
                    self.setNameOfTheUserInFirebaseAuth(name: name)
                    self.addUserToFirestore(userId: userId, name: name, email: email)
                } else {
                    self.hideActivityIndicator()
                    print("Error creating user: \(String(describing: error?.localizedDescription))")
                }
            }
        } else {
            self.hideActivityIndicator()
            alertScreen(title: "Invalid Fields", message: "please check your input fields")
        }
    }
    
    func setNameOfTheUserInFirebaseAuth(name: String){
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = name
        changeRequest?.commitChanges(completion: {(error) in
            if error == nil{
                self.hideActivityIndicator()
                self.navigationController?.popViewController(animated: true)
            }else{
                print("Error occured: \(String(describing: error))")
            }
        })
    }
    
    func addUserToFirestore(userId: String, name: String, email: String) {
        let db = Firestore.firestore()
        let userData: [String: Any] = [
            "name": name,
            "emailId": email,
            "profilePicture": "",
            "createdByYou": [],
            "rsvpByYou": []
        ]
        
        db.collection("users").document(userId).setData(userData) { error in
            self.hideActivityIndicator()
            
            if error == nil {
                print("User successfully added to Firestore.")
                self.navigationController?.popViewController(animated: true)
            } else {
                print("Error adding user to Firestore: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@northeastern\\.edu$"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
    
    func alertScreen(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
