//
//  PlaceViewController.swift
//  AccuraSDK
//
// ****************** File Use to display place holder screen before barcode scan *********************

import UIKit

class PlaceViewController: UIViewController
{

   //MARK:- Outlet
    @IBOutlet weak var imgPlace: UIImageView!
    @IBOutlet weak var lbl_place: UILabel!
   
    //MARK:- Variable
    let prefs:UserDefaults = UserDefaults.standard

    //MARK:- UIViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let isFrom:String! = prefs.value(forKey: "isFromUSA") as? String
        if isFrom == "1"
        {
            print("chnage image")
            imgPlace.image = UIImage(named: "usa_place");
            lbl_place.text = "PLACE YOUR DRIVING LICENCE LIKE THIS"
        }
        else
        {
            imgPlace.image = UIImage(named: "place_qr");
            lbl_place.text = "PLACE YOUR BARCODE LIKE THIS"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- UIButton Action
    @IBAction func btnStartScanningpress(_ sender: Any) {
        
        let loginVC = UIStoryboard(name: "CodeScanVC", bundle: nil).instantiateViewController(withIdentifier: "CodeScanVC") as! CodeScanVC
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
    
    @IBAction func backAction(_ sender: Any)
    {
        navigationController?.popViewController(animated: true)
    }
    
   

}
