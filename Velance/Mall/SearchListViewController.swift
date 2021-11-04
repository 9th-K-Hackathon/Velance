import UIKit
import PanModal

protocol SearchListDelegate {
    func didChoosePlace(index: Int)
}

class SearchListViewController: UITableViewController {

    @IBOutlet var searchResultTableView: UITableView!
    
    var placeName: [String] = [String]()
    var address: [String] = [String]()
    var searchResultCount: Int = 0
    
    var delegate: SearchListDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchResultTableView.delegate = self
        searchResultTableView.dataSource = self
    }
}

//MARK: - SearchListViewController

extension SearchListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeName.count > 0 ? placeName.count : 1
    }
 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "searchedRestaurantResultCell"
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: cellIdentifier
        ) else { return UITableViewCell() }
    
        if placeName.count != 0 {
            cell.textLabel?.text = placeName[indexPath.row]
            cell.detailTextLabel?.text = address[indexPath.row]
        }
        else {
            cell.textLabel?.text = "검색 결과가 없습니다.🤔"
            cell.detailTextLabel?.text = "매장명을 다시 한 번 확인해주세요."
            tableView.tableFooterView = UIView(frame: .zero)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if searchResultCount == 0 { return }
        delegate?.didChoosePlace(index: indexPath.row)
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

}

extension SearchListViewController: PanModalPresentable {
    
    var panScrollable: UIScrollView? {
        return searchResultTableView
    }
    
    var shortFormHeight: PanModalHeight {
        let count = CGFloat(placeName.count)
        return .contentHeight(80 * count)
    }
    
    var longFormHeight: PanModalHeight {
        return .maxHeightWithTopInset(50)
    }
}
