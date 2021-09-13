//
//  ViewController.swift
//  Velance
//
//  Created by Kevin Kim on 2021/09/11.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tabView: UIView!
    @IBOutlet weak var homeTabButton: UIButton!
    @IBOutlet weak var shoppingTabButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        changeToHomeVC()
    }
    
    @IBAction func pressedHomeButton(_ sender: UIButton) {
        changeToHomeVC()
    }
    
    @IBAction func pressedShoppingButton(_ sender: UIButton) {
        changeToShoppingVC()
    }
}

//MARK: - UI Configuration

extension MainViewController {
    
    private func configure() {
        
        view.backgroundColor = UIColor(named: Colors.appBackgroundColor)
        configureTabView()
        configureTabButtons()
    }
    
    private func configureTabView() {
        tabView.layer.cornerRadius = tabView.frame.height / 2
    }
    
    private func configureTabButtons() {
        
        homeTabButton.setImage(UIImage(named: Images.homeTabBarIcon_unselected), for: .normal)
        homeTabButton.setImage(UIImage(named: Images.homeTabBarIcon_selected), for: .selected)
        homeTabButton.setImage(UIImage(named: Images.homeTabBarIcon_selected), for: .highlighted)
        
        homeTabButton.setTitle("기록", for: .normal)
        homeTabButton.setTitleColor(UIColor(named: Colors.tabBarUnselectedColor), for: .normal)
        homeTabButton.setTitleColor(UIColor(named: Colors.tabBarSelectedColor), for: .selected)
        homeTabButton.setTitleColor(UIColor(named: Colors.tabBarSelectedColor), for: .highlighted)
        homeTabButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        homeTabButton.alignTextBelow()
        
  
        shoppingTabButton.setImage(UIImage(named: Images.shopTabBarIcon_unselected), for: .normal)
        shoppingTabButton.setImage(UIImage(named: Images.shopTabBarIcon_selected), for: .selected)
        shoppingTabButton.setImage(UIImage(named: Images.shopTabBarIcon_selected), for: .highlighted)
        
        shoppingTabButton.setTitle("쇼핑", for: .normal)
        shoppingTabButton.setTitleColor(UIColor(named: Colors.tabBarUnselectedColor), for: .normal)
        shoppingTabButton.setTitleColor(UIColor(named: Colors.tabBarSelectedColor), for: .selected)
        shoppingTabButton.setTitleColor(UIColor(named: Colors.tabBarSelectedColor), for: .highlighted)
        shoppingTabButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        shoppingTabButton.alignTextBelow()
        
        homeTabButton.isSelected = true
        shoppingTabButton.isSelected = false
    }
    

    private func changeToHomeVC() {
        homeTabButton.isSelected = true
        shoppingTabButton.isSelected = false
        remove()
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        guard let vc = storyboard.instantiateViewController(identifier: StoryboardID.homeVC) as? HomeViewController else { fatalError() }
        add(vc, frame: containerView.frame)
    
    }
    
    private func changeToShoppingVC() {
        shoppingTabButton.isSelected = true
        homeTabButton.isSelected = false
        remove()
        let storyboard = UIStoryboard(name: "Shopping", bundle: nil)
        guard let vc = storyboard.instantiateViewController(identifier: StoryboardID.shoppingVC) as? ShoppingViewController else { return }
        add(vc, frame: containerView.frame)
    }
}
