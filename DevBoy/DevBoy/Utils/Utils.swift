//
//  Utils.swift
//  DevBoy
//
//  Created by Ahmad Abdul-Gawad Mahmoud on 11/12/16.
//  Copyright © 2016 Ahmad Abdul-Gawad Mahmoud. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import Firebase
@objc class Utils: NSObject {
    
    
    static var locationsRef = FIRDatabase.database().reference().child("locations3")
    
    static var demoView: DemoView?
    
    override init() {
        
        super.init()

        print(Utils.locationsRef)
        
        if !(Utils.demoView?.tracking)! {
            
            Utils.locationsRef.removeValue()
        }
    }
    
    class func storeLocation(_ location: CLLocation) {
        
        let newLocation = locationsRef.childByAutoId()
        
        let locationData: [String : String] = ["latitude" : String(location.coordinate.latitude), "longitude" : String(location.coordinate.longitude), "altitude" : String(location.altitude), "horizontalAccuracy" : String(location.horizontalAccuracy), "verticalAccuracy" : String(location.verticalAccuracy), "course" : String(location.course), "speed" : String(location.speed), "timestamp" : String(describing: location.timestamp)]
        newLocation.setValue(locationData)
    }
    
    
    class func observeNewLocations() {
        
        locationsRef.observe(.value) {(snapshot: FIRDataSnapshot) in
            
            print(snapshot.value ?? "Empty Location")
            
            if let dict = snapshot.value as? [String : String]  {
                
                if (demoView?.tracking)! {
                
                    NotificationCenter.default.post(name: NSNotification.Name("newLocationAdded"), object: dict)
                }
            }
        }
    
        

        
    }

}
