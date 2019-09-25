//
//  PlaceHolderVC.swift
//  AccuraSDK
//
//  Created by Zignuts Technolab on 07/06/19.
//  Copyright © 2019 Elite Development LLC. All rights reserved.
//

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
        print("I did an unwind segway! Holy crap!")
    }
    
    @IBAction func prepare(forUnwind segue: UIStoryboardSegue?) {
        print("I did an unwind segway! Holy crap!")
    }

}

