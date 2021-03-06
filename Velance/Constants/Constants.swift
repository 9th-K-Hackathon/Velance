import Foundation
import UIKit

struct API {
    
    static let baseUrl = "http://222.104.199.114:5100/api/"
}

struct StoryboardName {
    
    static let main             = "Main"
    static let login            = "Login"
    static let userRegister     = "UserRegister"
    static let productReview    = "ProductReview"
    static let myPage           = "MyPage"
    static let community        = "Community"
    static let mall             = "Mall"
    
    // Custom
    static let chooseInterest   = "ChooseInterest"
}

struct StoryboardID {
    
    static let mainVC                       = "MainViewController"
    static let homeVC                       = "RecordViewController"
    static let shoppingVC                   = "ShoppingViewController"
    
    // User Register
    static let idPasswordInputVC            = "IdPasswordInputViewController"
    static let chooseTypeVC                 = "ChooseTypeViewController"
    static let inputUserInfoForRegister     = "InputUserInfoForRegisterViewController"

    // Product Review
    static let productReviewListContainerVC = "ProductReviewListContainerViewController"
    static let productReviewListVC          = "ProductReviewListViewController"
    static let uploadNewProductVC           = "UploadNewProductViewController"
    static let productReviewVC              = "ProductReviewViewController"
    static let newProductReviewVC           = "NewProductReviewViewController"
    
    // Shopping
    static let recipeDetailVC               = "RecipeDetailViewController"
    
    // Custom
    static let chooseInterestVC             = "ChooseInterestViewController"
}

struct Colors {
    
    static let appDefaultColor              = "AppDefaultColor"
    static let appBackgroundColor           = "AppBackgroundColor"
    static let appTintColor                 = "AppTintColor"
    static let buttonSelectedColor          = "ButtonSelectedColor"
    static let foodCategorySelectedColor    = "FoodCategorySelectedColor"
    
    //Tab Bar Colors
    static let tabBarSelectedColor          = "TabBarSelectedColor"
    static let tabBarUnselectedColor        = "TabBarUnselectedColor"
    
    // Button Colors
    static let ovalButtonGradientLeft       = "OvalButtonGradientLeft"
    static let ovalButtonGradientRight      = "OvalButtonGradientRight"
    static let loginScreenButtonColor       = "LoginButtonColor"
}

struct CellID {
    
    static let similarTasteTableViewCell            = "similarTasteTVC"
    static let popularProductTableViewCell          = "popularProductTVC"
    
    static let shoppingItemCollectionViewCell   = "shoppingItemCVC"
    static let recipeCollectionViewCell         = "recipeCVC"
    
    // Product Review
    static let productForSimilarTasteCVC        = "ProductForSimilarTasteCVC"
    static let popularProductCVC                = "PopularProductCVC"
    static let productReviewTVC                = "ProductReviewTVC"
}

struct XIB_ID {
    
    // Product Review
    static let productForSimilarTasteCVC        = "ProductForSimilarTasteCVC"
    static let popularProductCVC                = "PopularProductCVC"
    static let productReviewTVC                 = "ProductReviewTableViewCell"
    
    static let shoppingItemCollectionViewCell   = "ShoppingItemCollectionViewCell"
    static let recipeCollectionViewCell         = "RecipeCollectionViewCell"
}

struct Images {
    
    // MealView Images
    
    static let mealViewImageBreakfast           = "breakfast"
    static let mealViewImageLunch               = "lunch"
    static let mealViewImageDinner              = "dinner"
    
    // Tab Bar Icons
    static let tabImageActive                   = ["Tab1comunity_active", "Tab2mall_active", "Tab3product_active", "Tab4mypage_active"]
    static let tabImageInactive                 = ["Tab1comunity_inactive", "Tab2mall_inactive", "Tab3product_inactive", "Tab4mypage_inactive"]
    
    // Vegan Types
    static let vegan                = "vegan"
    static let ovo                  = "ovo"
    static let lacto                = "lacto"
    static let lacto_ovo            = "lactoovo"
    static let pesco                = "pesco"
    static let veganTypesUnselected = [vegan, ovo, lacto, lacto_ovo, pesco]
    
    static let vegan_selected       = "vegan_selected"
    static let ovo_selected         = "ovo_selected"
    static let lacto_selected       = "lacto_selected"
    static let lacto_ovo_selected   = "lactoovo_selected"
    static let pesco_selected       = "pesco_selected"
    static let veganTypesSelected   = [vegan_selected, ovo_selected, lacto_selected, lacto_ovo_selected, pesco_selected]
    
    // Buttons
    static let circleButtonSelected     = "CircleButtonSelected"
    static let ovalButtonSelected       = "OvalButtonSelected"
    
    
    // Stars
    static let starFilled               = "StarFilled"
    static let starUnfilled             = "StarUnfilled"
    static let starFilledLarge          = "StarFilledLarge"
    static let starUnfilledLarge        = "StarUnfilledLarge"
}

struct LayoutConstants {
    static var tabContainerViewHeight: CGFloat       = 0.0
}

struct KakaoAPIKey {
    static let App_Key                      = "2fc239ca0b3bd6827cd30cb3a899fe96"
    static let API_Key                      = "96812c95e78a181604f1b6fb0a751398"
    static let Admin_Key                    = "55631246cbc856f459c460cc47806611"
}

struct OpenAPI {
    static let baseURL                      = "https://openapi.foodsafetykorea.go.kr/api/6975f768355f446ea613/C002/json/1/5?PRDLST_NM="
    static let publicAPIKey                 = "6975f768355f446ea613"
}


struct NotionUrl {
    static let privacyTermsUrl              = "https://linen-twister-e2b.notion.site/524009eb747946d7ad0096bec1b43af2"
    
    static let termsAndAgreementUrl         = "https://linen-twister-e2b.notion.site/dc291675a5e34c1fb506c96d341635aa"
}
