import Foundation

protocol ProductReviewDelegate: AnyObject {
    func didFetchReviewList()
    func failedFetchingReviewList(with error: NetworkError)
    
    func didDeleteReview()
    func didCompleteReport()
    func didBlockUser()
    
    func failedUserRequest(with error: NetworkError)
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
    
    // 제품에 문제가 있음을 신고
    func reportProduct(type: ReportType.Product) {
        
        let model = ReportDTO(reason: type.rawValue, productId: productId ?? 0)
        
        reportManager?.report(
            type: .product(type),
            model: model
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.delegate?.didCompleteReport()
            case .failure(let error):
                self.delegate?.failedUserRequest(with: error)
               
            }
        }
    }
    
    
    func deleteMyReview(reviewId: Int) {
        
        productManager?.deleteReview(reviewId: reviewId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success: self.delegate?.didDeleteReview()
            case .failure(let error): self.delegate?.failedUserRequest(with: error)
            }
        }
    }
    
    func reportReview(type: ReportType.Review, reviewId: Int) {
        
        let model = ReportDTO(reason: type.rawValue, reviewId: reviewId)
        
        reportManager?.report(
            type: .review(type),
            model: model
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.delegate?.didCompleteReport()
            case .failure(let error):
                self.delegate?.failedUserRequest(with: error)
            }
        }
    }
    
    
    func blockUser(targetUserId: String) {
        
        reportManager?.blockUser(targetUserId: targetUserId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.delegate?.didCompleteReport()
            case .failure(let error):
                self.delegate?.failedUserRequest(with: error)
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
