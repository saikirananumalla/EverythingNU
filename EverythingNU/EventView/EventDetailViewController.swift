//
//  EventDetailViewController.swift
//  final
//
//  Created by Sai Kiran Anumalla on 06/12/24.
//


import UIKit
import MapKit
import FirebaseAuth
import FirebaseFirestore

class EventDetailViewController: UIViewController {

    let detailView = EventDetailView()
    var event: Event! // Pass the event data from the homepage
    var currentUserID: String? {
        return Auth.auth().currentUser?.uid
    }

    override func loadView() {
        view = detailView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        listenToEventChanges()
        
        detailView.eventChatButton.addTarget(self, action: #selector(onEventChatButtonTapped), for: .touchUpInside)
        
        detailView.navigateButton.addTarget(self, action: #selector(navigateToLocation), for: .touchUpInside)
        detailView.rsvpButton.addTarget(self, action: #selector(onRSVPButtonTapped), for: .touchUpInside)
        updateRSVPButton()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onEventUpdated(_:)), name: Notification.Name("editFromEditScreen"), object: nil)

        
        detailView.editButton.addTarget(self, action: #selector(onEditButtonTapped), for: .touchUpInside)
        detailView.deleteButton.addTarget(self, action: #selector(onDeleteButtonTapped), for: .touchUpInside)

        configureButtonsVisibility()
        populateEventDetails()
    }
    
    @objc func onEventChatButtonTapped() {
        guard let eventId = event?.id, let eventName = event?.name else { return }
        let chatVC = EventChatViewController(eventId: eventId, eventName: eventName)
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    @objc private func navigateToLocation() {
        guard let event = event else { return }
        let coordinate = CLLocationCoordinate2D(latitude: event.location.latitude, longitude: event.location.longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = event.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    private func updateRSVPButton() {
       guard let userID = currentUserID else { return }
       let isRSVPed = event.rsvpList.contains(where: { $0.documentID == userID })
       detailView.rsvpButton.setTitle(isRSVPed ? "Un-RSVP" : "RSVP", for: .normal)
       detailView.rsvpButton.backgroundColor = isRSVPed ? .systemRed : .systemBlue
   }
    
    @objc private func onRSVPButtonTapped() {
        guard let eventID = event.id, let userID = currentUserID else { return }

        let eventRef = Firestore.firestore().collection("events").document(eventID)
        let isRSVPed = event.rsvpList.contains(where: { $0.documentID == userID })

        // Add or remove RSVP
        let update = isRSVPed
            ? FieldValue.arrayRemove([Firestore.firestore().collection("users").document(userID)])
            : FieldValue.arrayUnion([Firestore.firestore().collection("users").document(userID)])

        eventRef.updateData(["rsvpList": update]) { [weak self] error in
            if let error = error {
                print("Error updating RSVP: \(error)")
                return
            }
            print("RSVP updated successfully")
            // Update the local model and UI
            if isRSVPed {
                self?.event.rsvpList.removeAll { $0.documentID == userID }
            } else {
                let userRef = Firestore.firestore().collection("users").document(userID)
                self?.event.rsvpList.append(userRef)
            }
            self?.updateRSVPButton()
            self?.populateEventDetails()
        }
    }
    
    @objc func onEventUpdated(_ notification: Notification) {
        reloadEventDetails()
    }
    
    func reloadEventDetails() {
        Firestore.firestore().collection("events").document(event.id ?? "").getDocument { [weak self] document, error in
            if let document = document, let updatedEvent = try? document.data(as: Event.self) {
                self?.event = updatedEvent
                self?.updateUI()
            }
        }
    }
    
    func updateUI() {
        guard let event = event else { return }

        detailView.nameLabel.text = event.name
        detailView.descriptionLabel.text = event.description
        detailView.dateTimeLabel.text = "From \(event.startTime.dateValue().formatted()) to \(event.endTime.dateValue().formatted())"
        let tagReferences = event.eventTags
        var tagString = ""
        let dispatchGroup = DispatchGroup()
        for tagRef in tagReferences {
            dispatchGroup.enter()
            tagRef.getDocument { document, error in
                if let document = document, let tagName = document.data()?["name"] as? String {
                    tagString = tagString + " " + tagName.lowercased()
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.detailView.tagsLabel.text = "Tags: \(tagString)"
        }
        detailView.rsvpLabel.text = "RSVP Count: \(event.rsvpList.count)"
        
        let coordinate = CLLocationCoordinate2D(latitude: event.location.latitude, longitude: event.location.longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        detailView.locationMap.removeAnnotations(detailView.locationMap.annotations)
        detailView.locationMap.addAnnotation(annotation)
        detailView.locationMap.setCenter(coordinate, animated: true)

        if let imageUrl = event.pictures.first {
            fetchImage(from: imageUrl) { [weak self] image in
                self?.detailView.imageView.image = image
            }
        }
    }
    
    func configureButtonsVisibility() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let createdByUserId = event.createdBy?.documentID

        let isOwner = currentUserId == createdByUserId
        detailView.editButton.isHidden = !isOwner
        detailView.deleteButton.isHidden = !isOwner
    }

    private func populateEventDetails() {
        detailView.nameLabel.text = event.name
        detailView.descriptionLabel.text = event.description
        detailView.dateTimeLabel.text = "From \(event.startTime.dateValue()) to \(event.endTime.dateValue())"

        // Show the location on the map
        let coordinate = CLLocationCoordinate2D(latitude: event.location.latitude, longitude: event.location.longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        detailView.locationMap.addAnnotation(annotation)
        detailView.locationMap.setRegion(MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500), animated: false)
        
        let tagReferences = event.eventTags
        var tagString = ""
        let dispatchGroup = DispatchGroup()
        for tagRef in tagReferences {
            dispatchGroup.enter()
            tagRef.getDocument { document, error in
                if let document = document, let tagName = document.data()?["name"] as? String {
                    tagString = tagString + " " + tagName.lowercased()
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.detailView.tagsLabel.text = "Tags: \(tagString)"
        }


        // Show RSVP list
        detailView.rsvpLabel.text = "RSVP: \(event.rsvpList.count) people"

        // Show the first image (if available)
        if let imageURL = event.pictures.first {
            fetchImage(from: imageURL) { [weak self] image in
                self?.detailView.imageView.image = image
            }
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
    
    @objc func onEditButtonTapped() {
        let editEventVC = CreateEventViewController()
        editEventVC.eventToEdit = event
        navigationController?.pushViewController(editEventVC, animated: true)
    }

    @objc func onDeleteButtonTapped() {
        let alert = UIAlertController(title: "Delete Event", message: "Are you sure you want to delete this event?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deleteEvent()
        }))
        present(alert, animated: true)
    }

    func deleteEvent() {
        guard let eventId = event.id else { return }

        Firestore.firestore().collection("events").document(eventId).delete { [weak self] error in
            if let error = error {
                print("Error deleting event: \(error)")
                return
            }

            print("Event deleted successfully")
            NotificationCenter.default.post(name: Notification.Name("deleteFromDetailScreen"), object: nil)
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    private func listenToEventChanges() {
        guard let eventID = event.id else { return }
        Firestore.firestore().collection("events").document(eventID)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let snapshot = snapshot, let updatedEvent = try? snapshot.data(as: Event.self) else {
                    print("Error fetching event updates: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                self?.event = updatedEvent
                self?.populateEventDetails()
            }
    }

}
