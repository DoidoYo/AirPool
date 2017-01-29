//
//  LoginController.swift
//  AirPool
//
//  Created by Gabriel Fernandes on 1/19/17.
//  Copyright © 2017 Gabriel Fernandes. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit
import SwiftKeychainWrapper

class LoginController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var fbPictureView: FBSDKProfilePictureView!
    
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if (FBSDKAccessToken.current()) != nil {
            //already logged in
            
        } else {
            fbLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
            fbLoginButton.delegate = self;
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Logged Out!")
    }
 
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if let er = error {
            print(er)
        } else {
            //check for permission but nahhh
            
            let token = FBSDKAccessToken.current()
            
            var permArray: [String] = []
            for item in Array(token!.permissions) {
                permArray.append(item as! String)
            }
            let permString = permArray.joined(separator: "&")
            
            var dpermArray: [String] = []
            for item in Array(token!.declinedPermissions) {
                dpermArray.append(item as! String)
            }
            let dpermString = dpermArray.joined(separator: "&")
            
            KeychainWrapper.standard.set(token!.tokenString, forKey: "tokenString")
            KeychainWrapper.standard.set(permString, forKey: "permissions")
            KeychainWrapper.standard.set(dpermString, forKey: "declinedPermissions")
            KeychainWrapper.standard.set(token!.appID, forKey: "appID")
            KeychainWrapper.standard.set(token!.userID, forKey: "userID")
            
            let expDateString = DateFormatter().string(from: token!.expirationDate)
            let reDateString = DateFormatter().string(from: token!.refreshDate)
            
            KeychainWrapper.standard.set(expDateString, forKey: "expirationDate")
            KeychainWrapper.standard.set(reDateString, forKey: "refreshDate")
            
            
                //instantiate controller
                let story = UIStoryboard(name: "Main", bundle: nil)
                let vs = story.instantiateInitialViewController()
                
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = vs
            
        }
        
    }


}

