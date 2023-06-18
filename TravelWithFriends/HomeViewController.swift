import UIKit

class HomeViewController: UIViewController {

  @IBAction func tapEditPeople(_ sender: Any) {
    performSegue(withIdentifier: "navigateToList", sender: self)
  }

  @IBAction func tapEditActivities(_ sender: Any) {
    performSegue(withIdentifier: "navigateToActivities", sender: self)
  }

  @IBAction func tapEditMyLocation(_ sender: Any) {
    performSegue(withIdentifier: "navigateToEdit", sender: self)
  }

  @IBAction func tapNavigate(_ sender: Any) {
    performSegue(withIdentifier: "navigateToMap", sender: self)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "navigateToEdit" {
      if let navigationController = segue.destination as? UINavigationController,
         let destinationVC = navigationController.topViewController as? EditViewController {
        
        destinationVC.editableObject = People.myLocation
        destinationVC.actionType = .edit
        destinationVC.shouldShowLocateCurrentLocationButton = true
      }
    }
  }

}
