import UIKit
import MapKit
import Algorithms
import CoreLocation

class MapViewController: UIViewController {

  @IBOutlet weak var cinemaButton: UIButton!
  @IBOutlet weak var poolButton: UIButton!
  @IBOutlet weak var bowlingButton: UIButton!
  @IBOutlet private var mapView: MKMapView!
  @IBOutlet weak var closeButton: UIButton!

  let locationManager = CLLocationManager()

  private var objectLocations: [ObjectLocation] = []
  
  enum ActivityType {
    case bowling
    case cinema
    case pool
  }
  
  func distance(from location1: CLLocation, to location2: CLLocation) -> CLLocationDistance {
    return location1.distance(from: location2)
  }

  func calc(activityType:ActivityType){
    let activities: [ObjectLocation]
    switch activityType {
    case .bowling:
      activities = Activities.bowlings
    case .cinema:
      activities = Activities.cinemas
    case .pool:
      activities = Activities.pools
    }

    let startLocation = People.myLocation
    let people = People.people

    let locations: [ObjectLocation] = [startLocation] + people + activities
    
    objectLocations = locations

    let permutations = people.permutations(ofCount: people.count).map { Array($0) }
    var possibleRoutes = [[ObjectLocation]]()

    for a in activities {
      for p in permutations {
        let route: [ObjectLocation] = [startLocation] + p + [a]
        possibleRoutes.append(route)
      }
    }

    findRoute(routes: possibleRoutes)
  }
  
  func findRoute(routes:[[ObjectLocation]]) {
    var shortestRoute:[ObjectLocation] = []
    var shortestLength: Double = 0
    for route in routes{
      var length: Double = 0
      for i in 1..<route.count{
        let previousLocation = route[i-1]
        let currentLocation = route[i]

        let currentCLLocation = CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        let previousCLLocation = CLLocation(latitude: previousLocation.coordinate.latitude, longitude: previousLocation.coordinate.longitude)
        
        let distanceBetweenLocations = distance(from: previousCLLocation, to: currentCLLocation)
        length = length + distanceBetweenLocations
      }
      if (shortestLength == 0 || shortestLength > length){
        shortestLength = length
        shortestRoute = route
        
      }
    }
    print("shortestlength:", shortestLength)
    print("shortest route:", shortestRoute)
    self.mapView.removeOverlays(self.mapView.overlays)
    
    //kelio vaizdavimas
    if shortestRoute.count > 1 {
      for i in 0..<shortestRoute.count-1 {
        let sourcePlacemark = MKPlacemark(coordinate: shortestRoute[i].coordinate)
        let destinationPlacemark = MKPlacemark(coordinate: shortestRoute[i+1].coordinate)

        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)

        let directionsRequest = MKDirections.Request()
        directionsRequest.source = sourceMapItem
        directionsRequest.destination = destinationMapItem
        directionsRequest.transportType = .automobile

        let directions = MKDirections(request: directionsRequest)
        directions.calculate { response, error in
          guard let route = response?.routes.first else {
            if let error = error {
              print("Error calculating route:", error.localizedDescription)
            }
            return
          }
          // nubrezia route
          self.mapView.addOverlay(route.polyline)
        }
      }
    }
    
  }
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if let polylineOverlay = overlay as? MKPolyline {
      let renderer = MKPolylineRenderer(overlay: polylineOverlay)
      renderer.strokeColor = UIColor.red
      renderer.lineWidth = 3
      return renderer
    }

    return MKOverlayRenderer(overlay: overlay)
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    bowlingButton.addTarget(self, action: #selector(bowlingClicked), for: .touchUpInside)
    cinemaButton.addTarget(self, action: #selector(cinemaClicked), for: .touchUpInside)
    poolButton.addTarget(self, action: #selector(poolClicked), for: .touchUpInside)
    closeButton.addTarget(self, action: #selector(closeClicked), for: .touchUpInside)


    // setinu initiallocationa
    let initialLocation = CLLocation(latitude: 54.702593, longitude: 25.288330)
    mapView.centerToLocation(initialLocation)
    
    let vilniusCenter = CLLocation(latitude: 54.689040, longitude: 25.268674)
    let region = MKCoordinateRegion(
      center: vilniusCenter.coordinate,
      latitudinalMeters: 50000,
      longitudinalMeters: 60000)
    mapView.setCameraBoundary(
      MKMapView.CameraBoundary(coordinateRegion: region),
      animated: true)
    
    let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 200000)
    mapView.setCameraZoomRange(zoomRange, animated: true)
    
    mapView.delegate = self
    
    mapView.register(
      LocationMarkerView.self,
      forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)

    setupLocationTracking()
  }

  private func setupLocationTracking() {

    // Set up the location manager
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest

    // Request location authorization
    locationManager.requestWhenInUseAuthorization()

    // Check if location services are enabled
    if CLLocationManager.locationServicesEnabled() {
      locationManager.startUpdatingLocation()
    }
  }

  
  @objc func bowlingClicked() {
    calc(activityType: .bowling)
    mapView.addAnnotations(objectLocations)
  }

  @objc func cinemaClicked() {
    calc(activityType: .cinema)
    mapView.addAnnotations(objectLocations)
  }

  @objc func poolClicked() {
    calc(activityType: .pool)
    mapView.addAnnotations(objectLocations)
  }

  @objc func closeClicked() {
    dismiss(animated: true)
  }

}


private extension MKMapView {
  func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 5000) {
    let coordinateRegion = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}

extension MapViewController: MKMapViewDelegate {
  func mapView(
    _ mapView: MKMapView,
    annotationView view: MKAnnotationView,
    calloutAccessoryControlTapped control: UIControl
  ) {
    guard let location = view.annotation as? ObjectLocation else {
      return
    }
    
    let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
    location.mapItem?.openInMaps(launchOptions: launchOptions)
  }
}

extension MapViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.last {
      // Set the map view's region to display the user's current location
      //          let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
      //          mapView.setRegion(region, animated: true)

      // Stop updating location once it's obtained
      //locationManager.stopUpdatingLocation()
    }
  }
}
