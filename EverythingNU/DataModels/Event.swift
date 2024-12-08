import Foundation
import FirebaseFirestore

struct Event: Codable, Identifiable {
    
    @DocumentID var id: String?
    var startTime: Timestamp
    var endTime: Timestamp
    var eventTags: [DocumentReference]
    var rsvpList: [DocumentReference]
    var name: String
    var description: String
    var pictures: [String]
    var location: GeoPoint
    var createdBy: DocumentReference?
    
}
