import MapKit
import CoreLocation

class LocationManager {

  static func makeSearchRegion() -> MKCoordinateRegion {

    let vilniusCenter = CLLocation(latitude: 54.689040, longitude: 25.268674)
    let region = MKCoordinateRegion(
      center: vilniusCenter.coordinate,
      latitudinalMeters: 15000,
      longitudinalMeters: 15000)

    return region
  }
}
