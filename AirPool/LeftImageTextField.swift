//
//  LeftImageTextField.swift
//  AirPool
//
//  Created by Gabriel Fernandes on 1/21/17.
//  Copyright © 2017 Gabriel Fernandes. All rights reserved.
//

import Foundation
import UIKit

public extension UIImage {
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!
        
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
}

class LeftImageTextField: UITextField {
    
    @IBInspectable var img: UIImage = #imageLiteral(resourceName: "Marker")
    
    @IBInspectable var imageScale: CGFloat = 1
    
    @IBInspectable var leftImageSpacing: CGFloat = 10
    
    @IBInspectable var radius: CGFloat = 0
    
    override func awakeFromNib() {
        
//        img = img.maskWithColor(color: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))!
        
        let leftImg = UIImageView(image: imageWithImage(image: img, scaledToSize: CGSize(width: (img.size.width) * imageScale, height: (img.size.width) * imageScale)))
        
        if let size = leftImg.image?.size {
            leftImg.frame = CGRect(x: 0, y: 0, width: size.width + leftImageSpacing, height: size.height)
        }
        leftImg.contentMode = UIViewContentMode.center
        self.leftView = leftImg
        self.leftViewMode = UITextFieldViewMode.always
        
        self.layer.cornerRadius = radius
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 3, height: 3)
        self.layer.shadowOpacity = 0.4
        self.layer.shadowRadius = 2
    }
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
}
