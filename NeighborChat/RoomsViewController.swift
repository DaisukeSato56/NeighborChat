//
//  RoomsViewController.swift
//  NeighborChat
//
//  Created by 佐藤大介 on 2018/06/21.
//  Copyright © 2018年 sato daisuke. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class RoomsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var uid = Auth.auth().currentUser?.uid
    var profileImage:NSURL!
//    比べる用
    var address:String = String()
    
    var posts = [Post]()
    
    @IBOutlet weak var tableView: UITableView!
    
    var contry_Array = [String]()
    var administrativeArea_Array = [String]()
    var subAdministrativeArea_Array = [String]()
    var locality_Array = [String]()
    var subLocality_Array = [String]()
    var thoroughfare_Array = [String]()
    var subToroughfare_Array_Array = [String]()
    var pathToImage_Array = [String]()
    var roomName_Array = [String]()
    var roomRule_Array = [String]()
    var userID_Array = [String]()
    
    var posst = Post()

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        fetchPosts()
        
    }
    
//    Postsを取得する関数
    func fetchPosts(){
        
        let ref = Database.database().reference()
        ref.child("Rooms").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snap) in
            let postsSnap = snap.value as! [String : AnyObject]
            
            for (_,post) in postsSnap{
                if let userID = post["userID"] as? String{
                    
                    self.posst = Post()
                    if let pathToImage = post["pathToImage"] as? String,
                        let postID = post["postID"] as? String, let roomName = post["roomName"] as? String,
                        let country = post["country"] as? String,
                        let administrativeArea = post["administrativeArea"] as? String,
                        let subAdministrativeArea = post["subAdministrativeArea"] as? String,
                        let locality = post["locality"] as? String, let subLocality = post["subLocality"] as? String,
                        let thoroughfare = post["thoroughfare"] as? String {
                        self.posst.pathToImage = pathToImage
                        self.posst.userID = userID
                        self.posst.roomName = roomName
                        self.posst.country = country
                        self.posst.administrativeArea = administrativeArea
                        self.posst.subAdministrativeArea = subAdministrativeArea
                        self.posst.locality = locality
                        self.posst.subLocality = subLocality
                        self.roomName_Array.append(self.posst.roomName)
                        //比較して入れるものを限る
                        if ((self.posst.country + self.posst.administrativeArea + self.posst.subAdministrativeArea
                            + self.posst.locality + self.posst.subLocality) == self.address) {
                            self.posts.append(self.posst)
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        画面遷移
        performSegue(withIdentifier: "privateChat", sender: indexPath)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "privateChat") {
            
            let privateChatVC = segue.destination as! PrivateChatViewController
            
//            Poomsの中の全てのAddressを足したものとaddressを比べる
            let fromDBAddress = self.posst.country + self.posst.administrativeArea + self.posst.subAdministrativeArea + self.posst.locality + self.posst.subLocality
            
            print(address)
            
//            roomNameを渡す
            privateChatVC.roomName = self.posst.roomName
            
//            住所を渡す
            privateChatVC.fromDBAddress = fromDBAddress
            
//            pathToImageを渡す
            privateChatVC.pathToImage = profileImage.absoluteString!
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
//        オーナーの名前
        let ownerNameLabel = cell.viewWithTag(1) as! UILabel
        ownerNameLabel.text = self.posts[indexPath.row].userID
        
        print(self.posts[indexPath.row].userID)
        
//        プロフィール
        let profileImageView = cell.viewWithTag(2) as! UIImageView
        let profileImageUrl = URL(string: self.posts[indexPath.row].pathToImage as String)!
        profileImageView.sd_setImage(with: profileImageUrl, completed: nil)
        
//        部屋の名前
        let roomNameLabel = cell.viewWithTag(3) as! UILabel
        roomNameLabel.text = self.posts[indexPath.row].roomName
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
