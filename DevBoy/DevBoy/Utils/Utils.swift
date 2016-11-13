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

@objc class Utils: NSObject {
    
    
    static var locationsRef = FIRDatabase.database().reference().child("locations")
    
    override init() {
        
        super.init()
        
        print(Utils.locationsRef)
    }
    
    class func storeLocationsWithLatitude(latitude: String, andLongitude longitude: String) {
        
        let newLocation = locationsRef.childByAutoId()

        let messageData: [String : String] = ["latitude" : latitude, "longitude" : longitude]
        
        newLocation.setValue(messageData)
    }
    
    
    class func observeNewLocations() {
        
        locationsRef.observe(.childAdded) {(snapshot: FIRDataSnapshot) in
            
            print(snapshot.value ?? "Empty Location")
            
            if let dict = snapshot.value as? [String : String] {
                
                NotificationCenter.default.post(name: NSNotification.Name("newLocationAdded"), object: dict)
            }
        }
        
    }

}
