//
//  ShareButton.swift
//  AirPool
//
//  Created by Gabriel Fernandes on 1/20/17.
//  Copyright © 2017 Gabriel Fernandes. All rights reserved.
//

import Foundation
import UIKit

class ShareButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let img = UIImageView(image: #imageLiteral(resourceName: "Carpool"))
        img.frame = CGRect(x: 28, y: -2, width: 41, height: 41)
        
        self.setTitle("Share a Ride", for: .normal)
        self.titleLabel!.font = UIFont(name: "MarkerFelt-Thin", size: 24)
        self.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        
        self.layer.cornerRadius = 10
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.shadowOpacity = 0.7
        self.layer.shadowRadius = 4.0
        
        self.addSubview(img)
    }
    
    public func setIsEnabled (_ enabled: Bool) {
        self.isEnabled = enabled
        
        if enabled {
            self.alpha = 1
        } else {
            self.alpha = 0.4
        }
    }
    
}
