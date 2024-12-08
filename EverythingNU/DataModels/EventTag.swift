import Foundation
import FirebaseFirestore

struct EventTag: Codable, Identifiable {
    
    @DocumentID var id: String?
    var name: String
    
}

