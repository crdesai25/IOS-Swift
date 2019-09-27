//
//  PlaceHolderVC.swift
//  AccuraSDK


import UIKit

class PlaceHolderVC: UIViewController {

    private var isPdf = false
    private var dataArr: [AnyHashable] = []
    private var scanInfoArray: [AnyHashable] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    // MARK: - UIButton Action

    @IBAction func menuAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func back(toPlaceHolder segue: UIStoryboardSegue?) {
    }
    
    @IBAction func prepare(forUnwind segue: UIStoryboardSegue?) {
        
    }

}

