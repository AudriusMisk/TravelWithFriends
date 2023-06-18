import UIKit

class ActivitiesViewController: UIViewController {

  var listType: ListViewController.ListType = .blowling

    let listId = "navigateToGenericList"

  override func viewDidLoad() {
    super.viewDidLoad()

    let dismissButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissButtonTapped))
    navigationItem.leftBarButtonItem = dismissButton
  }

  @objc func dismissButtonTapped() {
      dismiss(animated: true, completion: nil)
  }

    @IBAction func bowlingTapped(_ sender: Any) {
      listType = .blowling
      performSegue(withIdentifier: listId, sender: self)
    }

    @IBAction func cinemaTapped(_ sender: Any) {
      listType = .cinema
      performSegue(withIdentifier: listId, sender: self)
    }

    @IBAction func poolTapped(_ sender: Any) {
      listType = .pool
      performSegue(withIdentifier: listId, sender: self)
    }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == listId {

      if let navigationController = segue.destination as? UINavigationController,
         let destinationVC = navigationController.topViewController as? ListViewController {

        destinationVC.listType = listType
      }
    }
  }
}
