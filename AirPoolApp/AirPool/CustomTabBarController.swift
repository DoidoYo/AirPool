//
//  CustomTabBarViewController.swift
//  CustomTabBar
//
//  Created by Adam Bardon on 07/03/16.
//  Copyright © 2016 Swift Joureny. All rights reserved.
//

import UIKit

class CustomTabBarViewController: UITabBarController, CustomTabBarDelegate, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedIndex = 1
        self.delegate = self
        
        let customTabBar = (self.tabBar as! CustomTabBar)
        
        customTabBar.cDelegate = self
        customTabBar.setup(startingIndex: self.selectedIndex)
    }
    
    // MARK: - CustomTabBarDelegate
    
    func didSelectViewController(tabBarView: CustomTabBar, atIndex index: Int) {
        self.selectedIndex = index
    }
    
    // MARK: - UITabBarControllerDelegate
    
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
//        return CustomTabAnimatedTransitioning()
        return nil
    }

}
