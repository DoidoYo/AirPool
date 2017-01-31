
//
//  CustomTabBar.swift
//  CustomTabBar
//
//  Created by Adam Bardon on 07/03/16.
//  Copyright © 2016 Swift Joureny. All rights reserved.
//

import UIKit

protocol CustomTabBarDelegate {
    func didSelectViewController(tabBarView: CustomTabBar, atIndex index: Int)
}

class CustomTabBar: UITabBar {
    var cDelegate: CustomTabBarDelegate!
    
    var tabBarItems: [UITabBarItem]!
    var customTabBarItems: [CustomTabBarItem]!
    var tabBarButtons: [UIButton]!
    
    var initialTabBarItemIndex: Int!
    var selectedTabBarItemIndex: Int!
    var slideMaskDelay: Double!
    var slideAnimationDuration: Double!
    
    var tabBarItemWidth: CGFloat!
    var selectedMask: UIView!
    
    @IBInspectable var selectedColor : UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.brown
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup(startingIndex: Int) {
        // get tab bar items from default tab bar
        tabBarItems = self.items
        
        customTabBarItems = []
        tabBarButtons = []
        
        initialTabBarItemIndex = startingIndex
        selectedTabBarItemIndex = initialTabBarItemIndex
        
        slideAnimationDuration = 0.4
        slideMaskDelay = slideAnimationDuration / 2
        
        let containers = createTabBarItemContainers()
        
        createTabBarItemSelectionOverlay(containers: containers)
        createTabBarItemSelectionOverlayMask(containers: containers)
        createTabBarItems(containers: containers)
    }
    
    func createTabBarItemSelectionOverlay(containers: [CGRect]) {
        
        for index in 0..<tabBarItems.count {
            let container = containers[index]
            
            let view = UIView(frame: container)
            
            let selectedItemOverlay = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
            selectedItemOverlay.backgroundColor = self.backgroundColor
            view.addSubview(selectedItemOverlay)
            
            self.addSubview(view)
        }
    }
    
    func createTabBarItemSelectionOverlayMask(containers: [CGRect]) {
        
        tabBarItemWidth = self.frame.width / CGFloat(tabBarItems.count)
        
        selectedMask = UIView(frame: CGRect(x: CGFloat(initialTabBarItemIndex) * tabBarItemWidth, y: 0, width: tabBarItemWidth, height: self.frame.height))
        selectedMask.backgroundColor = selectedColor

        self.addSubview(selectedMask)
    }
    
    func createTabBarItems(containers: [CGRect]) {
        
        var index = 0
        for item in tabBarItems {
            
            let container = containers[index]
            
            let customTabBarItem = CustomTabBarItem(frame: container)
            customTabBarItem.setup(item: item)
            
            self.addSubview(customTabBarItem)
            customTabBarItems.append(customTabBarItem)
            
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: container.width, height: container.height))
            button.addTarget(self, action: #selector(CustomTabBar.barItemTapped), for: UIControlEvents.touchUpInside)
            
            customTabBarItem.addSubview(button)
            tabBarButtons.append(button)
            
            index += 1
        }
        
        self.customTabBarItems[initialTabBarItemIndex].iconView.tintColor = UIColor.blue
        
    }
    
    func createTabBarItemContainers() -> [CGRect] {
        
        var containerArray = [CGRect]()
        
        // create container for each tab bar item
        for index in 0..<tabBarItems.count {
            let tabBarContainer = createTabBarContainer(index: index)
            containerArray.append(tabBarContainer)
        }
        
        return containerArray
    }
    
    func createTabBarContainer(index: Int) -> CGRect {
        
        let tabBarContainerWidth = self.frame.width / CGFloat(tabBarItems.count)
        let tabBarContainerRect = CGRect(x: tabBarContainerWidth * CGFloat(index), y: 0, width: tabBarContainerWidth, height: self.frame.height)
        
        return tabBarContainerRect
    }
    
    func animateTabBarSelection(from: Int, to: Int) {
        
        self.selectedMask.frame.origin.x = CGFloat(to) * self.tabBarItemWidth
        
//        UIView.animate(withDuration: slideAnimationDuration , delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
//            self.selectedMask.frame.origin.x = CGFloat(to) * self.tabBarItemWidth
//            }, completion: nil)
        
    }
    
    func barItemTapped(sender : UIButton) {
        let index = tabBarButtons.index(of: sender)!
        
        animateTabBarSelection(from: selectedTabBarItemIndex, to: index)
        selectedTabBarItemIndex = index
        cDelegate.didSelectViewController(tabBarView: self, atIndex: index)
    }
}
