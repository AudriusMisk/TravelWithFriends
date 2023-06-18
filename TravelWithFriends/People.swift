import UIKit
import CoreLocation

class People {
  
  static var people:[ObjectLocation] = initializePersons()

  static var myLocation: ObjectLocation = initializeStartLocation()

  static func initializeStartLocation() -> ObjectLocation {
      let startLocation = ObjectLocation(
          title: "Me",
          locationType: .starting,
          coordinate: CLLocationCoordinate2D(latitude: 54.728395, longitude: 25.296547)
      )
      return startLocation
  }

  static func initializePersons() -> [ObjectLocation] {
    let personOne = ObjectLocation(
      title: "Jonas",
      locationType: .person,
//      coordinate: CLLocationCoordinate2D(latitude: 54.717594, longitude: 25.284990)
      coordinate: CLLocationCoordinate2D(latitude: 54.717834, longitude: 25.275935)
    )

    let personTwo = ObjectLocation(
      title: "Petras",
      locationType: .person,
//      coordinate: CLLocationCoordinate2D(latitude: 54.712715, longitude: 25.303593)
      coordinate: CLLocationCoordinate2D(latitude: 54.695779, longitude: 25.254486)
    )

    let personThree = ObjectLocation(
      title: "Rimas",
      locationType: .person,
//      coordinate: CLLocationCoordinate2D(latitude: 54.728395, longitude: 25.296547)
      coordinate: CLLocationCoordinate2D(latitude: 54.704188, longitude: 25.289978)
    )

    return [personOne, personTwo, personThree]
  }

  static func add(name: String, coordinate: CLLocationCoordinate2D) {
    let person = ObjectLocation(title: name, locationType: .person, coordinate: coordinate)
    people.append(person)
  }
}
