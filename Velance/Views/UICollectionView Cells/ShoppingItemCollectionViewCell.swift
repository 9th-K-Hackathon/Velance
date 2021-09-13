import UIKit

class ShoppingItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var itemContentView: UIView!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var itemDetailLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    @IBOutlet weak var shoppingCartButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
        
    }
  
    @objc private func pressedAddCartButton() {
        
        
    }

    private func configure() {
        configureItemContentView()
        configureItemImageView()
        configureItemTitleLabel()
        configureItemDetailLabel()
        configureItemPriceLabel()
        configureShoppingCartButton()
    }
    
    private func configureItemContentView() {
        itemContentView.layer.borderWidth = 0.5
        itemContentView.layer.borderColor = UIColor.lightGray.cgColor
        itemContentView.layer.cornerRadius = 10
    }
    
    private func configureItemImageView() {
        itemImageView.layer.cornerRadius = 10
    }
    
    private func configureItemTitleLabel() {
        
        
    }
    
    private func configureItemDetailLabel() {
        
    }
    
    private func configureItemPriceLabel() {
        
    }
    
    private func configureShoppingCartButton() {
        shoppingCartButton.layer.cornerRadius = 10
        shoppingCartButton.addBounceAnimation()
        shoppingCartButton.addTarget(
            self,
            action: #selector(pressedAddCartButton),
            for: .touchUpInside
        )
    }

}
