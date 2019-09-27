//
//  FirstViewVC.swift
//  AccuraSDK

import UIKit

class FirstViewVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //MARK:- Outlet
    @IBOutlet weak var tblFirst: UITableView!
    
    //MARK:- View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
          self.tblFirst.register(UINib.init(nibName: "FirstTableViewCell", bundle: nil), forCellReuseIdentifier: "FirstTableViewCell")
        // Do any additional setup after loading the view.
    }
    
    //MARK:- TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 155
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FirstTableViewCell") as! FirstTableViewCell
        cell.selectionStyle = .none
        
        switch indexPath.row {
        case 0:
            cell.lblTitle.text = "ACCURA OCR"
            cell.lblContect.text = "Recognizes Passport & ID MRZ. Pan & Aadhaar Cards India. Works Offline"
            cell.view.backgroundColor = UIColor(red: 213.0 / 255.0, green: 50.0 / 255.0 , blue: 63.0 / 255.0, alpha: 1.0)
            cell.view.layer.cornerRadius = 10
            cell.iconImg.image = UIImage(named: "icn_Ocr")
            cell.view.layer.masksToBounds = true
            break
        case 1:
            
            cell.lblTitle.text = "ACCURA FACE MATCH"
            cell.lblContect.text = "AI & ML Based Powerful Face Detection & Recognition Solution. 1:1 and 1:N. Works Offline"
            cell.view.backgroundColor = UIColor(red: 154.0 / 255.0, green: 154.0 / 255.0 , blue: 154.0 / 255.0, alpha: 1.0)
            cell.view.layer.cornerRadius = 10
            cell.iconImg.image = UIImage(named: "Icn_Face_Scan")
            cell.view.layer.masksToBounds = true
            break
        case 2:
            cell.lblTitle.text = "ACCURA AUTHENTICATION"
            cell.lblContect.text = "eKYC and Digital Customer On-Boarding & Real Time Face Biometrics with Zoom Certified Liveness Detection for Real Time User Authentication"
            cell.view.backgroundColor = UIColor(red: 213.0 / 255.0, green: 50.0 / 255.0, blue: 63.0 / 255.0, alpha: 1.0)
            cell.view.layer.cornerRadius = 10
            cell.iconImg.image = UIImage(named: "icn_Scan")
            cell.view.layer.masksToBounds = true
            break
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        switch indexPath.row {
        case 0:
            print("Accura OCR")
            let MainStoryBoard = UIStoryboard(name: "MainStoryboard_iPhone", bundle: nil)
            let ocrVC = MainStoryBoard.instantiateViewController(withIdentifier: "ListViewVC") as? ListViewVC
            ocrVC?._stTitle = "ACCURA OCR"
            appDelegate?.selectedScanType = .OcrScan
            if let ocrVC = ocrVC {
                navigationController?.pushViewController(ocrVC, animated: true)
            }
        case 1:
            print("Face Match")
            let MainStoryBoard = UIStoryboard(name: "MainStoryboard_iPhone", bundle: nil)
            let faceVC = MainStoryBoard.instantiateViewController(withIdentifier: "FaceMatchViewController") as? FaceMatchViewController
            appDelegate?.selectedScanType = .FMScan
            if let faceVC = faceVC {
                navigationController?.pushViewController(faceVC, animated: true)
            }
        case 2:
            print("Accura Scan")
            let MainStoryBoard = UIStoryboard(name: "MainStoryboard_iPhone", bundle: nil)
            let scanVC = MainStoryBoard.instantiateViewController(withIdentifier: "ListViewVC") as? ListViewVC
             appDelegate?.selectedScanType = .AccuraScan
            scanVC?._stTitle = "ACCURA SCAN"
            if let scanVC = scanVC {
                navigationController?.pushViewController(scanVC, animated: true)
            }
        default:
            break
        }

    }
    
    //MARK:- Button Action
    @IBAction func visitAccuraScanBtnAction(_ sender: UIButton) {
        let application: UIApplication = UIApplication.shared
        let URL: NSURL = NSURL(string: "https://www.accurascan.com")!
        application.open(URL as URL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: { (success: Bool) in
            if success {
                print("Opened url")
            }
            
        })
    }
    
    @IBAction func emailUsBtnAction(_ sender: UIButton) {
        let application: UIApplication = UIApplication.shared
        let URL: NSURL = NSURL(string: "mailto:connect@accurascan.com")!
        application.open(URL as URL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: { (success: Bool) in
            if success {
                print("Opened url")
            }
            
        })
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
