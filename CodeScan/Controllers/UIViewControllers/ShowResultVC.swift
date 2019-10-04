//
//  ShowResultVC.swift
//  AccuraSDK


import UIKit
import ZoomAuthenticationHybrid
import SVProgressHUD
import Alamofire

//Define Global Key
let KEY_TITLE           =  "KEY_TITLE"
let KEY_VALUE           =  "KEY_VALUE"
let KEY_FACE_IMAGE      =  "KEY_FACE_IMAGE"
let KEY_FACE_IMAGE2     =  "KEY_FACE_IMAGE2"
let KEY_DOC1_IMAGE      =  "KEY_DOC1_IMAGE"
let KEY_DOC2_IMAGE      =  "KEY_DOC2_IMAGE"
var MY_ZOOM_DEVELOPER_APP_TOKEN1: String  = "dUfNhktz2Tcl32pGgbPTZ57QujOQBluh"

class ShowResultVC: UIViewController, UITableViewDelegate, UITableViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate,ZoomVerificationDelegate,CustomAFNetWorkingDelegate {
   
    //MARK:- Outlet
    @IBOutlet weak var img_height: NSLayoutConstraint!
    @IBOutlet weak var lblLinestitle: UILabel!
    @IBOutlet weak var tblResult: UITableView!
    @IBOutlet weak var imgPhoto: UIImageView!
    
    @IBOutlet weak var btnLiveness: UIButton!
    @IBOutlet weak var btnFaceMathch: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    //MARK:- Variable
    let obj_AppDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var uniqStr = ""
    var mrz_val = ""
    
    var imgDoc: UIImage?
    var retval: Int = 0
    var lines = ""
    var success = false
    var passportType = ""
    var country = ""
    var surName = ""
    var givenNames = ""
    var passportNumber = ""
    var passportNumberChecksum = ""
    var nationality = ""
    var birth = ""
    var birthChecksum = ""
    var sex = ""
    var expirationDate = ""
    var otherID = ""
    var expirationDateChecksum = ""
    var personalNumber = ""
    var personalNumberChecksum = ""
    var secondRowChecksum = ""
    var placeOfBirth = ""
    var placeOfIssue = ""
    
    var fontImgRotation = ""
    var backImgRotation = ""
    
    var photoImage: UIImage?
    var documentImage: UIImage?
    
    
    var isFirstTime:Bool = false
    var arrDocumentData: [[String:AnyObject]] = [[String:AnyObject]]()
    var dictDataShow: [String:AnyObject] = [String:AnyObject]()
    var appDocumentImage: [UIImage] = [UIImage]()
    var pageType: NAV_PAGETYPE = .Default
    
    var matchImage: UIImage?
    var liveImage: UIImage?
    
    let picker: UIImagePickerController = UIImagePickerController()
    var stLivenessResult: String = ""
    var faceRegion: NSFaceRegion?
    
    //MARK:- UIViewContoller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var dictScanningData:NSDictionary = NSDictionary()
        isFirstTime = true

        /*
         FaceMatch SDK method to check if engine is initiated or not
         Return: true or false
         */
        let fmInit = EngineWrapper.isEngineInit() 
        if !fmInit{
            
            /*
             FaceMatch SDK method initiate SDK engine
             */
            
            EngineWrapper.faceEngineInit()
        }
        
        /*
         Facematch SDK method to get SDK engine status after initialization
         Return: -20 = Face Match license key not found, -15 = Face Match license is invalid.
         */
        let fmValue = EngineWrapper.getEngineInitValue() //get engineWrapper load status
        if fmValue == -20{
            GlobalMethods.showAlertView("key not found", with: self)
        }else if fmValue == -15{
            GlobalMethods.showAlertView("License Invalid", with: self)
        }
        
        //Pagetype using Hidden show button
        if obj_AppDelegate.selectedScanType == .OcrScan{
            btnLiveness.isHidden = true
            btnFaceMathch.isHidden = true
            btnCancel.isHidden = false
        }else{
            btnLiveness.isHidden = false
            btnFaceMathch.isHidden = false
            btnCancel.isHidden = false
            
            /*
             Initialize Zoom SDK and set Controller
             */
            self.initializeZoom()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadPhotoCaptured), name: NSNotification.Name("_UIImagePickerControllerUserDidCaptureItem"), object: nil)
        
        if pageType == .ScanPan || pageType == .ScanAadhar{
            dictScanningData = obj_AppDelegate.dictStoreScanningData // Get Local Store Dictionary
        }else{
            dictScanningData  = UserDefaults.standard.value(forKey: "ScanningData") as! NSDictionary  // Get UserDefaults Store Dictionary
            if let stFontRotaion:String = dictScanningData["fontImageRotation"] as? String{
                fontImgRotation = stFontRotaion
            }
            
            if let stBackRotaion:String = dictScanningData["backImageRotation"] as? String{
                backImgRotation = stBackRotaion
            }
        }
        
        //========================== Filter Scanning data  ==========================//
        if pageType == .ScanPan{
            let strImgURL = dictScanningData["scan_image"] as? String ?? ""
            if let url = URL.init(string: strImgURL) {
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    DispatchQueue.main.async {
                        self.photoImage = UIImage(data: data!)
                        self.faceRegion = nil;
                        if (self.photoImage != nil){
                            self.faceRegion = EngineWrapper.detectSourceFaces(self.photoImage) //Identify face in Document scanning image
                        }
                        let dict = [KEY_FACE_IMAGE: self.photoImage] as [String : AnyObject]
                        if !self.arrDocumentData.isEmpty{
                            self.arrDocumentData[0] = dict
                        }
                        self.tblResult.reloadData()
                    }
                }
            }
            if let stCard: String =  dictScanningData["card"] as? String {
                self.passportType = stCard
            }
            
            if let stDOB: String =  dictScanningData["date of birth"] as? String {
                self.birth = stDOB
            }
            
            if let stName: String =  dictScanningData["name"] as? String {
                self.givenNames = stName
            }
            
            if let stSName: String = dictScanningData["second_name"] as? String {
                self.surName = stSName
            }
            
            if let stPanCardNo: String =  dictScanningData["pan_card_no"] as? String {
                self.passportNumber = stPanCardNo
            }
            
            if let image_documentImage: UIImage = dictScanningData["KEY_DOC1_IMAGE"] as? UIImage {
                appDocumentImage.append(image_documentImage)
            }
            
            self.country = "IND"
            
        }
        else if pageType == .ScanAadhar{
            let strImgURL = dictScanningData["scan_image"] as? String ?? ""
            if let url = URL.init(string: strImgURL) {
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    DispatchQueue.main.async {
                        self.photoImage = UIImage(data: data!)
                        self.faceRegion = nil;
                        if (self.photoImage != nil){
                            self.faceRegion = EngineWrapper.detectSourceFaces(self.photoImage) //Identify face in Document scanning image
                        }
                        let dict = [KEY_FACE_IMAGE: self.photoImage] as [String : AnyObject]
                        if !self.arrDocumentData.isEmpty{
                            self.arrDocumentData[0] = dict
                        }
                        self.tblResult.reloadData()
                    }
                }
            }
            if let stCard: String =  dictScanningData["card"] as? String {
                self.passportType = stCard
            }
            
            if let stDOB: String =  dictScanningData["date of birth"] as? String {
                self.birth = stDOB
            }
            
            if let stName: String =  dictScanningData["name"] as? String {
                self.givenNames = stName
            }
            
            if let stSName: String = dictScanningData["sex"] as? String {
                self.sex = stSName
            }
            
            if let stPanCardNo: String =  dictScanningData["aadhar_card_no"] as? String {
                self.passportNumber = stPanCardNo
            }
            
            if let image_documentImage: UIImage = dictScanningData["KEY_DOC1_IMAGE"] as? UIImage {
                appDocumentImage.append(image_documentImage)
            }
            
            self.country = "IND"
        }
        else{
            if let strline: String =  dictScanningData["lines"] as? String {
                self.lines = strline
            }
            if let strpassportType: String =  dictScanningData["passportType"] as? String  {
                self.passportType = strpassportType
            }
            if let stRetval: String = dictScanningData["retval"] as? String   {
                self.retval = Int(stRetval) ?? 0
            }
            if let strcountry: String =  dictScanningData["country"] as? String {
                self.country = strcountry
            }
            if let strsurName: String = dictScanningData["surName"] as? String {
                self.surName = strsurName
            }
            if let strgivenNames: String =  dictScanningData["givenNames"] as? String  {
                self.givenNames = strgivenNames
            }
            if let strpassportNumber: String = dictScanningData["passportNumber"] as? String   {
                self.passportNumber = strpassportNumber
            }
            if let strpassportType: String =  dictScanningData["passportType"] as? String {
                self.passportType = strpassportType
            }
            
            if let strpassportNumberChecksum: String = dictScanningData["passportNumberChecksum"] as? String {
                self.passportNumberChecksum = strpassportNumberChecksum
            }
            if let strnationality: String =  dictScanningData["nationality"] as? String  {
                self.nationality = strnationality
            }
            if let strbirth: String = dictScanningData["birth"] as? String  {
                self.birth = strbirth
            }
            if let strbirthChecksum: String = dictScanningData["birthChecksum"] as? String{
                self.birthChecksum = strbirthChecksum
            }
            if let strsex: String =  dictScanningData["sex"] as? String {
                self.sex = strsex
            }
            if let strexpirationDate: String = dictScanningData["expirationDate"] as? String {
                self.expirationDate = strexpirationDate
            }
            
            if let strexpirationDateChecksum: String = dictScanningData["expirationDateChecksum"] as? String  {
                self.expirationDateChecksum = strexpirationDateChecksum
            }
            if let strpersonalNumber: String = dictScanningData["personalNumber"] as? String{
                self.personalNumber = strpersonalNumber
            }
            if let strpersonalNumberChecksum: String = dictScanningData["personalNumberChecksum"] as? String {
                self.personalNumberChecksum = strpersonalNumberChecksum
            }
            if let strsecondRowChecksum: String = dictScanningData["secondRowChecksum"] as? String {
                self.secondRowChecksum = strsecondRowChecksum
            }
            if let strplaceOfBirth: String = dictScanningData["placeOfBirth"] as? String{
                self.placeOfBirth = strplaceOfBirth
            }
            if let strplaceOfIssue: String = dictScanningData["placeOfIssue"] as? String {
                self.placeOfIssue = strplaceOfIssue
            }
            if let image_photoImage: Data = dictScanningData["photoImage"] as? Data {
                self.photoImage = UIImage(data: image_photoImage)
                self.faceRegion = nil;
                if (self.photoImage != nil){
                    self.faceRegion = EngineWrapper.detectSourceFaces(photoImage) //Identify face in Document scanning image
                }
            }
            
            if let image_documentFontImage: Data = dictScanningData["docfrontImage"] as? Data  {
                appDocumentImage.append(UIImage(data: image_documentFontImage)!)
            }
            
            if let image_documentImage: Data = dictScanningData["documentImage"] as? Data  {
                appDocumentImage.append(UIImage(data: image_documentImage)!)
            }
            
            imgDoc = documentImage
        }
        //**************************************************************//
        
        //Register Table cell
        self.tblResult.register(UINib.init(nibName: "UserImgTableCell", bundle: nil), forCellReuseIdentifier: "UserImgTableCell")
        
        self.tblResult.register(UINib.init(nibName: "ResultTableCell", bundle: nil), forCellReuseIdentifier: "ResultTableCell")
        
        self.tblResult.register(UINib.init(nibName: "DocumentTableCell", bundle: nil), forCellReuseIdentifier: "DocumentTableCell")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Set TableView Height
        self.tblResult.estimatedRowHeight = 60.0
        self.tblResult.rowHeight = UITableView.automaticDimension
        print("\(retval)")
        
        mrz_val = "CORRECT"
        if retval == 1 {
            mrz_val = "CORRECT"
        } else {
            
        }
        img_height.constant = 0
        imgPhoto.image = photoImage
        self.lblLinestitle.text = lines
        if isFirstTime{
            isFirstTime = false
            self.setData() // this function Called set data in tableView
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // ZoomScanning SDK Reset
        Zoom.sdk.preload()
    }
    
    //MARK:- Custom Methods
    /**
     * This method use set scanning data
     *
     */
    func setData(){
        //Set tableView Data
        if pageType == .ScanPan{
            for index in 0..<7 + appDocumentImage.count{
                var dict: [String:AnyObject] = [String:AnyObject]()
                switch index {
                case 0:
                    dict = [KEY_FACE_IMAGE: photoImage] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 1:
                    dict = [KEY_VALUE: self.passportType,KEY_TITLE:"DOCUMENT : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 2:
                    dict = [KEY_VALUE: self.surName,KEY_TITLE:"LAST NAME : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 3:
                    dict = [KEY_VALUE: self.givenNames,KEY_TITLE:"FIRST NAME : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 4:
                    dict = [KEY_VALUE: self.passportNumber,KEY_TITLE:"PAN CARD NO : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 5:
                    dict = [KEY_VALUE: self.birth,KEY_TITLE:"DATE OF BIRTH : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 6:
                    dict = [KEY_VALUE: self.country,KEY_TITLE:"COUNTRY : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                case 7:
                    dict = [KEY_DOC1_IMAGE: !appDocumentImage.isEmpty ? appDocumentImage[0] : nil] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                default:
                    break
                }
            }
        }else if pageType == .ScanAadhar{
            for index in 0..<7 + appDocumentImage.count + arrDocumentData.count{
                var dict: [String:AnyObject] = [String:AnyObject]()
                switch index {
                case 0:
                    dict = [KEY_FACE_IMAGE: photoImage] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 1:
                    dict = [KEY_VALUE: self.passportType,KEY_TITLE:"DOCUMENT : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 2:
                    dict = [KEY_VALUE: self.givenNames,KEY_TITLE:"FIRST NAME : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 3:
                    dict = [KEY_VALUE: self.passportNumber,KEY_TITLE:"AADHAR CARD NO : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 4:
                    dict = [KEY_VALUE: self.birth,KEY_TITLE:"DATE OF BIRTH : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 5:
                    dict = [KEY_VALUE: self.sex,KEY_TITLE:"SEX : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 6:
                    dict = [KEY_VALUE: self.country,KEY_TITLE:"COUNTRY : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                case 7:
                    dict = [KEY_DOC1_IMAGE: !appDocumentImage.isEmpty ? appDocumentImage[0] : nil] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                default:
                    break
                }
            }
        }
        else{
            for index in 0..<18 + appDocumentImage.count{
                var dict: [String:AnyObject] = [String:AnyObject]()
                switch index {
                case 0:
                    dict = [KEY_FACE_IMAGE: photoImage] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 1:
                    dict = [KEY_VALUE: lines] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 2:
                    var firstLetter: String = ""
                    var strFstLetter: String = ""
                    let strPassportType = passportType.lowercased()
                    
                    if !lines.isEmpty{
                        firstLetter = (lines as? NSString)?.substring(to: 1) ?? ""
                        strFstLetter = firstLetter.lowercased()
                    }
                    
                    var dType: String = ""
                    if strPassportType == "v" || strFstLetter == "v" {
                        dType = "VISA"
                    }
                    else if passportType == "p" || strFstLetter == "p" {
                        dType = "PASSPORT"
                    }
                    else if passportType == "d" || strFstLetter == "p" {
                        dType = "DRIVING LICENCE"
                    }
                    else {
                        if (strFstLetter == "d") {
                            dType = "DRIVING LICENCE"
                        } else {
                            dType = "ID"
                        }
                    }
                    
                    dict = [KEY_VALUE: dType,KEY_TITLE:"DOCUMENT TYPE : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 3:
                    dict = [KEY_VALUE: country,KEY_TITLE:"COUNTRY : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 4:
                    dict = [KEY_VALUE: surName,KEY_TITLE:"LAST NAME : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 5:
                    dict = [KEY_VALUE: givenNames,KEY_TITLE:"FIRST NAME : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 6:
                    let stringWithoutSpaces = passportNumber.replacingOccurrences(of: "<", with: "")
                    dict = [KEY_VALUE: stringWithoutSpaces,KEY_TITLE:"DOCUMENT NO : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                case 7:
                    dict = [KEY_VALUE: passportNumberChecksum,KEY_TITLE:"DOCUMENT CHECK NUMBER : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 8:
                    dict = [KEY_VALUE: nationality,KEY_TITLE:"NATIONALITY : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 9:
                    dict = [KEY_VALUE: date(toFormatedDate: birth),KEY_TITLE:"DATE OF BIRTH : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 10:
                    dict = [KEY_VALUE: birthChecksum,KEY_TITLE:"BIRTH CHECK NUMBER : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 11:
                    var stSex: String = ""
                    if sex == "F" {
                        stSex = "FEMALE";
                    }
                    if sex == "M" {
                        stSex = "MALE";
                    }
                    dict = [KEY_VALUE: stSex,KEY_TITLE:"SEX : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 12:
                    dict = [KEY_VALUE: date(toFormatedDate: expirationDate),KEY_TITLE:"DATE OF EXPIRY : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 13:
                    dict = [KEY_VALUE: expirationDateChecksum,KEY_TITLE:"EXPIRATION CHECK NUMBER : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 14:
                    dict = [KEY_VALUE: personalNumber,KEY_TITLE:"OTHER ID : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 15:
                    dict = [KEY_VALUE: personalNumberChecksum,KEY_TITLE:"OTHER ID CHECK : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 16:
                    dict = [KEY_VALUE: secondRowChecksum,KEY_TITLE:"SECOND ROW CHECK NUMBER : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 17:
                    var stResult: String = ""
                    if retval == 1 {
                        stResult = "CORRECT MRZ";
                    }
                    else if retval == 2 {
                        stResult = "INCORRECT MRZ";
                    }
                    else {
                        stResult = "FAIL";
                    }
                    dict = [KEY_VALUE: stResult,KEY_TITLE:"RESULT : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 18:
                    dict = [KEY_DOC1_IMAGE: !appDocumentImage.isEmpty ? appDocumentImage[0] : nil] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 19:
                    dict = [KEY_DOC2_IMAGE: appDocumentImage.count == 2 ? appDocumentImage[1] : nil] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                default:
                    break
                }
            }
        }
    }
    
    /**
     * This method use lunchZoom setup
     * Make sure initialization was successful before launcing ZoOm
     *
     */
 
    func launchZoomToVerifyLivenessAndRetrieveFacemap() {
     // Make sure initialization was successful before launcing ZoOm
        var reason: String = ""
        var status:ZoomSDKStatus = Zoom.sdk.getStatus()
        switch(status) {
        case .neverInitialized:
            reason = "Initialize was never attempted";
            break;
        case .initialized:
            reason = "The app token provided was verified";
            break;
        case .networkIssues:
            reason = "The app token could not be verified";
            break;
        case .invalidToken:
            reason = "The app token provided was invalid";
            break;
        case .versionDeprecated:
            reason = "The current version of the SDK is deprecated";
            break;
        case .offlineSessionsExceeded:
            reason = "The app token needs to be verified again";
            break;
        case .unknownError:
            reason = "An unknown error occurred";
            break;
        default:
            break;
        }

        if(status != .initialized) {
          let alert = UIAlertController(title: "Get Ready To ZoOm.", message: "ZoOm is not ready to be launched. \nReason: \(reason)", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return;
        }
            
        let vc = Zoom.sdk.createVerificationVC(delegate: self)//Zoom SDK set Delegate
        
        let colors: [AnyObject] = [UIColor(red: 0.04, green: 0.71, blue: 0.64, alpha: 1).cgColor,UIColor(red: 0.07, green: 0.57, blue: 0.76, alpha: 1).cgColor]
        self.configureGradientBackground(arrcolors: colors, inLayer: vc.view.layer)

        // For proper modal presentation of ZoOm interface, modal presentation style must be set as .overFullScreen or .overCurrentContext.
        // UIModalPresentationStyles.formsheet is not currently supported, as it impedes intended ZoOm functionality and user experience.
        // Example of presenting ZoOm using cross dissolve effect

        vc.modalTransitionStyle = .crossDissolve

        // When presenting the ZoOm interface over your own application, you can keep your application showing in the background by using this presentation style

        vc.modalPresentationStyle =  .overCurrentContext

        // Refer to ZoomFrameCustomization for further presentation/interface customization.
        self.present(vc, animated: true, completion: nil)
    }
    
    func initializeZoom(){
        //Initialize the ZoOm SDK using your app token
        Zoom.sdk.initialize(appToken: MY_ZOOM_DEVELOPER_APP_TOKEN1) { (validationResult) in
            if validationResult {
                print("AppToken validated successfully")
            } else {
                if Zoom.sdk.getStatus() != .initialized {
                    self.showInitFailedDialog()
                }
            }
        }
        
        // Configures the look and feel of Zoom
        var currentCustomization = ZoomCustomization()
        currentCustomization.showPreEnrollmentScreen = false; //show Pre-Enrollment screens
        
        // Sample UI Customization: vertically center the ZoOm frame within the device's display
        centerZoomFrameCustomization(currentCustomization);
        
        // Apply the customization changes
        Zoom.sdk.setCustomization(currentCustomization)
        Zoom.sdk.auditTrailType = .height640 //Sets the type of audit trail images to be collected
    }
    
    func showInitFailedDialog(){
        let alert = UIAlertController(title: "Initialization Failed", message: "Please check that you have set your ZoOm app token to the MY_ZOOM_DEVELOPER_APP_TOKEN variable in this file.  To retrieve your app token, visit https://dev.zoomlogin.com/zoomsdk/#/account.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    /**
     * This method use set custom Frame lunchZoom
     *
     */
    func centerZoomFrameCustomization(_ currentCustomization:ZoomCustomization){
        let screenHeight = UIScreen.main.fixedCoordinateSpace.bounds.size.height
        var frameHeight = CGFloat(screenHeight) * CGFloat(currentCustomization.frameCustomization.sizeRatio)
     
        // Detect iPhone X and iPad displays
        if(UIScreen.main.fixedCoordinateSpace.bounds.size.height >= 812) {
            frameHeight = UIScreen.main.fixedCoordinateSpace.bounds.size.width * (16.0/9.0) * CGFloat(currentCustomization.frameCustomization.sizeRatio);
        }

        let topMarginToCenterFrame = (screenHeight - frameHeight)/2.0
      currentCustomization.frameCustomization.topMargin = Double(topMarginToCenterFrame);
    }
    
    func configureGradientBackground(arrcolors:[AnyObject],inLayer:CALayer){
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = UIScreen.main.bounds
        gradient.colors = arrcolors
        gradient.startPoint =  CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        inLayer.addSublayer(gradient)
    }
    
    //Remove Same Value
    func removeOldValue(_ removeKey: String){
        var removeIndex: String = ""
        for (index,dict) in arrDocumentData.enumerated(){
            if dict[KEY_TITLE] != nil{
                if dict[KEY_TITLE] as! String == removeKey{
                    removeIndex = "\(index)"
                }
            }
        }
        if !removeIndex.isEmpty{ arrDocumentData.remove(at: Int(removeIndex)!)}
        tblResult.reloadData()
    }
    
    //MARK:- Image Rotation
    @objc func loadPhotoCaptured() {
        let img = allImageViewsSubViews(picker.viewControllers.first?.view)?.last
        if img != nil {
            if let imgView: UIImageView = img as? UIImageView{
                imagePickerController(picker, didFinishPickingMediaWithInfo: convertToUIImagePickerControllerInfoKeyDictionary([convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage) : imgView.image!]))
            }
        } else {
            picker.dismiss(animated: true)
        }
    }
    
    /**
     * This method is used to get captured view
     * Param: UIView
     * Return: array of UIImageview
     */
    func allImageViewsSubViews(_ view: UIView?) -> [AnyHashable]? {
        var arrImageViews: [AnyHashable] = []
        if (view is UIImageView) {
            if let view = view {
                arrImageViews.append(view)
            }
        } else {
            for subview in view?.subviews ?? [] {
                if let all = allImageViewsSubViews(subview) {
                    arrImageViews.append(contentsOf: all)
                }
            }
        }
        return arrImageViews
    }
    
    /**
     * This method is used to compress image in particular size
     * Param: UIImage and covert size
     * Return: compress UIImage
     */
    func compressimage(with image: UIImage?, convertTo size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        image?.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let destImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return destImage
    }
    
    //MARK: UIButton Method Action
    @IBAction func onCancelAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnLivenessAction(_ sender: UIButton) {
        uniqStr = ProcessInfo.processInfo.globallyUniqueString
        if pageType == .Default{
            self.launchZoomToVerifyLivenessAndRetrieveFacemap() //lunchZoom setup
        }else{
            if photoImage != nil{
               self.launchZoomToVerifyLivenessAndRetrieveFacemap() //lunchZoom setup
            }
        }
    }
    
    @IBAction func btnFaceMatchAction(_ sender: UIButton) {
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .camera
        picker.mediaTypes = ["public.image"]
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func btnCancelAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - UITableView Delegate and Datasource Method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return  self.arrDocumentData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  dictResultData: [String:AnyObject] = arrDocumentData[indexPath.row]
        print(dictResultData)
        if dictResultData[KEY_FACE_IMAGE] != nil{
            //Set User Image
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserImgTableCell") as! UserImgTableCell
            cell.selectionStyle = .none
            if let imageFace: UIImage =  dictResultData[KEY_FACE_IMAGE]  as? UIImage{
                cell.User_img2.isHidden = true
                cell.user_img.image = imageFace
            }
            if dictResultData[KEY_FACE_IMAGE2] != nil{
             cell.User_img2.isHidden = false
                if let imageFace: UIImage =  dictResultData[KEY_FACE_IMAGE2]  as? UIImage{
                    cell.User_img2.image = imageFace
                }
            }
            return cell
        }
       else if dictResultData[KEY_TITLE] != nil || dictResultData[KEY_VALUE] != nil{
            //Set Document data
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResultTableCell") as! ResultTableCell
            cell.selectionStyle = .none
            if dictResultData[KEY_TITLE] == nil && dictResultData[KEY_VALUE] != nil{
                cell.lblValue.isHidden = true
                cell.lblName.isHidden = true
                cell.lblSinglevalue.isHidden = false
                
            }else{
                cell.lblValue.isHidden = false
                cell.lblName.isHidden = false
                cell.lblSinglevalue.isHidden = true
            }
            if(dictResultData[KEY_TITLE]?.isEqual("FACEMATCH SCORE : ") ?? false || dictResultData[KEY_TITLE]?.isEqual("LIVENESS SCORE : ") ?? false){
                cell.lblName.font = UIFont(name: "Aller-Bold", size: 14.0)
                cell.lblValue.font = UIFont(name: "Aller-Bold", size: 14.0)
                
                cell.lblName.textColor = UIColor.darkText
                cell.lblValue.textColor = UIColor.darkText
            }else{
                cell.lblName.font = UIFont(name: "Aller-Regular", size: 14.0)
                cell.lblValue.font = UIFont(name: "Aller-Regular", size: 14.0)
                
                cell.lblName.textColor = UIColor.init(displayP3Red: 85/255, green: 85/255, blue: 85/255, alpha: 1)
                cell.lblValue.textColor =  UIColor.init(displayP3Red: 85/255, green: 85/255, blue: 85/255, alpha: 1)
            }
            cell.lblSinglevalue.text = dictResultData[KEY_VALUE] as? String ?? ""
            cell.lblName.text = dictResultData[KEY_TITLE] as? String ?? ""
            cell.lblValue.text = dictResultData[KEY_VALUE] as? String ?? ""
            return cell
        }else{
            //Set Document Images
            let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentTableCell") as! DocumentTableCell
            cell.selectionStyle = .none
            cell.imgDocument.contentMode = .scaleToFill
            if dictResultData[KEY_DOC1_IMAGE] != nil {
                if pageType == .ScanAadhar || pageType == .ScanPan{
                    cell.lblDocName.text = ""
                    cell.constraintLblHeight.constant = 0
                }else{
                    cell.lblDocName.text = "Front Side :"
                    cell.constraintLblHeight.constant = 25
                }
                if let imageDoc1: UIImage =  dictResultData[KEY_DOC1_IMAGE]  as? UIImage{
                    if fontImgRotation == "Left"{
                        cell.imgDocument.image = UIImage(cgImage: imageDoc1.cgImage!, scale: imageDoc1.scale, orientation: .left)
                        
                    }else if fontImgRotation == "Right"{
                        cell.imgDocument.image = UIImage(cgImage: imageDoc1.cgImage!, scale: imageDoc1.scale, orientation: .right)
                    }else{
                        cell.imgDocument.image = imageDoc1
                    }
                    
                }
            }
            
            if dictResultData[KEY_DOC2_IMAGE] != nil {
                if pageType == .ScanAadhar || pageType == .ScanPan{
                    cell.lblDocName.text = ""
                    cell.constraintLblHeight.constant = 0
                }else{
                    cell.lblDocName.text = "Back Side :"
                    cell.constraintLblHeight.constant = 25
                }
                if let imageDoc2: UIImage =  dictResultData[KEY_DOC2_IMAGE]  as? UIImage{
                    if backImgRotation == "Left"{
                        cell.imgDocument.image = UIImage(cgImage: imageDoc2.cgImage!, scale: imageDoc2.scale, orientation: .left)
                        
                    }else if backImgRotation == "Right"{
                        cell.imgDocument.image = UIImage(cgImage: imageDoc2.cgImage!, scale: imageDoc2.scale, orientation: .right)
                    }else{
                        cell.imgDocument.image = imageDoc2
                    }
                }
            }
            
           
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let  dictResultData: [String:AnyObject] = arrDocumentData[indexPath.row]
        print(dictResultData)
        if dictResultData[KEY_FACE_IMAGE] != nil{
               return 140.0
        }else if dictResultData[KEY_TITLE] == nil && dictResultData[KEY_VALUE] != nil{
            return 90.0
        }
        else if dictResultData[KEY_TITLE] != nil || dictResultData[KEY_VALUE] != nil{
            return 44.0
        }
        else if dictResultData[KEY_DOC1_IMAGE] != nil || dictResultData[KEY_DOC2_IMAGE] != nil{
            return 240
        }else{
            return 0.0
        }
        
    }

    //MARK:- ZoomVerification Methods
    func onZoomVerificationResult(result: ZoomVerificationResult) {
        if result.status == .failedBecauseEncryptionKeyInvalid{
            let alert = UIAlertController(title: "Public Key Not Set.", message: "Retrieving facemaps requires that you generate a public/private key pair per the instructions at https://dev.zoomlogin.com/zoomsdk/#/zoom-server-guide", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else if result.status == .userProcessedSuccessfully {
            SVProgressHUD.show(withStatus: "Loading...")
            self.handleVerificationSuccessResult(result: result)
        }
        else{
             // Handle other error
        }
    }
    
    /**
     * This method use to get liveness image and face match score
     * Parameters to Pass: ZoomVerificationResult data
     *
     */
    func handleVerificationSuccessResult(result:ZoomVerificationResult){
     
        let faceMetrics: ZoomFaceBiometricMetrics = result.faceMetrics!  // faceMetrics data is user scanning face
        var faceImage2: UIImage? = nil
     
        if faceMetrics.auditTrail !=  nil &&  faceMetrics.auditTrail!.count > 0{
            var isFindImg: Bool = false
            for (index,var dict) in arrDocumentData.enumerated(){
                for st in dict.keys{
                    if st == KEY_FACE_IMAGE{
                         // faceMetrics.auditTrail![0] will return user face image from zoom liveness check for face match
                        dict[KEY_FACE_IMAGE2] = faceMetrics.auditTrail![0]
                        arrDocumentData[index] = dict
                        isFindImg = true
                        break
                    }
                    if isFindImg{ break }
                }
            }
            // faceMetrics.auditTrail![0] will return user face image from zoom liveness check for face match
            faceImage2 = faceMetrics.auditTrail?[0];
            matchImage = faceImage2 ?? UIImage();
            liveImage = faceImage2 ?? UIImage();
            //Find Facematch score
            if (faceRegion != nil)
            {
                /*
                 FaceMatch SDK method call to detect Face in back image
                 @Params: BackImage, Front Face Image faceRegion
                 @Return: Face Image Frame
                 */
                
                let face2 = EngineWrapper.detectTargetFaces(faceImage2, feature1: faceRegion!.feature)
                
                /*
                 FaceMatch SDK method call to get FaceMatch Score
                 @Params: FrontImage Face, BackImage Face
                 @Return: Match Score
                 
                 */
                let fm_Score = EngineWrapper.identify(faceRegion!.feature, featurebuff2: face2!.feature)
                let twoDecimalPlaces = String(format: "%.2f", fm_Score*100) //Face Match score convert to float value
                self.removeOldValue("FACEMATCH SCORE : ")
                let dict = [KEY_VALUE: "\((twoDecimalPlaces))",KEY_TITLE:"FACEMATCH SCORE : "] as [String : AnyObject]
                if pageType == .ScanPan || pageType == .ScanAadhar{
                    arrDocumentData.insert(dict, at: 1) // Insert Particular position
                }else{
                    arrDocumentData.insert(dict, at: 2) // Insert Particular position
                }
                
                UIView.animate (withDuration: 0.1, animations: {
                   self.tblResult.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
                }) {(_) in
                    self.tblResult.reloadData()
                }
            }
        }
        self.handleResultFromFaceTecManagedRESTAPICall(_result: result)
    }
    
    /**
     * This method use to get liveness score
     * Parameters to Pass: ZoomVerificationResult user scanning data
     *
     */
    func handleResultFromFaceTecManagedRESTAPICall(_result:ZoomVerificationResult){
        if(_result.faceMetrics != nil)
        {
            let zoomFacemap = _result.faceMetrics?.zoomFacemap //zoomFacemap is Biometric Facemap
            let zoom = zoomFacemap?.base64EncodedString(options: [])

            //Call Liveness Api
            let dictPara: NSMutableDictionary = NSMutableDictionary()
            dictPara["sessionId"] = _result.sessionId
            dictPara["facemap"] = zoom

            //Call liveness Api
            let apiObject = CustomAFNetWorking(post: WS_liveness, withTag: LivenessTag, withParameter: dictPara)
            apiObject?.delegate = self
        }
    }
    
    //MARK:- UIImagePickerController Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        picker.dismiss(animated: true, completion: nil)
        SVProgressHUD.show(withStatus: "Loading...")
        DispatchQueue.global(qos: .background).async {
            guard var chosenImage:UIImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage else{return}
            
            //Capture Image Left flipped
            if picker.sourceType == UIImagePickerController.SourceType.camera && picker.cameraDevice == .front {
                var flippedImage: UIImage? = nil
                if let CGImage = chosenImage.cgImage {
                    flippedImage = UIImage(cgImage: CGImage, scale: chosenImage.scale, orientation: .leftMirrored)
                }
                chosenImage = flippedImage!
            }
            
            //Image Resize
            
            let ratio = CGFloat(chosenImage.size.width) / chosenImage.size.height
            chosenImage = self.compressimage(with: chosenImage, convertTo: CGSize(width: 600 * ratio, height: 600))!
            
            
            self.faceRegion = nil;
            if (self.photoImage != nil){
                /*
                 Accura Face SDK method to detect user face from document image
                 Param: Document image
                 Return: User Face
                 */

                self.faceRegion = EngineWrapper.detectSourceFaces(self.photoImage)
            }
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                if (self.faceRegion != nil){
                    /*
                     Accura Face SDK method to detect user face from selfie or camera stream
                     Params: User photo, user face found in document scanning
                     Return: User face from user photo
                     */
                    let face2 : NSFaceRegion = EngineWrapper.detectTargetFaces(chosenImage, feature1: self.faceRegion?.feature)   //identify face in back image which found in front image
                    
                    /*
                     Accura Face SDK method to get face match score
                     Params: face image from document with user image from selfie or camera stream
                     Returns: face match score
                     */
                    let fm_Score = EngineWrapper.identify(self.faceRegion!.feature, featurebuff2: face2.feature) 
                    if(fm_Score != 0.0){
                        var isFindImg: Bool = false
                        for (index,var dict) in self.arrDocumentData.enumerated(){
                            for st in dict.keys{
                                if st == KEY_FACE_IMAGE{
                                    dict[KEY_FACE_IMAGE2] = chosenImage
                                    self.arrDocumentData[index] = dict
                                    isFindImg = true
                                    break
                                }
                                if isFindImg{ break }
                            }
                        }
                        
                        self.removeOldValue("LIVENESS SCORE : ")
                        self.btnFaceMathch.isHidden = true
                        self.removeOldValue("FACEMATCH SCORE : ")
                        let twoDecimalPlaces = String(format: "%.2f", fm_Score * 100) //Match score Convert Float Value
                        let dict = [KEY_VALUE: "\(twoDecimalPlaces)",KEY_TITLE:"FACEMATCH SCORE : "] as [String : AnyObject]
                        if self.pageType == .ScanPan || self.pageType == .ScanAadhar{
                            self.arrDocumentData.insert(dict, at: 1)
                        }else{
                            self.arrDocumentData.insert(dict, at: 2)
                        }
                    }else {
                        self.btnFaceMathch.isHidden = false
                    }
                }
                UIView.animate (withDuration: 0.1, animations: {
                    self.tblResult.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
                }) {(_) in
                    self.tblResult.reloadData()
                }
                SVProgressHUD.dismiss()
            })
        }
    }
    
    //MARK:-  customURLConnection Delegate
    func customURLConnectionDidFinishLoading(_ connection: CustomAFNetWorking!, withTag tagCon: Int32, withResponse response: Any!) {
        SVProgressHUD.dismiss()
        if tagCon == LivenessTag{
            let dictResponse: NSDictionary = response as? NSDictionary ?? NSDictionary()
            let dictFinalResponse: NSDictionary = dictResponse["data"] as! NSDictionary
            if let livenseeScore: String = dictFinalResponse["livenessResult"] as? String{
                stLivenessResult = livenseeScore
            }
            if let livenessScore: Double = dictFinalResponse["livenessScore"] as? Double{
                self.removeOldValue("LIVENESS SCORE : ")
                btnLiveness.isHidden = true
                let twoDecimalPlaces = String(format: "%.2f", livenessScore)
                let dict = [KEY_VALUE: "\((twoDecimalPlaces))",KEY_TITLE:"LIVENESS SCORE : "] as [String : AnyObject]
                if pageType == .ScanPan || pageType == .ScanAadhar{
                    arrDocumentData.insert(dict, at: 1)
                }else{
                    arrDocumentData.insert(dict, at: 2)
                }
                UIView.animate (withDuration: 0.1, animations: {
                    self.tblResult.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
                }) {(_) in
                    self.tblResult.reloadData()
                }
            }
        }
    }
    
    func customURLConnection(_ connection: CustomAFNetWorking!, withTag tagCon: Int32, didReceive response: URLResponse!) {
        
    }
    
    func customURLConnection(_ connection: CustomAFNetWorking!, withTag tagCon: Int32, didFailWithError error: Error!) {
        SVProgressHUD.dismiss()
    }
    
    func customURLConnection(_ connection: CustomAFNetWorking!, with exception: NSException!, withTag tagCon: Int32) {
        
    }
    
    func customURLConnection(_ connection: CustomAFNetWorking!, withTag tagCon: Int32, didReceive data: Data!) {
        
    }
    
    func customURLConnectionDidFinishLoading(_ connection: CustomAFNetWorking!, withTag tagCon: Int32) {
        
    }
    
    func customURLConnectionDidFinishLoading(_ connection: CustomAFNetWorking!, withTag tagCon: Int32, with data: NSMutableData!) {
        
    }
    
    func customURLConnectionDidFinishLoading(_ connection: CustomAFNetWorking!, withTag tagCon: Int32, with data: NSMutableData!, from url: URL!) {
        
    }
  
    //MARK:- Custom
    func date(toFormatedDate dateStr: String?) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        let date: Date? = dateFormatter.date(from: dateStr ?? "")
        dateFormatter.dateFormat = "dd-MM-yyyy"
        if let date = date {
            return dateFormatter.string(from: date)
        }
        return nil
    }
    
    func date(to dateStr: String?) -> String? {
        // Convert string to date object
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyMMdd"
        let date: Date? = dateFormat.date(from: dateStr ?? "")
        dateFormat.dateFormat = "yyyy-MM-dd"
        if let date = date {
            return dateFormat.string(from: date)
        }
        return nil
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIImagePickerControllerInfoKeyDictionary(_ input: [String: Any]) -> [UIImagePickerController.InfoKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIImagePickerController.InfoKey(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
