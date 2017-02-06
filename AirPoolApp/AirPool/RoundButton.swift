//
//  RoundButton.swift
//  AirPool
//
//  Created by Gabriel Fernandes on 1/23/17.
//  Copyright © 2017 Gabriel Fernandes. All rights reserved.
//

import Foundation
import UIKit

class RoundButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layer.cornerRadius = self.frame.width / 2.0
        
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
