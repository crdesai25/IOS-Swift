//
//  FaceMatchViewController.swift
//  AccuraSDK
//
//  Created by Technozer on 8/20/19.
//  Copyright © 2019 Elite Development LLC. All rights reserved.
//

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
        let fmInit = EngineWrapper.isEngineInit()  //Check engineWrapper init or not init
        if !fmInit{
            EngineWrapper.faceEngineInit() //Declaration EngineWrapper
        }
         imagePicker.delegate = self
        
        lableMatchRate.text = "Match Score : 0 %";
        NotificationCenter.default.addObserver(self, selector: #selector(loadPhotoCaptured), name: NSNotification.Name("_UIImagePickerControllerUserDidCaptureItem"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let fmValue = EngineWrapper.getEngineInitValue() //get engineWrapper load status value
        if fmValue == -20{
                GlobalMethods.showAlertView("key not found", with: self)
        }else if fmValue == -15{
                GlobalMethods.showAlertView("License Invalid", with: self)
        }
    }
    

    override func viewDidDisappear(_ animated: Bool) {
       // EngineWrapper.faceEngineClose()
    }

    //MARK:- UIButton Action
    @IBAction func actionBack(_ sender: Any) {
        faceView1 = nil
        faceView2 = nil
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func imageCamera1(_ sender: Any) {
        selectFirstImage = true
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func imageGallery1(_ sender: Any) {
        self.openPhotosLibrary(_isFirst: true)
    }
    
    @IBAction func imageCamera2(_ sender: Any) {
        selectFirstImage = false
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func imageGallery2(_ sender: Any) {
        self.openPhotosLibrary(_isFirst: false)
    }

    //MARK:- Custom Methods
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
    
    func openGallary(_ isFirst: Bool){
        selectFirstImage = isFirst
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK:- Image Rotation
    @objc func loadPhotoCaptured() {
        let img = allImageViewsSubViews(imagePicker.viewControllers.first?.view)?.last
        if img != nil {
            if let imgView: UIImageView = img as? UIImageView{
                imagePickerController(imagePicker, didFinishPickingMediaWithInfo: [UIImagePickerControllerOriginalImage : imgView.image!])
            }
        } else {
            imagePicker.dismiss(animated: true)
        }
    }
    
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
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        dismiss(animated: true, completion: nil)
        SVProgressHUD.show(withStatus: "Loading...")
        DispatchQueue.global(qos: .background).async {
            guard var originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
          
            //Capture Image Left flipped
            if picker.sourceType == UIImagePickerController.SourceType.camera && picker.cameraDevice == .front {
                var flippedImage: UIImage? = nil
                if let CGImage = originalImage.cgImage {
                    flippedImage = UIImage(cgImage: CGImage, scale: originalImage.scale, orientation: .leftMirrored)
                }
                originalImage = flippedImage!
            }
            //Image Resize
            let ratio = CGFloat(originalImage.size.width) / originalImage.size.height
            originalImage = self.compressimage(with: originalImage, convertTo: CGSize(width: 360 * ratio, height: 360))!
            
            let compressData = UIImage(data: UIImageJPEGRepresentation(originalImage, 0.1)!)
           // if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                    self.setFaceRegion(compressData!)//Set FaceMatch score
                    SVProgressHUD.dismiss()
                })
            //}
        }
        
    }
    
    func setFaceRegion(_ image: UIImage) {
        var faceRegion : NSFaceRegion?
        if(selectFirstImage){
            faceRegion = EngineWrapper.detectSourceFaces(image)
        }else{
            let face1 : NSFaceRegion? = faceView1.getFaceRegion();
            if (face1 == nil) {
                faceRegion = EngineWrapper.detectSourceFaces(image);
            } else {
                faceRegion = EngineWrapper.detectTargetFaces(image, feature1: face1?.feature);
            }
        }
        
        if (selectFirstImage){
            if (faceRegion != nil){
                image1.isHidden = true
                faceView1.setFaceRegion(faceRegion)
                faceView1.setImage(faceRegion?.image)
                faceView1.setNeedsDisplay()
                faceView1.isHidden = false
                imgUpload.isHidden = true
                txtUpload.isHidden = true
                
            }
            
            let face2 : NSFaceRegion? = faceView2.getFaceRegion();
            if (face2 != nil) {
                let face1 : NSFaceRegion? = faceView1.getFaceRegion();
                var faceRegion2 : NSFaceRegion?
                if (face1 == nil){
                    faceRegion2 = EngineWrapper.detectSourceFaces(face2?.image)
                }else{
                    faceRegion2 = EngineWrapper.detectTargetFaces(face2?.image, feature1: face2?.feature)
                }

                if(faceRegion2 != nil){
                    image2.isHidden = true
                    faceView2.setFaceRegion(faceRegion2)
                    faceView2.setImage(faceRegion2?.image)
                    faceView2.setNeedsDisplay()
                    imgUpload2.isHidden = true
                    txtUpload2.isHidden = true
                }
            
            }
        } else if(faceRegion != nil){
            image1.isHidden = true
            image2.isHidden = true
            
            faceView2.setFaceRegion(faceRegion)
            faceView2.setImage(faceRegion?.image)
            faceView2.setNeedsDisplay()
            imgUpload2.isHidden = true
            txtUpload2.isHidden = true
        }
        let face1:NSFaceRegion? = faceView1.getFaceRegion()
        let face2:NSFaceRegion? = faceView2.getFaceRegion()
        
        if (face1==nil || face2==nil){
            lableMatchRate.text = "Match Score : 0.0 %";
            return
        }
        arrDocument.removeAll()
        arrDocument.append(face1?.image ?? UIImage())
        arrDocument.append(face2?.image ?? UIImage())
        let fmSore = EngineWrapper.identify(face1?.feature, featurebuff2: face2?.feature) //Find FaceMatch Score
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
    
    //Comapress Image
    func compressimage(with image: UIImage?, convertTo size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        image?.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let destImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return destImage
    }
    
}


extension UIImage {
    func resizeWithPercent(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    func resizeWithWidth(width: CGFloat, height:CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: height)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}
