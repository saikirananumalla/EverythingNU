import Foundation
import FirebaseFirestore

struct GeoLocation: Codable {
    
    @DocumentID var id: String?
    var latitude: Double
    var longitude: Double

    init(geoPoint: GeoPoint) {
        self.latitude = geoPoint.latitude
        self.longitude = geoPoint.longitude
    }
}

