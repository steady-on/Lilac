//
//  WorkSpaceTabBarController.swift
//  Lilac
//
//  Created by Roen White on 2/19/24.
//

import UIKit

final class WorkSpaceTabBarController: UITabBarController {
    
    private let home = HomeViewController()
    private let directMessage = DirectMessageViewController()
    private let search = SearchViewController()
    private let settings = SettingsViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTabBar()
    }
    
    private func configureTabBar() {
        tabBar.tintColor = .black
        
        setTabImage()
        
        let viewControllers = [home, directMessage, search, settings].map { viewController in
            UINavigationController(rootViewController: viewController)
        }
        
        setViewControllers(viewControllers, animated: true)
    }
}

extension WorkSpaceTabBarController {
    private func setTabImage() {
        home.tabBarItem.image = .TabItem.home
        home.tabBarItem.selectedImage = .TabItem.homeActive
        
        directMessage.tabBarItem.image = .TabItem.message
        directMessage.tabBarItem.selectedImage = .TabItem.messageActive
        
        search.tabBarItem.image = .TabItem.profile
        search.tabBarItem.selectedImage = .TabItem.profileActive
        
        settings.tabBarItem.image = .TabItem.setting
        settings.tabBarItem.selectedImage = .TabItem.settingActive
    }
}
