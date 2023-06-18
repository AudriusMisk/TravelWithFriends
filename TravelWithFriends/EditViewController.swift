import UIKit
import CoreLocation
import MapKit

class EditViewController: UIViewController {

  enum ActionType {
    case edit
    case add
  }

  let geocoder = CLGeocoder()

  @IBOutlet weak var nameTextField: UITextField!

  @IBOutlet weak var addressTextField: UITextField!

  @IBOutlet weak var locateButton: UIButton!

  @IBOutlet weak var coordinatesTextField: UITextField!

  @IBOutlet weak var suggestionLabel: UILabel!

  @IBOutlet weak var currentLocationButton: UIButton!

//  var objectLocationIdentifier: UUID?

  private let completer = MKLocalSearchCompleter()

  var actionType: ActionType = .add
  var objectType: ObjectLocation.LocationType = .person

  var editableObject: ObjectLocation? = nil

  var locatedLoction: CLLocationCoordinate2D?

  weak var reloadDelegate: ReloadDelegate?

  let locationManager = CLLocationManager()

//  var currentLoction: CLLocationCoordinate2D?
  var shouldShowLocateCurrentLocationButton = false

  var editableItemType: ListViewController.ListType = .people

  override func viewDidLoad() {
    super.viewDidLoad()

    completer.delegate = self

    completer.region = LocationManager.makeSearchRegion()

    suggestionLabel.addBorder()

    locateButton.addTarget(self, action: #selector(locateClicked), for: .touchUpInside)

    currentLocationButton.addTarget(self, action: #selector(currentClicked), for: .touchUpInside)

    if !shouldShowLocateCurrentLocationButton {
      currentLocationButton.isHidden = true
    }

    let dismissButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissButtonTapped))

    let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonTapped))

    navigationItem.leftBarButtonItem = dismissButton

    navigationItem.rightBarButtonItem = saveButton

    configureGestures()
    loadData()
    startLocationTracking()
  }

  func startLocationTracking() {

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

  private func loadData() {

    if actionType == .edit {
      nameTextField.text = editableObject?.title
      coordinatesTextField.text = (editableObject?.coordinate.latitude.description ?? "") + "," +  (editableObject?.coordinate.longitude.description ?? "")
    }
  }

  private func configureGestures() {

    suggestionLabel.isUserInteractionEnabled = true
    suggestionLabel.isEnabled = true

    suggestionLabel.addGestureRecognizer(
      UITapGestureRecognizer(
        target: self,
        action: #selector(suggestionTapped(_:))
      )
    )
  }

  @objc private func suggestionTapped(_ gesture: UITapGestureRecognizer) {
    addressTextField?.text = suggestionLabel.text
    locateClicked()
    suggestionLabel.text = nil
  }

  @objc func dismissButtonTapped() {
    dismiss(animated: true) {
      self.reloadDelegate?.reload()
    }
  }

  @objc func saveButtonTapped() {

    switch actionType {
    case .add:
      addObject()
    case .edit:
      updateEdit()
    }

    dismiss(animated: true) {
      self.reloadDelegate?.reload()
    }
  }

  private func updateEdit() {
    editableObject?.title = nameTextField.text

    if let locatedLoction = locatedLoction {
      editableObject?.coordinate = locatedLoction
    }
  }

  private func addObject() {
    if let locatedLoction = locatedLoction, let name = nameTextField.text {

      switch editableItemType {
      case .people:
        People.add(name: name, coordinate: locatedLoction)
      case .blowling:
        Activities.addBowling(name: name, coordinate: locatedLoction)
      case .cinema:
        Activities.addCinema(name: name, coordinate: locatedLoction)
      case .pool:
        Activities.addPool(name: name, coordinate: locatedLoction)
      }

    }
  }

  @IBAction func addressDidChange(_ sender: UITextField) {
    guard let query = sender.contents else {

      if completer.isSearching {
        completer.cancel()
      }
      return
    }

    completer.queryFragment = query

    locateClicked()
  }

  @objc func currentClicked() {
    let latitude = locatedLoction?.latitude.description ?? ""
    let longitude = locatedLoction?.longitude.description ?? ""
    let coordinates = latitude + "," + longitude

    self.coordinatesTextField.text = coordinates
  }

  @objc func locateClicked() {

    let address = addressTextField.text ?? "" //"Your Address"
    geocoder.geocodeAddressString(address) { (placemarks, error) in
      if let error = error {
        // Handle the error
        print("Geocoding error: \(error.localizedDescription)")
        return
      }

      guard let placemark = placemarks?.first,
            let location = placemark.location else {
        // Unable to geocode the address
        return
      }

      let coordinates = location.coordinate
      let latitude = coordinates.latitude
      let longitude = coordinates.longitude

      // Use the latitude and longitude as needed
      print("Latitude: \(latitude), Longitude: \(longitude)")

      self.coordinatesTextField.text = latitude.description + "," + longitude.description

      self.locatedLoction = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
  }

  private func showSuggestion(_ suggestion: String) {
    suggestionLabel.text = suggestion
    //    suggestionContainerTopConstraint.constant = -4 // to hide the top corners

    UIView.animate(withDuration: 0.25) {
      self.view.layoutIfNeeded()
    }
  }

}

extension EditViewController: MKLocalSearchCompleterDelegate {
  func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
    guard let firstResult = completer.results.first else {
      return
    }

    showSuggestion(firstResult.title)
  }

  func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
    print("Error suggesting a location: \(error.localizedDescription)")
  }
}

extension EditViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.last {
      // Set the map view's region to display the user's current location
      //          let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
      //          mapView.setRegion(region, animated: true)
      
      locatedLoction = locationManager.location?.coordinate

      // Stop updating location once it's obtained
      locationManager.stopUpdatingLocation()

    }
  }

}

extension UITextField {
  var contents: String? {
    guard
      let text = text?.trimmingCharacters(in: .whitespaces),
      !text.isEmpty
    else {
      return nil
    }

    return text
  }
}

extension UIView {
  func addBorder() {
    layer.borderWidth = 1
    layer.cornerRadius = 3
    layer.borderColor = UIColor.darkGray.cgColor
  }
}
