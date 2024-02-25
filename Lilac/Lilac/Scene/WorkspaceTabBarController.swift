//
//  WorkspaceTabBarController.swift
//  Lilac
//
//  Created by Roen White on 2/19/24.
//

import UIKit

final class WorkspaceTabBarController: UITabBarController {
    
    private let home = HomeViewController(viewModel: HomeViewModel())
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

extension WorkspaceTabBarController {
    private func setTabImage() {
        home.tabBarItem.image = .TabItem.home
        home.tabBarItem.selectedImage = .TabItem.homeActive
        home.tabBarItem.title = "홈"
        
        directMessage.tabBarItem.image = .TabItem.message
        directMessage.tabBarItem.selectedImage = .TabItem.messageActive
        directMessage.tabBarItem.title = "DM"
        
        search.tabBarItem.image = .TabItem.profile
        search.tabBarItem.selectedImage = .TabItem.profileActive
        search.tabBarItem.title = "검색"
        
        settings.tabBarItem.image = .TabItem.setting
        settings.tabBarItem.selectedImage = .TabItem.settingActive
        settings.tabBarItem.title = "설정"
    }
}
