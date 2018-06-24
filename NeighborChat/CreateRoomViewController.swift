//
//  CreateRoomViewController.swift
//  NeighborChat
//
//  Created by 佐藤大介 on 2018/06/21.
//  Copyright © 2018年 sato daisuke. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class CreateRoomViewController: UIViewController, CLLocationManagerDelegate {
    
    var posts = [Post]()
    
    var uid = Auth.auth().currentUser?.uid
    var profileImage:NSURL!
    var locationManager:CLLocationManager!
    
    var country:String = String()
    var administrativeArea:String = String()
    var subAdministrativeArea:String = String()
    var locality:String = String()
    var subLocality:String = String()
    var thoroughfare:String = String()
    var subThoroughfare:String = String()
    
    var address:String = String()
    
    var data:Data = Data()
    var imageString:String! 

    @IBOutlet weak var idoLabel: UILabel!
    @IBOutlet weak var keidoLabel: UILabel!
    
    @IBOutlet weak var inputRoomNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        catchLocationData()
    }
    
    func catchLocationData() {
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }
    }
    
    //    位置情報に関するアラート
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways, .authorizedWhenInUse:
            break
        }
    }
    
    //    位置情報が更新されるたびに呼ばれるメソッド
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newlocation = locations.last else {
            return
        }
        
        self.idoLabel.text = "".appendingFormat("%.4f", newlocation.coordinate.latitude)
        self.keidoLabel.text = "".appendingFormat("%.4f", newlocation.coordinate.longitude)
        self.reverseGeocode(latitude: Double(idoLabel.text!)!, longitude: Double(keidoLabel.text!)!)
    }
    
    //    逆ジオコーディング処理(緯度経度を住所に変換)
    func reverseGeocode(latitude:CLLocationDegrees, longitude:CLLocationDegrees) {
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocorder = CLGeocoder()
        
        geocorder.reverseGeocodeLocation(location, completionHandler: { (placemark, error) -> Void in
            let placeMark = placemark?.first
            if let country = placeMark?.country {
                print("\(country)")
                self.country = country
            }
            if let administrativeArea = placeMark?.administrativeArea {
                print("\(administrativeArea)")
                self.administrativeArea = administrativeArea
            }
            if let subAdministrativeArea = placeMark?.subAdministrativeArea {
                print("\(subAdministrativeArea)")
                self.subAdministrativeArea = subAdministrativeArea
            }
            if let locality = placeMark?.locality {
                print("\(locality)")
                self.locality = locality
            }
            if let subLocality = placeMark?.subLocality {
                print("\(subLocality)")
                self.subLocality = subLocality
            }
            if let thoroughfare = placeMark?.thoroughfare {
                print("\(thoroughfare)")
                self.thoroughfare = thoroughfare
            }
            if let subThoroughfare = placeMark?.subThoroughfare {
                print("\(subThoroughfare)")
                self.subThoroughfare = subThoroughfare
            }
            
            self.address = self.country + self.administrativeArea + self.subAdministrativeArea + self.locality + self.subLocality
        })
        
    }
    
    func postRoom() {
        AppDelegate.instance().showIndicator()
        reverseGeocode(latitude: Double(idoLabel.text!)!, longitude: Double(keidoLabel.text!)!)
        
        let ref = Database.database().reference()
        let storage = Storage.storage().reference(forURL: "gs://neighborchat-fa60d.appspot.com")
        let key = ref.child("Rooms").childByAutoId().key
        let imageRef = storage.child("Rooms").child(uid!).child("\(key).png")
        
        self.data = UIImageJPEGRepresentation(UIImage(named: "ownerImage.png")!, 0.6)!
        
        let uploadTask = imageRef.putData(self.data, metadata: nil) { (metaData, error) in
            
            if error != nil {
                AppDelegate.instance().dismissActivityIndicator()
                return
            }
            
//            URLはストレージのURL
            imageRef.downloadURL(completion: { (url, error) in
                if let url = url {
                    
                    let feed = ["userID":self.uid,"pathToImage":self.profileImage.absoluteString,"ido":self.idoLabel.text,"keido":self.keidoLabel.text,
                    "roomName":self.inputRoomNameTextField.text,"postID":key,"country":self.country,"administrativeArea":self.administrativeArea,"subAdministrativeArea":self.subAdministrativeArea,"locality":self.locality,"subLocality":self.subLocality,"thoroughfare":self.thoroughfare,"subThoroughfare":self.subThoroughfare] as [String:Any]
                    
                    
                    let postFeed = ["\(key)":feed]
                    self.imageString = self.profileImage.absoluteString
                    ref.child("Rooms").updateChildValues(postFeed)
                    AppDelegate.instance().dismissActivityIndicator()
                    self.performSegue(withIdentifier: "room", sender: nil)
                    
                }
            })
        }
        
        uploadTask.resume()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let chatVC = segue.destination as! ChatViewController
        chatVC.roomName = inputRoomNameTextField.text!
        chatVC.address = self.address
        chatVC.pathToImage = self.profileImage.absoluteString!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
