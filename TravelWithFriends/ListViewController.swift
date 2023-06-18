import UIKit

protocol ReloadDelegate: AnyObject {
  func reload()
}

class ListViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {

  enum ListType {
    case people
    case blowling
    case cinema
    case pool
  }

  @IBOutlet weak var tableView: UITableView!

  let segueIdentifier = "PresentEditVC"

  var item: ObjectLocation?

  var actionType: EditViewController.ActionType = .add

  var listType: ListType = .people

  var people: [ObjectLocation] {
    switch listType {
    case .people:
      return People.people
    case .blowling:
      return Activities.bowlings
    case .cinema:
      return Activities.cinemas
    case .pool:
      return Activities.pools
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.dataSource = self
    tableView.delegate = self
    
    // Create a UIBarButtonItem for the dismiss or back button
    let dismissButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissButtonTapped))

    let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))

    // Add the dismiss or back button to the left side of the navigation bar
    navigationItem.leftBarButtonItem = dismissButton

    navigationItem.rightBarButtonItem = addButton
  }

  @objc func dismissButtonTapped() {
    dismiss(animated: true, completion: nil)
  }

  @objc func addButtonTapped() {
    actionType = .add
    performSegue(withIdentifier: segueIdentifier, sender: self)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == segueIdentifier {

      if let navigationController = segue.destination as? UINavigationController,
         let destinationVC = navigationController.topViewController as? EditViewController {

        destinationVC.actionType = actionType
        destinationVC.editableObject = item
        destinationVC.reloadDelegate = self
        destinationVC.editableItemType = listType
      }
    }
  }

  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // Return the number of rows you want to display
    return people.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "People", for: indexPath) as! FriendTableViewCell
    cell.friendName?.text = people[indexPath.row].title
    cell.friendLocation?.text = people[indexPath.row].coordinate.latitude.description + " " + people[indexPath.row].coordinate.longitude.description
    return cell
  }
  
  // MARK: - UITableViewDelegate methods
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let item = people[indexPath.row]
    self.item = item

    actionType = .edit
    performSegue(withIdentifier: segueIdentifier, sender: self)
  }
  
}

extension ListViewController: ReloadDelegate {
  func reload() {
    tableView.reloadData()
  }
}
