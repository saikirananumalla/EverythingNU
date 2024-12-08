import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SDWebImage
import PhotosUI


class EditUserInfoViewController: UIViewController {
    
    let editUserInfoScreen = EditUserInfoScreen()
    
    var currentUser:FirebaseAuth.User?
    
    override func loadView() {
        view = editUserInfoScreen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectProfilePicture))
        self.editUserInfoScreen.profileImageView.addGestureRecognizer(tapGesture)
        self.editUserInfoScreen.saveButton.addTarget(self, action: #selector(saveChanges), for: .touchUpInside)
        self.editUserInfoScreen.cancelButton.addTarget(self, action: #selector(cancelEdit), for: .touchUpInside)
        prefillUserData()
    }
    
    func prefillUserData() {
        
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
            
            // Prefill the name field
            self.editUserInfoScreen.nameTextField.text = data["name"] as? String ?? ""
            
            // Load the profile picture
            if let profilePicturePath = data["profilePicture"] as? String, !profilePicturePath.isEmpty {
                self.loadProfilePicture(from: profilePicturePath)
            } else {
                self.editUserInfoScreen.profileImageView.image = UIImage(systemName: "person.circle")
            }
        }
    }


    func loadProfilePicture(from path: String) {
        let storageRef = Storage.storage().reference().child(path)
        
        storageRef.downloadURL { url, error in
            if let error = error {
                print("Error fetching profile picture URL: \(error.localizedDescription)")
                self.editUserInfoScreen.profileImageView.image = UIImage(systemName: "person.circle")
                return
            }
            
            guard let url = url else {
                print("Profile picture URL is nil.")
                self.editUserInfoScreen.profileImageView.image = UIImage(systemName: "person.circle")
                return
            }
            
            // Load image from the URL
            DispatchQueue.main.async {
                self.editUserInfoScreen.profileImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "person.circle"))
            }
        }
    }

    @objc func selectProfilePicture() {
        let alert = UIAlertController(title: "Choose Profile Picture", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func openCamera() {
        let cameraController = UIImagePickerController()
        cameraController.sourceType = .camera
        cameraController.allowsEditing = true
        cameraController.delegate = self
        present(cameraController, animated: true)
    }

    func openGallery() {
        var configuration = PHPickerConfiguration()
        configuration.filter = PHPickerFilter.any(of: [.images])
        configuration.selectionLimit = 1
                
        let photoPicker = PHPickerViewController(configuration: configuration)
                
        photoPicker.delegate = self
        present(photoPicker, animated: true, completion: nil)
    }

    @objc func saveChanges() {
        guard let currentUserEmail = Auth.auth().currentUser?.email else {
            print("Error: User not authenticated.")
            return
        }
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("Error: User not authenticated.")
            return
        }
        
        guard let name = self.editUserInfoScreen.nameTextField.text, !name.isEmpty else {
            print("Error: Name cannot be empty.")
            return
        }
        
        guard let newPassword = self.editUserInfoScreen.passwordTextField.text,
              let confirmPassword = self.editUserInfoScreen.confirmPasswordTextField.text,
              newPassword == confirmPassword else {
            print("Error: Passwords do not match.")
            return
        }
        
        // Update Firestore Authentication for password
        if (newPassword != "") {
            
            Auth.auth().currentUser?.updatePassword(to: newPassword) { error in
                if let error = error {
                    print("Error updating password: \(error.localizedDescription)")
                    return
                }
                print("Password updated successfully.")
            }
            
        }
        
        // Handle profile picture update
        if let newImage = self.editUserInfoScreen.profileImageView.image, let imageData = newImage.jpegData(compressionQuality: 0.8) {
            let storagePath = "profilepictures/\(currentUserEmail)/profile.png"
            let storageRef = Storage.storage().reference().child(storagePath)
            
            // Upload new profile picture to Firebase Storage
            storageRef.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    print("Error uploading profile picture: \(error.localizedDescription)")
                    return
                }
                
                // Update Firestore with new data
                Firestore.firestore().collection("users").document(currentUserId).updateData([
                    "name": name,
                    "profilePicture": storagePath
                ]) { error in
                    if let error = error {
                        print("Error updating Firestore document: \(error.localizedDescription)")
                    } else {
                        print("User data updated successfully.")
                    }
                }
            }
        } else {
            // Update Firestore without a profile picture change
            Firestore.firestore().collection("users").document(currentUserId).updateData([
                "name": name
            ]) { error in
                if let error = error {
                    print("Error updating Firestore document: \(error.localizedDescription)")
                } else {
                    print("User data updated successfully.")
                }
            }
        }
        navigationController?.popViewController(animated: true)
    }


    @objc func cancelEdit() {
        navigationController?.popViewController(animated: true)
    }
}


extension EditUserInfoViewController:PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        let itemprovider = results.map(\.itemProvider)
        
        for item in itemprovider{
            if item.canLoadObject(ofClass: UIImage.self){
                item.loadObject(ofClass: UIImage.self, completionHandler: { (image, error) in
                    DispatchQueue.main.async{
                        if let uwImage = image as? UIImage{
                            self.editUserInfoScreen.profileImageView.image = uwImage
                        }
                    }
                })
            }
        }
    }
}

extension EditUserInfoViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let image = info[.editedImage] as? UIImage{
            self.editUserInfoScreen.profileImageView.image = image
        }else{
            // Do your thing for No image loaded...
        }
    }
}
