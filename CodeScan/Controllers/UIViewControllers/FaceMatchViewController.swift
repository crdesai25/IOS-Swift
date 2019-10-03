//
//  FaceMatchViewController.swift
//  AccuraSDK


import UIKit
import SVProgressHUD
import Photos
import Alamofire

class FaceMatchViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    //MARK:- Outlet
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    
    @IBOutlet weak var faceView1: FaceView!
    @IBOutlet weak var faceView2: FaceView!
    
    @IBOutlet weak var imgUpload: UIImageView!
    @IBOutlet weak var imgUpload2: UIImageView!
    @IBOutlet weak var txtUpload: UILabel!
    @IBOutlet weak var txtUpload2: UILabel!
    @IBOutlet var lableMatchRate: UILabel!
    
    //MARK:- Variable
    var imagePicker = UIImagePickerController()
    var arrDocument: [UIImage] = [UIImage]()
    var selectFirstImage = false
    
    //MARK:- UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
         SDK method call to engineWrapper init
         @Return: init status bool value
         */
        let fmInit = EngineWrapper.isEngineInit()
        if !fmInit{
            EngineWrapper.faceEngineInit() //Declaration EngineWrapper
        }
        imagePicker.delegate = self
        
        lableMatchRate.text = "Match Score : 0 %";
        NotificationCenter.default.addObserver(self, selector: #selector(loadPhotoCaptured), name: NSNotification.Name("_UIImagePickerControllerUserDidCaptureItem"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /*
         SDK method call to get engineWrapper load status
         @Return: init status Int value
         */
        let fmValue = EngineWrapper.getEngineInitValue()
        if fmValue == -20{
            GlobalMethods.showAlertView("key not found", with: self)
        }else if fmValue == -15{
            GlobalMethods.showAlertView("License Invalid", with: self)
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
    }
    
    //MARK:- UIButton Action
    @IBAction func actionBack(_ sender: Any) {
        faceView1 = nil
        faceView2 = nil
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func imageCamera1(_ sender: Any) {
        selectFirstImage = true
        imagePicker.sourceType = UIImagePickerController.SourceType.camera
        imagePicker.allowsEditing = false
       imagePicker.modalPresentationStyle = .overCurrentContext
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func imageGallery1(_ sender: Any) {
        self.openPhotosLibrary(_isFirst: true)
    }
    
    @IBAction func imageCamera2(_ sender: Any) {
        selectFirstImage = false
        imagePicker.sourceType = UIImagePickerController.SourceType.camera
        imagePicker.allowsEditing = false
        imagePicker.modalPresentationStyle = .overCurrentContext
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func imageGallery2(_ sender: Any) {
        self.openPhotosLibrary(_isFirst: false)
    }
    
    //MARK:- Custom Methods
   
    /**
     * This method use to check permission photoLibrary and camera
     * Parameters to Pass: bool value first time page open
     *
     */
    
    func openPhotosLibrary(_isFirst: Bool){
        //Check camera permission
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .denied || photos == .notDetermined{
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                    self.openGallary(_isFirst)
                } else {
                    let alert = UIAlertController(title: "AccuraFrame", message: "Please allow Photos access to AccuraFrame \n Goto \n  Setting >> AccuraFrame >> Photos", preferredStyle: .alert);
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(defaultAction)
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }else if photos == .authorized{
            self.openGallary(_isFirst)
        }
    }
    
    /**
     * This method use to opem camera
     * Parameters to Pass: bool value first time page open
     *
     */
    func openGallary(_ isFirst: Bool){
        selectFirstImage = isFirst
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK:- Image Rotation
    @objc func loadPhotoCaptured() {
        let img = allImageViewsSubViews(imagePicker.viewControllers.first?.view)?.last
        if img != nil {
            if let imgView: UIImageView = img as? UIImageView{
                imagePickerController(imagePicker, didFinishPickingMediaWithInfo: convertToUIImagePickerControllerInfoKeyDictionary([convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage) : imgView.image!]))
            }
        } else {
            imagePicker.dismiss(animated: true)
        }
    }
    
    /**
     * This method use get captured view
     * Parameters to Pass: UIView
     *
     * This method will return array of UIImageview
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
    
    //MARK:- ImagePicker delegate
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        
        dismiss(animated: true, completion: nil)
        SVProgressHUD.show(withStatus: "Loading...")
        DispatchQueue.global(qos: .background).async {
            guard var originalImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage else { return }
            

            //Image Resize
            let ratio = CGFloat(originalImage.size.width) / originalImage.size.height
            originalImage = self.compressimage(with: originalImage, convertTo: CGSize(width: 600 * ratio, height: 600))!
            
            let compressData = UIImage(data: originalImage.jpegData(compressionQuality: 1.0)!)
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                self.setFaceRegion(compressData!)//Set FaceMatch score
                SVProgressHUD.dismiss()
            })
        }
        
    }
    
    /**
     * This method use calculate faceMatch score
     * Parameters to Pass: selected uiimage
     *
     */
    func setFaceRegion(_ image: UIImage) {
        var faceRegion : NSFaceRegion?
        if(selectFirstImage){
            /*
             FaceMatch SDK method call to Identify face in Document scanning image
             @Params: BackImage, Front Face Image
             @Return: Face data
             */
            faceRegion = EngineWrapper.detectSourceFaces(image)
        }else{
            let face1 : NSFaceRegion? = faceView1.getFaceRegion(); // Get image data
            if (face1 == nil) {
                /*
                 FaceMatch SDK method call to Identify face in Document scanning image
                 @Params: BackImage, Front Face Image
                 @Return: Face data
                 */
                faceRegion = EngineWrapper.detectSourceFaces(image);
            } else {
                /*
                 FaceMatch SDK method call to detect Face in back image
                 @Params: BackImage, Front Face Image faceRegion
                 @Return: Face Image Frame
                 */
                faceRegion = EngineWrapper.detectTargetFaces(image, feature1: face1?.feature);
            }
        }
        
        if (selectFirstImage){
            if (faceRegion != nil){
                image1.isHidden = true
                /*
                 SDK method call to draw square face around
                 @Params: BackImage, Front Image faceRegion Data
                 */
                faceView1.setFaceRegion(faceRegion)
                
                /*
                 SDK method call to draw square face around
                 @Params: BackImage, Front faceRegion Image
                 */
                faceView1.setImage(faceRegion?.image)
                faceView1.setNeedsDisplay()
                faceView1.isHidden = false
                imgUpload.isHidden = true
                txtUpload.isHidden = true
            }
            
            let face2 : NSFaceRegion? = faceView2.getFaceRegion(); // Get image data
            if (face2 != nil) {
                let face1 : NSFaceRegion? = faceView1.getFaceRegion(); // Get image data
                var faceRegion2 : NSFaceRegion?
                if (face1 == nil){
                    /*
                     FaceMatch SDK method call to Identify face in Document scanning image
                     @Params: BackImage, Front Face Image
                     @Return: Face data
                     */
                    faceRegion2 = EngineWrapper.detectSourceFaces(face2?.image) 
                }else{
                    /*
                     FaceMatch SDK method call to detect Face in back image
                     @Params: BackImage, Front Face Image faceRegion
                     @Return: Face Image Frame
                     */
                    faceRegion2 = EngineWrapper.detectTargetFaces(face2?.image, feature1: face2?.feature)  //Identify face in back image which found in front
                }
                
                if(faceRegion2 != nil){
                    image2.isHidden = true
                    /*
                     SDK method call to draw square face around
                     @Params: BackImage, Front Image faceRegion Data
                     */
                    faceView2.setFaceRegion(faceRegion2)
                    /*
                     SDK method call to draw square face around
                     @Params: BackImage, Front faceRegion Image
                     */
                    faceView2.setImage(faceRegion2?.image)
                    
                    faceView2.setNeedsDisplay()
                    imgUpload2.isHidden = true
                    txtUpload2.isHidden = true
                }
                
            }
        } else if(faceRegion != nil){
            image1.isHidden = true
            image2.isHidden = true
            
            /*
             SDK method call to draw square face around
             @Params: BackImage, Front Image faceRegion Data
             */
            faceView2.setFaceRegion(faceRegion)
            /*
             SDK method call to draw square face around
             @Params: BackImage, Front faceRegion Image
             */
            faceView2.setImage(faceRegion?.image) 
            faceView2.setNeedsDisplay()
            imgUpload2.isHidden = true
            txtUpload2.isHidden = true
        }
        let face1:NSFaceRegion? = faceView1.getFaceRegion() // Get image data
        let face2:NSFaceRegion? = faceView2.getFaceRegion() // Get image data
        
        if ((face1?.face == 0 || face1 == nil) || (face2?.face == 0 || face2 == nil)){
            lableMatchRate.text = "Match Score : 0.0 %";
            return
        }
        arrDocument.removeAll()
        arrDocument.append(face1?.image ?? UIImage())
        arrDocument.append(face2?.image ?? UIImage())
        
        /*
         SDK method call to get FaceMatch Score
         @Params: FrontImage Face, BackImage Face
         @Return: Match Score
         */
        let fmSore = EngineWrapper.identify(face1?.feature, featurebuff2: face2?.feature) 
        let twoDecimalPlaces = String(format: "%.2f", fmSore*100) //Match score Convert Float Value
        lableMatchRate.text = "Match Score : \(twoDecimalPlaces) %"
        self.sendMail("\(twoDecimalPlaces)") //Call Send mail api
    }
    
    //MARK:- Api Calling
    func sendMail(_ matchStore: String){
        var subjectTitle: String = ""
        var mailBody: String = ""
        
        let br = "<br/>";
        
        subjectTitle = "iOS Test - FM \(matchStore)"
        mailBody = "Match Score : \(matchStore) \(br)"
        var dictParam: [String: String] = [String: String]()
        dictParam["mailSubject"] = subjectTitle
        dictParam["platform"] = "iOS"
        dictParam["facematch"] = "False"
        dictParam["liveness"] = "False"
        dictParam["mailBody"] = mailBody
        
        let sharedInstance = NetworkReachabilityManager()!
        var isConnectedToInternet:Bool {
            return sharedInstance.isReachable
        }
        if(isConnectedToInternet){
            let post = PostResult()
            post.postMethodWithParamsAndImage(parameters: dictParam, forMethod: "https://accurascan.com/sendEmailApi/sendEmail.php", image: arrDocument, faceImg:  nil , success: { (response) in
                print(response)
            }) { (error) in
                print(error)
            }
        }
    }
    
    /**
     * This method use image compress particular size
     * Parameters to Pass: UIImage and covert size
     *
     * This method will return compress UIImage
     */
    func compressimage(with image: UIImage?, convertTo size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        image?.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let destImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return destImage
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
