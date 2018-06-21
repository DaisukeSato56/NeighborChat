//
//  CreateRoomViewController.swift
//  NeighborChat
//
//  Created by 佐藤大介 on 2018/06/21.
//  Copyright © 2018年 sato daisuke. All rights reserved.
//

import UIKit
import Firebase

class CreateRoomViewController: UIViewController {
    
    var uid = Auth.auth().currentUser?.uid

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
