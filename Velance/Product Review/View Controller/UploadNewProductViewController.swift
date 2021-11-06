import UIKit
import TextFieldEffects
import DropDown

class UploadNewProductViewController: UIViewController, Storyboarded {
    
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var productImageView: UIImageView!
    
    @IBOutlet weak var productNameTextField: HoshiTextField!
    @IBOutlet weak var productPriceTextField: HoshiTextField!
    
    @IBOutlet weak var chooseProductCategoryView: UIView!
    @IBOutlet var productCategoryButtons: [VLGradientButton]!
    
    
    @IBOutlet var searchOpenAPIButton: VLFloatingButton!
    @IBOutlet var openAPISearchResultLabel: UILabel!
    
    
    
    
    @IBOutlet weak var doneButton: UIButton!
    
    lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .savedPhotosAlbum
        return imagePicker
    }()
    
    //MARK: - NewProductDTO Properties
    var productCategoryId: Int?
    var productName: String?
    var productPrice: Int?
    var productImageData: Data?
    
    
    static var storyboardName: String {
        StoryboardName.productReview
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    
    

}

//MARK: - IBActions & Target Methods

extension UploadNewProductViewController {
    
    @IBAction func pressedAddImageButton(_ sender: UIButton) {
        present(imagePicker, animated: true)
    }
    
    @IBAction func pressedProductCategoryButton(_ sender: UIButton) {
        productCategoryButtons.forEach { $0.isSelected = false }
        sender.isSelected = true
        productCategoryId = sender.tag
    }
    
    @IBAction func pressedDoneButton(_ sender: UIButton) {
        
        guard let imageData = productImageData else {
            showSimpleBottomAlert(with: "제품 썸네일로 사용할 사진 1개를 골라주세요!")
            return
        }
        
        guard
            let productName = productNameTextField.text,
            let productPrice = productPriceTextField.text,
            productName.count > 2,
            productName.count > 2
        else {
            showSimpleBottomAlert(with: "빈칸이 없는지 확인해주세요.")
            return
        }
        
        guard let productCategoryId = productCategoryId else {
            showSimpleBottomAlert(with: "제품 카테고리를 1개 선택해주세요")
            return
        }
        
        presentAlertWithConfirmAction(title: "해당 제품을 새로 등록하시겠습니까?", message: "") { [weak self] selectedOk in
            guard let self = self else { return }
            if selectedOk {
                let model = NewProductDTO(
                    productCategoryId: productCategoryId,
                    name: productName,
                    price: Int(productPrice) ?? 0,
                    file: imageData
                ) 
                showProgressBar()
                ProductManager.shared.uploadNewProduct(with: model) { [weak self] result in
                    guard let self = self else { return }
                    dismissProgressBar()
                    switch result {
                    case .success:
                        self.showSimpleBottomAlert(with: "새 제품 등록에 성공하셨어요.🎉")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            self.navigationController?.popViewController(animated: true)
                        }
                    case .failure(let error):
                        self.showSimpleBottomAlert(with: error.errorDescription)
                    }
                }
            }
        }
    }
    
    @IBAction func pressedSearchAPIButton(_ sender: UIButton) {
        
        guard let productName = productNameTextField.text else { return }
        
        searchOpenAPIButton.loadingIndicator(true)
        
        ProductManager.shared.searchProductInOpenAPI(keyword: productName) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let openAPIProductDTO):
                
                DispatchQueue.main.async {
                    self.searchOpenAPIButton.loadingIndicator(false)
                    let dropDown = DropDown()
                    
    
                    openAPIProductDTO.results.productList?.forEach { result in
                        dropDown.dataSource.append(result.productName)
                    }
                    
                    
                    dropDown.anchorView = self.searchOpenAPIButton
                    dropDown.topOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
                    	
                    dropDown.show()
                    
                    
                    self.openAPISearchResultLabel.isHidden = false
                    self.openAPISearchResultLabel.text = "알러지 정보 조회  완료 🎉"
                }
                
                
            
            case .failure(_):
                DispatchQueue.main.async {
                    self.searchOpenAPIButton.loadingIndicator(false)
                    self.openAPISearchResultLabel.isHidden = false
                    self.openAPISearchResultLabel.text = "제품 조회에 실패했어요. 알러지 정보는 못 올리지만 제품을 그대로 올릴 수 있어요 :)"
                }
            }
        }
        
        
        
        
    }
    
    private func updateOpenAPISearchResultLabel() {
        
    }
    
}

//MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension UploadNewProductViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let originalImage: UIImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            dismiss(animated: true) {
                DispatchQueue.main.async {
                    self.productImageView.image = originalImage
                    self.productImageData = originalImage.jpegData(compressionQuality: 1.0)
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}


//MARK: - Initialization & UI Configuration

extension UploadNewProductViewController {
    
    private func configure() {
        title = "새 제품 등록"
        configureAddImageButton()
        configureProductImageView()
        configureTextFields()
        configureUIViews()
        configureProductCategoryGradientButtons()
        openAPISearchResultLabel.isHidden = true
    }
    
    private func configureAddImageButton() {
        addImageButton.layer.borderWidth = 1
        addImageButton.layer.borderColor = UIColor.lightGray.cgColor
        addImageButton.layer.cornerRadius = 5
    }
    
    private func configureProductImageView() {
        productImageView.layer.cornerRadius = 5
        productImageView.contentMode = .scaleAspectFill
    }
    
    private func configureTextFields() {
        
    }
    
    private func configureUIViews() {
        
        [chooseProductCategoryView].forEach { view in
            guard let view = view else { return }
            view.layer.cornerRadius = 15
            view.layer.borderWidth = 0.3
            view.layer.borderColor = UIColor.lightGray.cgColor
            view.backgroundColor = UIColor(named: Colors.appBackgroundColor)
            
        }
    }
    
    
    private func configureProductCategoryGradientButtons() {
        var index: Int = 1
        productCategoryButtons.forEach { button in
            button.tag = index
            button.setTitle(UserOptions.productCategory[index - 1], for: .normal)
            index += 1
        }
    }
}
