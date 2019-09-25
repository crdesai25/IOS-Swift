//
//  ListViewVC.swift
//  AccuraSDK
//
//  Created by Zignuts Technolab on 07/06/19.
//  Copyright © 2019 Elite Development LLC. All rights reserved.
//

import UIKit

class ListViewVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //MARK:- Outlet
    @IBOutlet var tblList: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    
    //MARK:- Variable
    internal var _stTitle: String = ""
    
    //MARK:- ViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tblList.register(UINib.init(nibName: "ListTableCell", bundle: nil), forCellReuseIdentifier: "ListTableCell")
        lblTitle.text = _stTitle
    }
    
    //MARK:- Button Action
    @IBAction func btnBackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: UITableView Delegate and Datasource method
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableCell") as! ListTableCell
        cell.selectionStyle = .none
        
        switch indexPath.row {
        case 0:
            cell.lbl_list_title.text = "Passport & ID MRZ"
            cell.vw.backgroundColor = #colorLiteral(red: 0.8352941176, green: 0.1960784314, blue: 0.2470588235, alpha: 1)
            cell.vw.layer.cornerRadius = 10
            cell.img.image = UIImage.init(named: "pass_mrz_ic")
            cell.vw.layer.masksToBounds = true;
            
        case 1:
            cell.lbl_list_title.text = "USA Driving License"
            cell.vw.backgroundColor = #colorLiteral(red: 0.6039215686, green: 0.6039215686, blue: 0.6039215686, alpha: 1)
            cell.vw.layer.cornerRadius = 10
            cell.img.image = UIImage.init(named: "usa_driving_ic")
            cell.vw.layer.masksToBounds = true

        case 2:
            cell.lbl_list_title.text = "Pan Card India"
            cell.vw.backgroundColor = #colorLiteral(red: 0.8352941176, green: 0.1960784314, blue: 0.2470588235, alpha: 1)
            cell.vw.layer.cornerRadius = 10
            cell.img.image = UIImage.init(named: "pan_card")
            cell.vw.layer.masksToBounds = true;
            
        case 3:
            cell.lbl_list_title.text = "Aadhaar Card India"
            cell.vw.backgroundColor = #colorLiteral(red: 0.6039215686, green: 0.6039215686, blue: 0.6039215686, alpha: 1)
            cell.vw.layer.cornerRadius = 10
            cell.img.image = UIImage.init(named: "aadhar_card")
            cell.vw.layer.masksToBounds = true;

        case 4:
            cell.lbl_list_title.text = "Barcode & PDF417"
            cell.vw.backgroundColor = #colorLiteral(red: 0.8352941176, green: 0.1960784314, blue: 0.2470588235, alpha: 1)
            cell.vw.layer.cornerRadius = 10
            cell.img.image = UIImage.init(named: "white")
            cell.vw.layer.masksToBounds = true;
            
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            print("Passport & id MRZ")
            let MainStoryBoard = UIStoryboard(name: "MainStoryboard_iPhone", bundle: nil)
            let placeVC = MainStoryBoard.instantiateViewController(withIdentifier: "PlaceHolderVC") as? PlaceHolderVC
            if let placeVC = placeVC {
                navigationController?.pushViewController(placeVC, animated: true)
            }
            
        case 1:
            print("Usa Driving license")
            UserDefaults.standard.set("1", forKey: "isFromUSA")
            let codeStory = UIStoryboard(name: "CodeScanVC", bundle: nil)
            let placeVC = codeStory.instantiateViewController(withIdentifier: "PlaceViewController") as? PlaceViewController
            if let placeVC = placeVC {
                navigationController?.pushViewController(placeVC, animated: true)
            }
        case 2:
            print("Pan Card")
            let MainStoryBoard = UIStoryboard(name: "MainStoryboard_iPhone", bundle: nil)
            let objPan = MainStoryBoard.instantiateViewController(withIdentifier: "PlacePanCardVC") as! PlacePanCardVC
            self.navigationController?.pushViewController(objPan, animated: true)

        case 3:
            print("Aadhaar card")
            let MainStoryBoard = UIStoryboard(name: "MainStoryboard_iPhone", bundle: nil)
            let objAadhar = MainStoryBoard.instantiateViewController(withIdentifier: "PlaceAdharCardVC") as! PlaceAdharCardVC
            self.navigationController?.pushViewController(objAadhar, animated: true)
            
        case 4:
            print("BarCode & PDF417")
            UserDefaults.standard.set("0", forKey: "isFromUSA")
            let codeStory = UIStoryboard(name: "CodeScanVC", bundle: nil)
            let placeVC = codeStory.instantiateViewController(withIdentifier: "PlaceViewController") as? PlaceViewController
            if let placeVC = placeVC {
                navigationController?.pushViewController(placeVC, animated: true)
            }
            
        default:
            break
        }
    }
   
}
