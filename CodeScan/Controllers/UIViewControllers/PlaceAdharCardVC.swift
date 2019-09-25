//
//  PlaceAdharCardVC.swift
//  AccuraSDK
//
//  Created by Zignuts Technolab on 07/06/19.
//  Copyright © 2019 Elite Development LLC. All rights reserved.
//

import UIKit
import AVFoundation

class PlaceAdharCardVC: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    //MARK: UIButton Mrthod
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextAction(_ sender: Any) {

        let status: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .authorized {
            // authorized

            DispatchQueue.main.async(execute: {
                let imgVC = self.storyboard!.instantiateViewController(withIdentifier: "ImageVC") as? ImageVC
                imgVC?._pageType = .ScanAadhar
                if let img_VC = imgVC {
                    self.navigationController?.pushViewController(img_VC, animated: false)
                }
                
            })
        }
        else if status == .denied {
            let alert = UIAlertController(title: APP_NAME, message: "It looks like your privacy settings are preventing us from accessing your camera.", preferredStyle: .alert)
            
            //Add Buttons
            let yesButton = UIAlertAction(title: "Ok", style: .default, handler: { action in
                
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            })
            
            alert.addAction(yesButton)
            self.present(alert, animated: true)

            // denied
        }
        else if status == .restricted {
            // restricted
        } else if status == .notDetermined {
            // not determined
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if granted {
                    print("Granted access")
                    DispatchQueue.main.async(execute: {
                        let imgVC = self.storyboard!.instantiateViewController(withIdentifier: "ImageVC") as? ImageVC
                        imgVC?._pageType = .ScanAadhar
                        if let img_VC = imgVC {
                            self.navigationController?.pushViewController(img_VC, animated: false)
                        }
                    })
                } else {
                    print("Not granted access")
                }
            })
        }
    }
}
