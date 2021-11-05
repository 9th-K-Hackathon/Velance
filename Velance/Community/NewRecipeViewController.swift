import UIKit

class NewRecipeViewController: UIViewController, Storyboarded {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var recipeCategoryView: UIView!
    @IBOutlet var recipeCategoryButtons: [VLGradientButton]!
    
    @IBOutlet weak var postImageCollectionView: UICollectionView!
    @IBOutlet weak var postTextView: UITextView!
    
    //MARK: - Properties
    
    var recipeCategoryId: Int = 1
    var userSelectedImages = [UIImage]() {
        didSet { convertUIImagesToDataFormat() }
    }
    var userSelectedImagesInDataFormat: [Data]?

    
    static var storyboardName: String {
        StoryboardName.community
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }


}

//MARK: - IBActions & Target Methods

extension NewRecipeViewController {
    
    @IBAction func pressedRecipeCategoryButton(_ sender: UIButton) {
        recipeCategoryButtons.forEach { $0.isSelected = false }
        sender.isSelected = true
        recipeCategoryId = sender.tag
        
    }
    
    @IBAction func pressedDoneButton(_ sender: UIButton) {
        
        guard let content = postTextView.text, content.count > 5 else {
            showSimpleBottomAlert(with: "글을 5자 이상 작성해주세요.")
            return
        }
        
        guard let _ = userSelectedImagesInDataFormat else {
            showSimpleBottomAlert(with: "사진을 1개 이상 골라주세요.")
            return
        }
        
        presentAlertWithConfirmAction(
            title: "피드 업로드를 하시겠습니까?",
            message: ""
        ) { selectedOk in
            if selectedOk { self.uploadNewRecipe() }
        }
    }
    
    func uploadNewRecipe() {
        
        let model = NewRecipeDTO(
            title: "",
            contents: postTextView.text!,
            files: userSelectedImagesInDataFormat!,
            recipeCategoryId: recipeCategoryId
        )
        
        CommunityManager.shared.uploadRecipePost(with: model) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.showSimpleBottomAlert(with: "피드 업로드 성공🎉")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.navigationController?.popViewController(animated: true)
                }
                
            case .failure(let error):
                self.showSimpleBottomAlert(with: error.errorDescription)
            }
        }
        
    }

    
    
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension NewRecipeViewController: UICollectionViewDelegate, UICollectionViewDataSource  {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Add Button 이 항상 있어야하므로 + 1
        return self.userSelectedImages.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let addImageButtonCellIdentifier = "AddImageButtonCollectionViewCell"
        let newFoodImageCellIdentifier = "UserPickedImageCollectionViewCell"
        
        /// 첫 번째 Cell 은 항상 Add Button
        if indexPath.item == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: addImageButtonCellIdentifier, for: indexPath) as? AddImageButtonCollectionViewCell else {
                fatalError()
            }
            cell.maxSelection = 3
            cell.delegate = self
            return cell
        }
        
        /// 그 외의 셀은 사용자가 고른 사진으로 구성된  Cell
        else {
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: newFoodImageCellIdentifier, for: indexPath) as? UserPickedImageCollectionViewCell else {
                fatalError()
            }
            cell.delegate = self
            cell.indexPath = indexPath.item
            
            // 사용자가 앨범에서 고른 사진이 있는 경우
            if self.userSelectedImages.count > 0 {
                cell.userPickedImageView.image = self.userSelectedImages[indexPath.item - 1]
            }
            return cell
        }
    }
}

//MARK: - AddImageDelegate

extension NewRecipeViewController: AddImageDelegate {
    func didPickImagesToUpload(images: [UIImage]) {
        self.userSelectedImages = images
        postImageCollectionView.reloadData()
    }
}

//MARK: - UserPickedImageCellDelegate

extension NewRecipeViewController: UserPickedImageCellDelegate {
    func didPressDeleteImageButton(at index: Int) {

        self.userSelectedImages.remove(at: index - 1)
        postImageCollectionView.reloadData()
        viewWillLayoutSubviews()
    }
}

//MARK: - Conversion Methods

extension NewRecipeViewController {
    
    func convertUIImagesToDataFormat() {
        userSelectedImagesInDataFormat?.removeAll()
        userSelectedImagesInDataFormat = userSelectedImages.map( { (image: UIImage) -> Data in
            guard let imageData = image.jpegData(compressionQuality: 1) else {
                return Data()
            }
            return imageData
        })
    }
}

//MARK: - UITextViewDelegate


extension NewRecipeViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.darkGray
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
    
        if textView.text.isEmpty {
            textView.text = "글을 작성해주세요 :)"
            textView.textColor = UIColor.lightGray
            return
        }
    }
}

//MARK: - UI Configuration & Initialization

extension NewRecipeViewController {
    
    private func configure() {
        title = "새 글 등록"
        configureCategoryViews()
   
        configureRecipeCategoryButtons()
        configurePostImagesCollectionView()
        configurePostTextView()
    }
    
    private func configureCategoryViews() {
        recipeCategoryView.layer.cornerRadius = 15
        recipeCategoryView.layer.borderWidth = 0.3
        recipeCategoryView.layer.borderColor = UIColor.lightGray.cgColor
        recipeCategoryView.backgroundColor = UIColor(named: Colors.appBackgroundColor)
    }
    
    private func configureRecipeCategoryButtons() {
        var index: Int = 1
        recipeCategoryButtons.forEach { button in
            button.tag = index
            button.setTitle(UserOptions.recipeType[index - 1], for: .normal)
            index += 1
        }
    }
    
    private func configurePostImagesCollectionView() {
        postImageCollectionView.delegate = self
        postImageCollectionView.dataSource = self
        postImageCollectionView.alwaysBounceHorizontal = true
    }
    
    private func configurePostTextView() {
        postTextView.delegate = self
        postTextView.layer.cornerRadius = 15
        postTextView.layer.borderWidth = 0.3
        postTextView.clipsToBounds = true
        postTextView.layer.borderColor = UIColor.lightGray.cgColor
        postTextView.text = "글을 작성해주세요 :)"
        postTextView.textColor = UIColor.lightGray
    }
    
    
}
