import UIKit
import InputBarAccessoryView
import ImageSlideshow
import SnapKit

class CommunityDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputBar: VelanceInputBar!
    
    private lazy var tableHeaderView: CommunityDetailTableHeaderView = {
        let headerView = CommunityDetailTableHeaderView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 500))
        headerView.parentVC = self
        tableView.tableHeaderView = headerView
        return headerView
    }()
    
    private let viewModel = CommunityDetailViewModel()
    
    private let cellReuseIdentifier = "CommunityDetailTableViewCell"
    
    var isRecipe: Bool!
    /// recipeID or dailyLifeID
    var id: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        configureTableHeaderView()
        setupInputBar()
        configureViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // tableHeaderView Dynamic Height
        let size = tableHeaderView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        if tableHeaderView.frame.size.height != size.height {
            tableHeaderView.frame.size.height = size.height
            tableView.tableHeaderView = tableHeaderView
            tableView.layoutIfNeeded()
        }
    }
}

extension CommunityDetailViewController {
    
    private func setupInputBar() {
        inputBar.delegate = self
        inputBar.inputTextView.keyboardType = .default
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CommunityDetailTableViewCell", bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(didDragTableView), for: .valueChanged)
    }
    
    private func configureTableHeaderView() {
        tableHeaderView.contentLabel.text = viewModel.contents
        tableHeaderView.dateLabel.text = viewModel.feedDate
        tableHeaderView.usernameLabel.text = viewModel.username
        tableHeaderView.userImageView.sd_setImage(with: viewModel.userProfileImageURL,
                                                  placeholderImage: UIImage(named: "avatarImage"))
        var inputSources: [InputSource] = []
        if let urls = viewModel.imageURLs {
            let placeholderImage = UIImage(named: "imagePlaceholder")
            urls.forEach {
                inputSources.append(SDWebImageSource(url: $0, placeholder: placeholderImage))
            }
        }
        tableHeaderView.imageSlideShow.setImageInputs(inputSources)
        tableHeaderView.likeButton.setTitle("\(viewModel.likeCount)", for: .normal)
        tableHeaderView.commentButton.setTitle("\(viewModel.repliesCount)", for: .normal)
    }
    
    private func configureViewModel() {
        viewModel.delegate = self
        viewModel.fetchPostInfo(isRecipe: isRecipe, id: id)
    }
    
    @objc private func didDragTableView() {
        viewModel.fetchPostInfo(isRecipe: isRecipe, id: id)
    }
    
    @objc private func didTapMoreButton(_ sender: UIButton) {
        print("moreButton Tapped.")
    }
}

extension CommunityDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
}

extension CommunityDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfReplies
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? CommunityDetailTableViewCell else { fatalError() }
        if viewModel.numberOfReplies == 0 { return cell }
        let cellViewModel = viewModel.replyAtIndex(indexPath.row)
        
        cell.delegate = self
        cell.parentVC = self
        cell.replyId = cellViewModel.replyID
        cell.createdUserUid = cellViewModel.createdBy
        cell.moreButton.tag = indexPath.row
        cell.moreButton.addTarget(self, action: #selector(didTapMoreButton(_:)), for: .touchUpInside)
        cell.contentLabel.text = cellViewModel.contents
        cell.usernameLabel.text = cellViewModel.username
        cell.dateLabel.text = cellViewModel.replyTime
        cell.userImageView.sd_setImage(with: cellViewModel.userProfileImageURL,
                                       placeholderImage: UIImage(named: "avatarImage"))
        return cell
    }
}

extension CommunityDetailViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        let contentHeight = tableView.contentSize.height
        let frameHeight = scrollView.frame.height
        
        if contentHeight > frameHeight + 100 && contentOffsetY > contentHeight - frameHeight - 100 && viewModel.hasMore && !viewModel.isFetchingReply {
            // fetch more
            viewModel.fetchReplies()
        }
    }
}

extension CommunityDetailViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        inputBar.inputTextView.resignFirstResponder()
        guard let feedID = viewModel.feedID else {
            print("feedID is empty")
            return
        }
        viewModel.postReply(feedID: feedID, contents: text)
        inputBar.inputTextView.text = ""
    }
}

extension CommunityDetailViewController: CommunityDetailViewModelDelegate {

    func didPostReply() {
        print(#function)
        viewModel.refreshReplies()
    }
    
    func didFetchReplies() {
        tableView.reloadData()
        tableView.refreshControl?.endRefreshing()
    }
    
    func didFetchDetailInfo() {
        viewModel.refreshReplies()
        configureTableHeaderView()
        tableView.refreshControl?.endRefreshing()
    }
    
    func didDeleteReply() {
        showSimpleBottomAlert(with: "댓글 삭제를 완료했어요 🎉")
        viewModel.refreshReplies()
    }
    
    func didCompleteReport() {
        showSimpleBottomAlert(with: "신고 처리가 완료됐어요! 벨런스 팀이 검토 후 조치할게요.👍")
    }
    
    func didBlockUser() {
        showSimpleBottomAlert(with: "처리가 완료되었습니다.")
        viewModel.refreshReplies()
    }
    
    func failedUserRequest(with error: NetworkError) {
        showSimpleBottomAlert(with: error.errorDescription)
    }
}

extension CommunityDetailViewController: CommunityDetailTVCDelegate {
    
    func didChooseToReportUser(type: ReportType.Reply, replyId: Int) {
        viewModel.reportReply(type: type, replyId: replyId)
    }
    
    func didChooseToBlockUser(userId: String) {
        viewModel.blockUser(targetUserId: userId)
    }
    
    func didChooseToDeleteMyReply(replyId: Int) {
        viewModel.deleteMyDailyLifeFeed(replyId: replyId)
    }
    
    
}
