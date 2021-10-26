import Foundation

protocol ProductReviewDelegate: AnyObject {
    func didFetchReviewList()
    func failedFetchingReviewList(with error: NetworkError)
    
    func didReportProduct()
    func failedReportingProduct(with error: NetworkError)
}


class ProductReviewViewModel {
    
    //MARK: - Properties
    
    private var productManager: ProductManager?
    private var reportManager: ReportManager?
    
    weak var delegate: ProductReviewDelegate?
    
    var productId: Int?
    
    var reviewList: [ProductReviewResponseDTO] = []
    
    var isFetchingData: Bool = false
    var cursor: Int = 0
    
    //MARK: - Initialization
    init(productManager: ProductManager, reportManager: ReportManager, productId: Int) {
        self.productManager = productManager
        self.reportManager = reportManager
        self.productId = productId
    }
    
    //MARK: - Methods
    
    func fetchReviewList() {
     
        isFetchingData = true
        
        productManager?.getProductReviews(
            page: cursor,
            productId: productId ?? 1
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let reviewList):
                if reviewList.isEmpty {
                    self.delegate?.didFetchReviewList()
                    return
                }
                self.cursor = reviewList.last?.reviewId ?? 0
                self.isFetchingData = false
                self.reviewList.append(contentsOf: reviewList)
                self.delegate?.didFetchReviewList()
            case .failure(let error):
                self.isFetchingData = false
                self.delegate?.failedFetchingReviewList(with: error)
            }
        }
    }
    
    func reportProduct(type: ReportType.Product) {
        
        #warning("model DTO replyId 말고 별도로 수정")
        let model = ReportDTO(createdBy: User.shared.userUid, reason: type.rawValue, mallId: productId ?? 0)
        
        reportManager?.report(
            type: .product(type),
            model: model
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.delegate?.didReportProduct()
            case .failure(let error):
                self.delegate?.failedReportingProduct(with: error)
            }
        }
    }
    
    func refreshTableView() {
        resetValues()
        fetchReviewList()
    }
    
    func resetValues() {
        reviewList.removeAll()
        isFetchingData = false
        cursor = 0
    }
}