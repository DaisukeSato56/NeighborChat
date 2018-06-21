//
//  LoginViewController.swift
//  NeighborChat
//
//  Created by 佐藤大介 on 2018/06/20.
//  Copyright © 2018年 sato daisuke. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import CoreLocation

class LoginViewController: UIViewController,GIDSignInDelegate,GIDSignInUIDelegate, CLLocationManagerDelegate {
    
    var profileImage:URL!
    
    var locationManager:CLLocationManager!
    
    var uid = Auth.auth().currentUser?.uid
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let err = error {
            print("エラーです", err)
            return
        }
        
        print("成功しました！")
        UserDefaults.standard.set(0, forKey: "login")
        
        guard let idToken = user.authentication.idToken else {
            return
        }
        
        guard let accessToken = user.authentication.accessToken else {
            return
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        Auth.auth().signIn(with: credential, completion: { (user,error) in
            if let err = error {
                print("エラー", err)
                return
            }
            let imageUrl = signIn.currentUser.profile.imageURL(withDimension: 100)
            self.profileImage = imageUrl
            self.postMyProfile()
            self.performSegue(withIdentifier: "next", sender: nil)
        })
    }
    
    func postMyProfile() {
        AppDelegate.instance().showIndicator()
        
        uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        let storage = Storage.storage().reference(forURL: "gs://cloudchatroom-43223.appspot.com/")
        let key = ref.child("Users").childByAutoId().key
        let imageRef = storage.child("Users").child(uid!).child("\(key).jpeg")
        let imageData:NSData = try! NSData(contentsOf: self.profileImage)
        
        let uploadTask = imageRef.putData(imageData as Data, metadata: nil) { (metaData, error) in
            if error != nil {
                AppDelegate.instance().dismissActivityIndicator()
                return
            }
            
            imageRef.downloadURL(completion: { (url, error) in
                if url != nil {
                    let feed = ["userID":self.uid, "pathToImage":self.profileImage.absoluteString, "postID":key] as [String:Any]
                    
                    let postFeed = ["\(key)":feed]
                    
                ref.child("Users").updateChildValues(postFeed)
                AppDelegate.instance().dismissActivityIndicator()
                }
                
            })
            
        }
        
        uploadTask.resume()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let googleButton = GIDSignInButton()
        googleButton.frame = CGRect(x: 20, y: 250, width: self.view.frame.size.width-40, height: 60)
        view.addSubview(googleButton)
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    


}
