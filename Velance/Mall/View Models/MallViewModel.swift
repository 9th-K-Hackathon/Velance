import Foundation

protocol MallViewModelDelegate: AnyObject {
    func didFetchMenuList()
    func failedFetchingMenuList(with error: NetworkError)
}

class MallViewModel {
    
    weak var delegate: MallViewModelDelegate?
    
    // 수정
    var mallId: Int?
    
    var menuList: [MallMenuResponseDTO] = []
    
    var isFetchingData: Bool = false
    var page: Int = 0
    
    func fetchMenuList() {
        
        isFetchingData = true
        
        MallManager.shared.getMallMenuList(
            page: page,
            mallId: mallId ?? 1
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let menuList):
                if menuList.isEmpty {
                    self.delegate?.didFetchMenuList()
                    return
                }
                self.page = menuList.last?.menuId ?? 0
                self.isFetchingData = false
                self.menuList.append(contentsOf: menuList)
                self.delegate?.didFetchMenuList()
                
            case .failure(let error):
                self.isFetchingData = false
                self.delegate?.failedFetchingMenuList(with: error)
                
            }
        }
        
    }
    
    func refreshTableView() {
        resetValues()
        fetchMenuList()
    }
    
    func resetValues() {
        menuList.removeAll()
        isFetchingData = false
        page = 0
    }
    
}