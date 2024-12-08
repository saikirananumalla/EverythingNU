import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable {
    
    @DocumentID var id: String?
    var name: String
    var emailId: String
    // This is the location of the profile picture in firestore bucket.
    var profilePicture: String
    var createdByYou: [DocumentReference]
    var rsvpByYou: [DocumentReference]
    
}

