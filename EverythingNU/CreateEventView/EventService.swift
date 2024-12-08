//
//  EventService.swift
//  final
//
//  Created by Sai Kiran Anumalla on 06/12/24.
//

import FirebaseFirestore
import FirebaseStorage

func saveEventToFirebase(event: Event, images: [UIImage], completion: @escaping (Bool) -> Void) {
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    var imageURLs = [String]()
    let group = DispatchGroup()
    
    // Upload images to Firebase Storage
    for (index, image) in images.enumerated() {
        group.enter()
        let imageRef = storage.reference().child("events/\(UUID().uuidString)_\(index).jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        imageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                group.leave()
                return
            }
            imageRef.downloadURL { url, error in
                if let url = url {
                    imageURLs.append(url.absoluteString)
                }
                group.leave()
            }
        }
    }
    
    // Save event to Firestore after images are uploaded
    group.notify(queue: .main) {
        do {
            var eventData = try Firestore.Encoder().encode(event)
            eventData["pictures"] = imageURLs // Add image URLs to event data
            db.collection("events").addDocument(data: eventData) { error in
                if let error = error {
                    print("Error saving event: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        } catch {
            print("Error encoding event data: \(error.localizedDescription)")
            completion(false)
        }
    }
}

