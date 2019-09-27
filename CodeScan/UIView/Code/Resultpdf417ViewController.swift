//
//  Resultpdf417ViewController.swift
//  AccuraSDK


import UIKit

class Resultpdf417ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
   
    //MARK:- Outlet
    @IBOutlet weak var tblResult: UITableView!
    @IBOutlet weak var Btnusadl: UIButton!
    @IBOutlet weak var btnPdf417: UIButton!
 
    //MARK:- Variable
    var keyArr = [String]()
    var valueArr = [String]()
    var passStr:String!
    var BtnCheck : Bool!
    
    //MARK:- ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        btnPdf417.layer.cornerRadius = 10
        Btnusadl.layer.cornerRadius = 10

        //Set tableview height
        tblResult.estimatedRowHeight = 65.0;
        tblResult.rowHeight = UITableView.automaticDimension
        
        //Register tableview cell
        tblResult.register(UINib(nibName: "DrivePDFTableViewCell", bundle: nil), forCellReuseIdentifier: "drivePDF")
        tblResult.register(UINib(nibName: "DrivingPDFstringTableViewCell", bundle: nil), forCellReuseIdentifier: "Stringcell")
        BtnCheck = true
        tblResult!.dataSource = self as UITableViewDataSource

    }
    
    //MARK:- UITableview Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if BtnCheck == true {
            return keyArr.count

        }
        else {
        return 1
        }
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
  
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
    if BtnCheck == false {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Stringcell", for: indexPath) as! DrivingPDFstringTableViewCell
        cell.lblWholerstr.text = passStr
        return cell
        
        
    }
    else {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "drivePDF", for: indexPath) as! DrivePDFTableViewCell
            
        cell.lblpreTitle.text = keyArr[indexPath.row] as  String;
        cell.lblValuetitle.text = valueArr[indexPath.row] as  String;
            
            
            
            return cell
        }
    }
    
    //MARK:- UIButton Action
    @IBAction func btnBackpress(_ sender: Any) {
    }
    
    @IBAction func btnOkpress(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnpdf417press(_ sender: Any) {
        BtnCheck = false
        self.tblResult .reloadData()
        let topPath = IndexPath(row: NSNotFound, section: 0)
        self.tblResult.scrollToRow(at: topPath, at: .top, animated: true)

        
    }
    @IBAction func btnUsadlpress(_ sender: Any) {
        BtnCheck = true
        self.tblResult .reloadData()
        let topPath = IndexPath(row: NSNotFound, section: 0)
        self.tblResult.scrollToRow(at: topPath, at: .top, animated: true)

        
    }
   

}
