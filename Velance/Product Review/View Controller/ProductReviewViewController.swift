import UIKit
import ImageSlideshow
import SDWebImage
import SnapKit

class ProductReviewViewController: UIViewController, Storyboarded {
    
    @IBOutlet weak var productThumbnailImageView: UIImageView!
    @IBOutlet weak var topImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var dragIndicator: UIView!
    @IBOutlet weak var reviewTableView: UITableView!
    
    var productId: Int?
    var productThumbnailUrl: URL?
    var productName: String?
    var rating: Int?
    var price: Int?
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        
        static let topImageViewMaxHeight: CGFloat = 280
        static let topImageViewMinHeight: CGFloat = 100
        static var startingTopImageViewHeight: CGFloat = topImageViewMaxHeight
    }
    
    
    static var storyboardName: String {
        StoryboardName.productReview
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        bottomView.backgroundColor = .white
    }
    
}

//MARK: - IBActions & Target Methods

extension ProductReviewViewController {
    
    @objc private func pressedOptionsBarButtonItem() {
        
        let reportAction = UIAlertAction(
            title: "잘못된 정보 수정 요청",
            style: .default
        ) { [weak self] _ in
            guard let self = self else { return }
            
        }
        let actionSheet = UIHelper.createActionSheet(with: [reportAction], title: nil)
        present(actionSheet, animated: true)
    }
    
    @objc private func pressedAddReviewButton() {
        guard let vc = NewProductReviewViewController.instantiate() as? NewProductReviewViewController else { return }
        vc.productId = productId ?? 0
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource

extension ProductReviewViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CellID.productReviewTVC,
            for: indexPath
        ) as? ProductReviewTableViewCell else { return ProductReviewTableViewCell() }
        
        var imageSources: [InputSource] = []
        imageSources.append(SDWebImageSource(url: URL(string: "https://picsum.photos/1200/1200")!))
        
        cell.currentVC = self
        cell.reviewLabel.text = "꽤 괜찮았습니다! 다만 가격이 조금 나가서 매번 사기에는 부담스러워요. 괜찮았습니다! 다만 가격이 조금 나가서 매번 사기에는 부담스러워요 괜찮았습니다! 다만 가격이 조금 나가서 매번 사기에는 부담스러워요 괜찮았습니다! 다만 가격이 조금."
        cell.dateLabel.text = "2021.03.24"
        cell.reviewImageSlideShow.setImageInputs(imageSources)
        
        
        return cell
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        topImageViewHeight.constant = Metrics.topImageViewMinHeight
        
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y <= 0 {
            
            topImageViewHeight.constant = Metrics.topImageViewMaxHeight
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            })
            
        }
    }
}

//MARK: - UIPanGestureRecognizer Methods

extension ProductReviewViewController {
    
    private func nearest(to number: CGFloat, inValues values: [CGFloat]) -> CGFloat {
        guard let nearestVal = values.min(by: { abs(number - $0) < abs(number - $1) }) else { return number }
        return nearestVal
    }
    
    private func changeTopImageViewHeight(to height: CGFloat, option: UIView.AnimationOptions) {
        topImageViewHeight.constant = height
        
        UIView.animate(withDuration: 0.2, delay: 0, options: option, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc private func viewPanned(_ panGestureRecognizer: UIPanGestureRecognizer) {
        let translation = panGestureRecognizer.translation(in: self.view)
        let velocity = panGestureRecognizer.velocity(in: self.view)
        
        switch panGestureRecognizer.state {
        case .began:
            Metrics.startingTopImageViewHeight = topImageViewHeight.constant
        case .changed:
            let modifiedTopClearViewHeight = Metrics.startingTopImageViewHeight + translation.y
            if modifiedTopClearViewHeight > Metrics.topImageViewMinHeight && modifiedTopClearViewHeight < Metrics.topImageViewMaxHeight {
                topImageViewHeight.constant = modifiedTopClearViewHeight
            }
        case .ended:
            if velocity.y > 1500 {
                changeTopImageViewHeight(to: Metrics.topImageViewMaxHeight, option: .curveEaseOut)
            } else if velocity.y < -1500 {
                changeTopImageViewHeight(to: Metrics.topImageViewMinHeight, option: .curveEaseOut)
            } else {
                let nearestVal = nearest(to: topImageViewHeight.constant, inValues: [Metrics.topImageViewMaxHeight, Metrics.topImageViewMinHeight])
                changeTopImageViewHeight(to: nearestVal, option: .curveEaseIn)
            }
        default:
            break
        }
    }
    
}


//MARK: - UI Configuration & Initialization

extension ProductReviewViewController {
    
    private func configure() {
        configureProductThumbnailImageView()
        configureDragIndicator()
        configurePanGestureRecognizer()
        configureTableView()
        addOptionsBarButtonItem()
        addFloatingButton()

    }
    
    private func configureProductThumbnailImageView() {
        productThumbnailImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        productThumbnailImageView.sd_setImage(
            with: productThumbnailUrl,
            placeholderImage: nil,
            options: .continueInBackground
        )
    }
    
    private func configureDragIndicator() {
        dragIndicator.layer.cornerRadius = dragIndicator.frame.height / 2
    }
    
    private func configurePanGestureRecognizer() {
        let panGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(viewPanned(_:))
        )
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)
    }
    
    private func configureTableView() {
        reviewTableView.delegate = self
        reviewTableView.dataSource = self
        reviewTableView.separatorStyle = .none
        reviewTableView.allowsSelection = false
        
        let headerView = ProductReviewHeaderView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 250))
        
        headerView.configure(
            productName: self.productName ?? "로딩 중..",
            rating: self.rating ?? 0,
            price: self.price ?? 0
        )
        let panGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(viewPanned(_:))
        )
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        headerView.addGestureRecognizer(panGesture)
        
        reviewTableView.tableHeaderView = headerView
        
        
        let reviewTableViewCell = UINib(
            nibName: XIB_ID.productReviewTVC,
            bundle: nil
        )
        
        reviewTableView.register(
            reviewTableViewCell,
            forCellReuseIdentifier: CellID.productReviewTVC
        )
        
        reviewTableView.rowHeight = UITableView.automaticDimension
        reviewTableView.estimatedRowHeight = 350
    }
    
    private func addOptionsBarButtonItem() {
        let optionsBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            style: .plain,
            target: self,
            action: #selector(pressedOptionsBarButtonItem)
        )
        navigationItem.rightBarButtonItem = optionsBarButtonItem
    }
    
    private func addFloatingButton() {
        let addReviewButton = VLFloatingButton()
        addReviewButton.setImage(UIImage(systemName: "pencil"), for: .normal)
        addReviewButton.addTarget(
            self,
            action: #selector(pressedAddReviewButton),
            for: .touchUpInside
        )
        view.addSubview(addReviewButton)
        addReviewButton.snp.makeConstraints { make in
            make.width.height.equalTo(60)
            make.right.equalTo(view.snp.right).offset(-25)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-35)
        }
    }
    
}
