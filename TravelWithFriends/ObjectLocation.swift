import Foundation
import MapKit

class ObjectLocation: NSObject, MKAnnotation {
  
  override var description: String{
    return title ?? "0"
  }
  
  enum LocationType: String {
    case starting = "Starting"
    case person = "Person"
    case activity = "Activity"
    
  }

  let id: UUID
  var title: String?
  let locationType: LocationType
  var coordinate: CLLocationCoordinate2D
  
  init(
    title: String?,
    locationType: LocationType,
    coordinate: CLLocationCoordinate2D
  ) {
    self.title = title
    self.locationType = locationType
    self.coordinate = coordinate
    self.id = UUID()

    super.init()
  }
  
  var subtitle: String? {
    return locationType.rawValue
  }
  
  var mapItem: MKMapItem? {
    let placemark = MKPlacemark(
      coordinate: coordinate)
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.name = title
    return mapItem
  }
  
  var markerTintColor: UIColor  {
    switch locationType{
    case .starting:
      return .red
    case .activity:
      return .yellow
    case .person:
      return .blue
    }
  }
  
  var image: UIImage {
    switch locationType {
    case .starting:
      return #imageLiteral(resourceName: "Monument")
    case .person:
      return #imageLiteral(resourceName: "Sculpture")
    case .activity:
      return #imageLiteral(resourceName: "Plaque")
    }
  }
}

