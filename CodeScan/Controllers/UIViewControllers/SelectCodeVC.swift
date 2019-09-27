//
//  SelectCodeVC.swift
//  CodeScan
//
//  ******************** File use to display list of barcode (for select or deselect particular barcode) ******************

import UIKit
import AVFoundation

protocol SelectedTypesDelegate {
    func setSelectedTypes(types: [AVMetadataObject.ObjectType])
}

class SelectCodeVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    //MARK:- Outlet
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- Variable
    let Types: [AVMetadataObject.ObjectType] = [.ean8, .ean13, .pdf417, .aztec, .code128, .code39, .code39Mod43, .code93, .dataMatrix, .face, .interleaved2of5, .itf14, .qr, .upce]
    var selectedTypes: [AVMetadataObject.ObjectType] = [AVMetadataObject.ObjectType]()
    var selectedTypesDelegate: SelectedTypesDelegate!
    
    //MARK:- UIView Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        //Register tableView cell
        tableView.register(BarcodeTypeTVC.nib(), forCellReuseIdentifier: BARCODE_TYPE_TVC)
        
        addBarButton(imageNormal: BACK_WHITE, imageHighlighted: nil, action: #selector(backBtnPressed), side: .west)
    }
    
    //MARK:- UITableView Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let barcodeTypeHFV = BarcodeTypeHFV.nib()
        return barcodeTypeHFV
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Types.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let type = Types[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: BARCODE_TYPE_TVC, for: indexPath) as! BarcodeTypeTVC
        
        if selectedTypes.contains(type) {
            cell.setSelected(code: type)
        } else {
            cell.setUnselected(code: type)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let type = (tableView.cellForRow(at: indexPath) as! BarcodeTypeTVC).code.rawValue
        if let index = selectedTypes.firstIndex(where: { $0.rawValue == type }), selectedTypes.contains(AVMetadataObject.ObjectType(rawValue: type)) {
            selectedTypes.remove(at: index)
        } else {
            selectedTypes.append(AVMetadataObject.ObjectType(rawValue: type))
        }
        tableView.reloadData()
    }
    
    //MARK:- UIButton Action 
    @objc func backBtnPressed() {
       selectedTypesDelegate.setSelectedTypes(types: selectedTypes)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backAction(_ sender: Any)
    {
        selectedTypesDelegate.setSelectedTypes(types: selectedTypes)
        navigationController?.popViewController(animated: true)
    }
    
}
