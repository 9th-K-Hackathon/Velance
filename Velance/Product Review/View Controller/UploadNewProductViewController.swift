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
    
    private var dropDown = DropDown()
    private var productNumberFromAPI: String?
    private var productRawMaterialNames: String?
    
    @IBOutlet weak var doneButton: UIButton!
    
    lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .savedPhotosAlbum
        return imagePicker
    }()
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
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
            showSimpleBottomAlert(with: "?????? ???????????? ????????? ?????? 1?????? ???????????????!")
            return
        }
        
        guard
            let productName = productNameTextField.text,
            let productPrice = productPriceTextField.text,
            productName.count > 2,
            productName.count > 2
        else {
            showSimpleBottomAlert(with: "????????? ????????? ??????????????????.")
            return
        }
        
        guard let productCategoryId = productCategoryId else {
            showSimpleBottomAlert(with: "?????? ??????????????? 1??? ??????????????????")
            return
        }
        
        presentAlertWithConfirmAction(title: "?????? ????????? ?????? ?????????????????????????", message: "") { [weak self] selectedOk in
            guard let self = self else { return }
            if selectedOk {
                let model = NewProductDTO(
                    productCategoryId: productCategoryId,
                    name: productName,
                    price: Int(productPrice) ?? 0,
                    file: imageData,
                    productReportNumber: self.productNumberFromAPI ?? "\(Int.random(in: 10000...10000000))",
                    productRawMaterialNames: self.productRawMaterialNames ?? "??????,"
                ) 
                showProgressBar()
                ProductManager.shared.uploadNewProduct(with: model) { [weak self] result in
                    guard let self = self else { return }
                    dismissProgressBar()
                    switch result {
                    case .success:
                        self.showSimpleBottomAlert(with: "??? ?????? ????????? ??????????????????.????")
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
        view.endEditing(true)
        guard let productName = productNameTextField.text, productName.count > 1 else { return }
        
        activityIndicator.startAnimating()

        
        ProductManager.shared.searchProductInOpenAPI(keyword: productName) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let openAPIProductDTO):
                self.dropDown.dataSource.removeAll()
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                
                    openAPIProductDTO.results.productList?.forEach { result in
                        self.dropDown.dataSource.append(result.productName)
                    }
                
                    self.dropDown.anchorView = self.searchOpenAPIButton
                    self.dropDown.topOffset = CGPoint(x: 0, y:(self.dropDown.anchorView?.plainView.bounds.height)!)
                    self.dropDown.show()
                    
                    self.dropDown.selectionAction = { [weak self] (index: Int, item: String) in
                        guard let self = self else { return }
                        self.productNameTextField.text = item
                        self.updateOpenAPISearchResultLabel(isSuccess: true, productName: item)
                        self.productNumberFromAPI = openAPIProductDTO.results.productList?[index].productListReportNumber
                        self.productRawMaterialNames = openAPIProductDTO.results.productList?[index].rawMaterialNames
                    }
                }
                
            case .failure(_):
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.updateOpenAPISearchResultLabel(isSuccess: false)
                }
            }
        }
    }
    
    private func updateOpenAPISearchResultLabel(isSuccess: Bool, productName: String = "") {
        
        openAPISearchResultLabel.isHidden = false
        openAPISearchResultLabel.text = isSuccess
        ? "\(productName) - ????????? ?????? ?????? ?????? ????"
        : "?????? ????????? ???????????????.\n????????? ????????? ??? ???????????? ????????? ????????? ?????? ??? ????????? :)"
    
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

//MARK: - UITextFieldDelegate

extension UploadNewProductViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        openAPISearchResultLabel.isHidden = true
    }
}


//MARK: - Initialization & UI Configuration

extension UploadNewProductViewController {
    
    private func configure() {
        title = "??? ?????? ??????"
        activityIndicator.stopAnimating()
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
        productNameTextField.delegate = self
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
