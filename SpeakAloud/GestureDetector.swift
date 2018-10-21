//
//  GestureDetector.swift
//  SpeakAloud
//
//  Created by SeoGiwon on 17/10/2018.
//  Copyright © 2018 SeoGiwon. All rights reserved.
//

import UIKit
import CoreMotion

class GestureDetector {

    let motion = CMMotionManager()
    
    init() {
        startQueuedUpdates()
    }
    
    func startQueuedUpdates() {
        if motion.isDeviceMotionAvailable {
            self.motion.deviceMotionUpdateInterval = 1.0 / 10.0 //1.0 / 60.0
            self.motion.showsDeviceMovementDisplay = true
            self.motion.startDeviceMotionUpdates(to: .main, withHandler: { (data, error) in
                
                // Make sure the data is valid before accessing it.
                if let validData = data {
                    let az = validData.userAcceleration.z
                    let rz = validData.rotationRate.z
                    
                    if az >= 1 {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "lifted"), object: nil)
                    }
                    
                    if rz < -7 {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "shaked"), object: nil)
                    }
                }
            })
        }
    
    }
    
    
}
