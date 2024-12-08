import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class CreateEventViewController: UIViewController {
    
    let createEventPage = CreateEventScreen()
    var selectedImages = [UIImage]()
    let childProgressView = ProgressSpinnerViewController()
    var eventToEdit: Event?
    
    override func loadView() {
        self.view = createEventPage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Event"
        
        if let event = eventToEdit {
            prefillEventDetails(event)
            title = "Edit Event"
        }
        
        createEventPage.textFieldTags.delegate = self
        createEventPage.collectionViewTags.dataSource = self
        createEventPage.collectionViewTags.delegate = self
        createEventPage.collectionViewTags.register(TagCell.self, forCellWithReuseIdentifier: "TagCell")
        
        createEventPage.buttonAddImage.addTarget(self, action: #selector(onAddImagePressed), for: .touchUpInside)
        createEventPage.buttonSelectLocation.addTarget(self, action: #selector(onSelectLocationPressed), for: .touchUpInside)
        createEventPage.buttonSubmit.addTarget(self, action: #selector(onSubmitPressed), for: .touchUpInside)
    }
    
    func prefillEventDetails(_ event: Event) {
        // Set existing event details
        createEventPage.textFieldName.text = event.name
        createEventPage.textViewDescription.text = event.description
        createEventPage.datePickerStartTime.date = event.startTime.dateValue()
        createEventPage.datePickerEndTime.date = event.endTime.dateValue()
        createEventPage.selectedLocation = event.location
        createEventPage.labelSelectedLocation.text = "Lat: \(event.location.latitude), Long: \(event.location.longitude)"

        // Load previous image
        if let imageURL = event.pictures.first {
            fetchImage(from: imageURL) { [weak self] image in
                self?.createEventPage.imageViewSelected.image = image
            }
        }

        // Load previous tags
        let tagReferences = event.eventTags
        var tagsList = [String]()
        let dispatchGroup = DispatchGroup()
        for tagRef in tagReferences {
            dispatchGroup.enter()
            tagRef.getDocument { document, error in
                if let document = document, let tagName = document.data()?["name"] as? String {
                    tagsList.append(tagName.lowercased())
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            print(tagsList)
            self.createEventPage.selectedTags = tagsList
            self.createEventPage.collectionViewTags.reloadData()
        }
    }
    
    private func fetchImage(from url: String, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: URL(string: url)!), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }


    
    func showDetailsInAlert(errorMessage: String){
        let alert = UIAlertController(title: "Error!", message: "\(errorMessage)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    @objc func onAddImagePressed() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func onSelectLocationPressed() {
        let locationPicker = LocationPickerViewController()
        locationPicker.delegate = self
        self.navigationController?.pushViewController(locationPicker, animated: true)
    }
    
    @objc func onSubmitPressed() {
        guard validateInputs() else {
            return
        }
        
        self.showActivityIndicator()
        
        if let event = eventToEdit {
            updateEvent(event)
            return
        }
        
        let location = self.createEventPage.selectedLocation ?? GeoPoint(latitude: 0, longitude: 0)
        let userID = Auth.auth().currentUser?.uid
        let userDocumentRef = Firestore.firestore().collection("users").document(userID ?? "")
        
        // Fetch tag references based on selected tag names
        fetchTagReferences(for: createEventPage.selectedTags) { tagReferences in
            if tagReferences.isEmpty {
                self.hideActivityIndicator()
                self.showDetailsInAlert(errorMessage: "Error: Tags not found")
                return
            }
            
            let event = Event(
                id: nil,
                startTime: Timestamp(date: self.createEventPage.datePickerStartTime.date),
                endTime: Timestamp(date: self.createEventPage.datePickerEndTime.date),
                eventTags: tagReferences,
                rsvpList: [],
                name: self.createEventPage.textFieldName.text ?? "",
                description: self.createEventPage.textViewDescription.text ?? "",
                pictures: [],
                location: location,
                createdBy: userDocumentRef
            )
            
            saveEventToFirebase(event: event, images: self.selectedImages) { success in
                self.hideActivityIndicator()
                if success {
                    NotificationCenter.default.post(name: Notification.Name("addFromAddEventScreen"), object: nil)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.showDetailsInAlert(errorMessage: "Error saving event: check inputs")
                }
            }
        }
    }

    func fetchTagReferences(for tagNames: [String], completion: @escaping ([DocumentReference]) -> Void) {
        let db = Firestore.firestore()
        let tagsCollection = db.collection("tags")
        var tagReferences = [DocumentReference]()
        let group = DispatchGroup()
        
        for tagName in tagNames {
            group.enter()
            // Check if the tag already exists
            tagsCollection.whereField("name", isEqualTo: tagName).getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching tag: \(error.localizedDescription)")
                    group.leave()
                } else if let document = snapshot?.documents.first {
                    // Tag exists, add its reference
                    tagReferences.append(document.reference)
                    group.leave()
                } else {
                    // Tag doesn't exist, create a new one
                    let newTagRef = tagsCollection.document()
                    let newTag = EventTag(name: tagName)
                    do {
                        try newTagRef.setData(from: newTag) { error in
                            if let error = error {
                                print("Error creating new tag: \(error.localizedDescription)")
                            } else {
                                tagReferences.append(newTagRef)
                            }
                            group.leave()
                        }
                    } catch {
                        print("Error encoding tag: \(error.localizedDescription)")
                        group.leave()
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(tagReferences)
        }
    }

    
    func updateEvent(_ event: Event) {
        guard let eventId = event.id else { return }

        // If there are new images, upload them
        if !selectedImages.isEmpty {
            uploadImages { [weak self] uploadedImageURLs in
                self?.performEventUpdate(eventId: eventId, imageUrls: uploadedImageURLs)
            }
        } else {
            // Keep existing images if no new ones are selected
            performEventUpdate(eventId: eventId, imageUrls: event.pictures)
        }
    }

    private func performEventUpdate(eventId: String, imageUrls: [String]) {
        let updatedData: [String: Any] = [
            "name": createEventPage.textFieldName.text ?? "",
            "description": createEventPage.textViewDescription.text ?? "",
            "startTime": Timestamp(date: createEventPage.datePickerStartTime.date),
            "endTime": Timestamp(date: createEventPage.datePickerEndTime.date),
            "location": createEventPage.selectedLocation ?? GeoPoint(latitude: 0, longitude: 0),
            "eventTags": createEventPage.selectedTags.map { Firestore.firestore().collection("tags").document($0) },
            "pictures": imageUrls // Update with new or existing images
        ]

        Firestore.firestore().collection("events").document(eventId).updateData(updatedData) { [weak self] error in
            if let error = error {
                print("Error updating event: \(error)")
                return
            }

            print("Event updated successfully")
            NotificationCenter.default.post(name: Notification.Name("editFromEditScreen"), object: nil)
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    private func validateInputs() -> Bool {
        // Validate Event Name
        guard let name = createEventPage.textFieldName.text, !name.isEmpty else {
            showDetailsInAlert(errorMessage: "Event name is required.")
            return false
        }

        // Validate Start and End Dates
        let startDate = createEventPage.datePickerStartTime.date
        let endDate = createEventPage.datePickerEndTime.date
        if startDate >= endDate {
            showDetailsInAlert(errorMessage: "Start time must be earlier than end time.")
            return false
        }

        // Validate Location
        guard createEventPage.selectedLocation != nil else {
            showDetailsInAlert(errorMessage: "Please select a location for the event.")
            return false
        }

        // Validate Tags
        if createEventPage.selectedTags.isEmpty {
            showDetailsInAlert(errorMessage: "Please add at least one tag for the event.")
            return false
        }

        // Validate Images
        if selectedImages.isEmpty && eventToEdit?.pictures.isEmpty ?? true {
            showDetailsInAlert(errorMessage: "Please add at least one image for the event.")
            return false
        }

        return true // All validations passed
    }
    
    private func uploadImages(completion: @escaping ([String]) -> Void) {
        let storage = Storage.storage()
        var uploadedImageURLs = [String]()
        let dispatchGroup = DispatchGroup()

        for image in selectedImages {
            dispatchGroup.enter()
            let imageRef = storage.reference().child("events/\(UUID().uuidString).jpg")
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                imageRef.putData(imageData, metadata: nil) { _, error in
                    if let error = error {
                        print("Error uploading image: \(error)")
                        dispatchGroup.leave()
                        return
                    }
                    imageRef.downloadURL { url, error in
                        if let url = url {
                            uploadedImageURLs.append(url.absoluteString)
                        }
                        dispatchGroup.leave()
                    }
                }
            } else {
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(uploadedImageURLs)
        }
    }


}

extension CreateEventViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            selectedImages.append(image)
            createEventPage.imageViewSelected.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension CreateEventViewController: LocationPickerDelegate {
    func didPickLocation(latitude: Double, longitude: Double) {
        print("Selected location: \(latitude), \(longitude)")
        createEventPage.selectedLocation = GeoPoint(latitude: latitude, longitude: longitude)
        createEventPage.labelSelectedLocation.text = "Lat: \(latitude), Long: \(longitude)"
    }
}

extension CreateEventViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let tag = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !tag.isEmpty else {
            return false
        }
        createEventPage.selectedTags.append(tag)
        createEventPage.collectionViewTags.reloadData()
        textField.text = "" // Clear the text field
        return true
    }
}


extension CreateEventViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return createEventPage.selectedTags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! TagCell
        cell.label.text = createEventPage.selectedTags[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let tag = createEventPage.selectedTags[indexPath.item]
        let width = tag.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]).width + 20
        return CGSize(width: width, height: 30)
    }
}

extension CreateEventViewController:ProgressSpinnerDelegate{
    func showActivityIndicator(){
        addChild(childProgressView)
        view.addSubview(childProgressView.view)
        childProgressView.didMove(toParent: self)
    }
    
    func hideActivityIndicator(){
        childProgressView.willMove(toParent: nil)
        childProgressView.view.removeFromSuperview()
        childProgressView.removeFromParent()
    }
}
