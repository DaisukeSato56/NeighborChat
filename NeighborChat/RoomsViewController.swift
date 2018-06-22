//
//  RoomsViewController.swift
//  NeighborChat
//
//  Created by 佐藤大介 on 2018/06/21.
//  Copyright © 2018年 sato daisuke. All rights reserved.
//

import UIKit
import Firebase

class RoomsViewController: UIViewController {
    
    var uid = Auth.auth().currentUser?.uid
    var profileImage:NSURL!
    var address:String = String()

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
