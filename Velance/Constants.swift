import Foundation

struct StoryboardID {
    
    static let mainVC                       = "MainViewController"
    static let homeVC                       = "HomeViewController"
    static let shoppingVC                   = "ShoppingViewController"
    
    // User Register
    static let chooseTypeVC                 = "ChooseTypeViewController"
    static let chooseDetailVC               = "ChooseDetailViewController"
    static let chooseReasonVC               = "ChooseReasonViewController"
    static let analyzingVC                  = "AnalyzingViewController"
}

struct Colors {
    
    static let appDefaultColor              = "AppDefaultColor"
    static let appBackgroundColor           = "AppBackgroundColor"
    static let appTintColor                 = "AppTintColor"
    static let buttonSelectedColor          = "ButtonSelectedColor"
    
    //Tab Bar Colors
    static let tabBarSelectedColor          = "TabBarSelectedColor"
    static let tabBarUnselectedColor        = "TabBarUnselectedColor"
    
    

}

struct Images {
    
    // Tab Bar Icons
    static let homeTabBarIcon_selected         = "home_selected"
    static let homeTabBarIcon_unselected       = "home_unselected"
    static let shopTabBarIcon_selected         = "shopping_selected"
    static let shopTabBarIcon_unselected       = "shopping_unselected"
    
    // Vegan Types
    static let vegan            = "vegan"
    static let ovo              = "ovo"
    static let lacto            = "lacto"
    static let lacto_ovo        = "lactoovo"
    static let pesco            = "pesco"
    static let veganTypesUnselected = [vegan, ovo, lacto, lacto_ovo, pesco]
    
    static let vegan_selected       = "vegan_selected"
    static let ovo_selected         = "ovo_selected"
    static let lacto_selected       = "lacto_selected"
    static let lacto_ovo_selected   = "lactoovo_selected"
    static let pesco_selected       = "pesco_selected"
    static let veganTypesSelected = [vegan_selected, ovo_selected, lacto_selected, lacto_ovo_selected, pesco_selected]
}