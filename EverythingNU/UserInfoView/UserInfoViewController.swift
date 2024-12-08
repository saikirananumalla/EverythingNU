import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SDWebImage


class UserInfoViewController: UIViewController {
    
    let userInfoScreen = UserInfoScreen()
    
    var currentUser:FirebaseAuth.User?
    
    override func loadView() {
        view = userInfoScreen
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        fetchUserInfo()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .edit, target: self,
            action: #selector(editButtonTapped)
        )
        userInfoScreen.buttonLogOut.addTarget(self, action: #selector(onLogOutButtonTapped), for: .touchUpInside)
    }

    func fetchUserInfo() {
        guard let currentUserEmail = Auth.auth().currentUser?.email else {
            print("Error: User not authenticated.")
            return
        }
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("Error: User not authenticated.")
            return
        }
        
        let userDocRef = Firestore.firestore().collection("users").document(currentUserId)
        
        userDocRef.getDocument { document, error in
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists, let data = document.data() else {
                print("Document does not exist or has no data.")
                return
            }
            
            // Update UI with fetched data
            self.userInfoScreen.nameLabel.text = data["name"] as? String ?? "No Name"
            self.userInfoScreen.emailLabel.text = currentUserEmail
            
            if let profilePicturePath = data["profilePicture"] as? String, !profilePicturePath.isEmpty {
                self.loadProfilePicture(from: profilePicturePath)
            } else {
                // Set default profile picture
                self.userInfoScreen.profileImageView.image = UIImage(systemName: "person.circle")
            }
        }
    }

    func loadProfilePicture(from path: String) {
        let storageRef = Storage.storage().reference().child(path)
        
        storageRef.downloadURL { url, error in
            if let error = error {
                print("Error fetching profile picture URL: \(error.localizedDescription)")
                self.userInfoScreen.profileImageView.image = UIImage(systemName: "person.circle")
                return
            }
            
            guard let url = url else {
                print("Profile picture URL is nil.")
                self.userInfoScreen.profileImageView.image = UIImage(systemName: "person.circle")
                return
            }
            
            // Load image from the URL
            DispatchQueue.main.async {
                self.userInfoScreen.profileImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "person.circle"))
            }
        }
    }

    @objc func editButtonTapped() {
        let editVC = EditUserInfoViewController()
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    @objc func onLogOutButtonTapped() {
        do {
            try Auth.auth().signOut()
            print("User logged out successfully.")
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError.localizedDescription)")
        }
        
    }
}
