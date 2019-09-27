//
//  ImageVC.swift
//  AccuraSDK


import UIKit
import SVProgressHUD
import AVFoundation

class ImageVC: UIViewController, AVCapturePhotoCaptureDelegate {
    
    //MARK:-Outlet
    @IBOutlet weak var btnUse: UIButton!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var btn_cancel: UIButton!
    @IBOutlet weak var btn_get_info: UIButton!
    @IBOutlet var _constant_width: NSLayoutConstraint!
    @IBOutlet var _constant_heigtt: NSLayoutConstraint!
    @IBOutlet weak var imageviewLogo: UIImageView!
    
    //MARK:- Variable
    var isFrom: String?
    var isDismiss = false
    var _pageType: NAV_PAGETYPE = .Default
    
    private var originalImage: UIImage?
    let MainStoryBoard = UIStoryboard(name: "MainStoryboard_iPhone", bundle: nil)
    
    var session: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    //MARK:- View Controlller
    override func viewDidLoad() {
        super.viewDidLoad()
        ChangedOrintation()
        NotificationCenter.default.addObserver(self, selector: #selector(self.buttonClicked(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        var with: CGFloat = UIScreen.main.bounds.size.width
        var hite: CGFloat = UIScreen.main.bounds.size.height
        with = with * 0.95
        hite = hite * 0.35
        _constant_heigtt.constant = hite
        _constant_width.constant = with
        
        isDismiss = true
    }
    
    /**
    * This method use image rotated particular degrees
    * Parameters to Pass: UIImage and croping degrees
    *
    * This method will return crop UIImage
    **/
    
    func imageRotated(byDegrees oldImage: UIImage?, deg degrees: CGFloat) -> UIImage? {
        // calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(x: 0, y: 0, width: oldImage?.size.width ?? 0.0, height: oldImage?.size.height ?? 0.0))
        let t = CGAffineTransform(rotationAngle: degrees)
        rotatedViewBox.transform = t
        let rotatedSize: CGSize = rotatedViewBox.frame.size
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap!.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        
        //   // Rotate the image context
        bitmap!.rotate(by: (degrees))
        
        // Now, draw the rotated/scaled image into the context
        bitmap!.scaleBy(x: 1.0, y: -1.0)
        bitmap?.draw((oldImage?.cgImage)!, in: CGRect(x: -(oldImage?.size.width ?? 0.0) / 2, y: -(oldImage?.size.height ?? 0.0) / 2, width: oldImage?.size.width ?? 0.0, height: oldImage?.size.height ?? 0.0))
        
        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    
    /**
    * This method use scanning frame
    * Device orientation acoding set scanning view frame
    */
    func ChangedOrintation() {
        if (UIDevice.current.orientation == .landscapeLeft) {
            //do something or rather
            shouldAutorotate//(to: .landscapeLeft)
            print("landscape left")
            imageviewLogo.isHidden = true
            var hite: CGFloat = UIScreen.main.bounds.size.width
            hite = hite * 0.75
            
            var with: CGFloat = UIScreen.main.bounds.size.height
            with = with * 0.65
            _constant_width.constant = hite
            _constant_heigtt.constant = with
            
        }
        if (UIDevice.current.orientation == .landscapeRight) {
            //do something or rather
            shouldAutorotate//(to: .landscapeRight)
            imageviewLogo.isHidden = true
            print("landscape right")
            
            var hite: CGFloat = UIScreen.main.bounds.size.width
            hite = hite * 0.75
            
            var with: CGFloat = UIScreen.main.bounds.size.height
            with = with * 0.65
            _constant_width.constant = hite
            _constant_heigtt.constant = with
            
        }
        if (UIDevice.current.orientation == .portrait) {
            shouldAutorotate//(to: .portrait)
            print("portrait")
             imageviewLogo.isHidden = false
            var with: CGFloat = UIScreen.main.bounds.size.width
            var hite: CGFloat = UIScreen.main.bounds.size.height
            with = with * 0.95
            hite = hite * 0.35
            
            _constant_heigtt.constant = hite
            _constant_width.constant = with
        }
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
            //code with animation
            self.view.layoutIfNeeded()
        }) { finished in
            //code for completion
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewView.setNeedsDisplay()
        previewView.layoutIfNeeded()
        // Setup your camera here..
        session = AVCaptureSession()
        session!.sessionPreset = AVCaptureSession.Preset.photo
        let backCamera =  AVCaptureDevice.default(for: AVMediaType.video)
        if let device = backCamera {
            do {
                try device.lockForConfiguration()
                device.focusMode = AVCaptureDevice.FocusMode.continuousAutoFocus
                device.unlockForConfiguration()
            }catch{ }
        }
        
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera!)
        } catch let error1 as NSError {
            error = error1
            input = nil
            print(error!.localizedDescription)
        }
        if error == nil && session!.canAddInput(input) {
            session!.addInput(input)
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput?.outputSettings = [AVVideoCodecKey:  AVVideoCodecType.jpeg]
            if session!.canAddOutput(stillImageOutput!) {
                session!.addOutput(stillImageOutput!)
                setupLivePreview()
            }
        }
        
        var with: CGFloat = UIScreen.main.bounds.size.width
        var hite: CGFloat = UIScreen.main.bounds.size.height
        with = with * 0.95
        hite = hite * 0.35
        _constant_heigtt.constant = hite
        _constant_width.constant = with
        frameView.layer.borderColor = UIColor.red.cgColor
        frameView.layer.borderWidth = 3.0
        img.frame = frameView.frame
    }
    
    func setupLivePreview() {
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session!)
        if (videoPreviewLayer != nil) {//Chcek camera session is start
            
            videoPreviewLayer?.videoGravity = .resizeAspect  //VideoView set contentMode
            videoPreviewLayer?.connection!.videoOrientation = .portrait //VideoView set video Orientation
            self.videoPreviewLayer?.frame = UIScreen.main.bounds // set videoView frame
            previewView.layer.addSublayer(videoPreviewLayer!)
            
            //Step12
            let globalQueue = DispatchQueue.global(qos: .default)
            globalQueue.async(execute: {
                self.session!.startRunning() // Start camera session
                
            })
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        btnUse.isHidden = true
        btn_get_info.isHidden = false
        frameView.isHidden = false
        img.isHidden = true
        if isDismiss {
            var with: CGFloat = UIScreen.main.bounds.size.width
            var hite: CGFloat = UIScreen.main.bounds.size.height
            with = with * 0.95
            hite = hite * 0.35
            _constant_heigtt.constant = hite
            _constant_width.constant = with
            
            frameView.layer.borderColor = UIColor.red.cgColor
            frameView.layer.borderWidth = 3.0
        }
        img.frame = frameView.frame
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session!.stopRunning()
    }
    
    //#pragma call delegate
    func sendData(toA dissmiss: Bool) {
        isDismiss = dissmiss
    }
    
    func alert(withMsg strMsg: String?) {
        let alert = UIAlertController(title: APP_NAME, message: strMsg, preferredStyle: .alert)
        
        //Add Buttons
        let okButton = UIAlertAction(title: "OK", style: .default, handler: { action in
            //Handle your yes please button action here
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(okButton)
        present(alert, animated: true)
    }
    
    /**
    * This method use image Orientation particular angle
    * Parameters to Pass: UIImage
    *
    * This method will return  UIImage
    */
    
    func fixedOrientation(_ image: UIImage?) -> UIImage? {
        
        //if let img = image {
        if image!.imageOrientation == .up {
            return image
        }
        
        var transform: CGAffineTransform = .identity
        
        switch image!.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: image!.size.width, y: image!.size.height)
            transform = transform.rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: image!.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(CGFloat(Double.pi / 2)))
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: image!.size.height)
            transform = transform.rotated(by: CGFloat(-(Double.pi / 2)))
        default:
            break
        }
        
        switch image!.imageOrientation {
        case .upMirrored, .downMirrored:
            transform.translatedBy(x: image!.size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform.translatedBy(x: image!.size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        let ctx: CGContext = CGContext(data: nil, width: Int(image!.size.width), height: Int(image!.size.height), bitsPerComponent: image!.cgImage!.bitsPerComponent, bytesPerRow: 0, space: image!.cgImage!.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        ctx.concatenate(transform)
        
        switch image!.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(image!.cgImage!, in: CGRect(origin: CGPoint.zero, size: CGSize.init(width: image!.size.width, height: image!.size.height)))
        default:
            ctx.draw(image!.cgImage!, in: CGRect(origin: CGPoint.zero, size: CGSize.init(width: image!.size.width, height: image!.size.height)))
            break
        }
        
        let cgImage: CGImage = ctx.makeImage()!
        
        return UIImage(cgImage: cgImage)
        
    }
    
    /**
     * This method use image resize particular size
     * Parameters to Pass: UIImage and resize size
     *
     * This method will return resize UIImage
     **/
    
    func image(withResize image: UIImage?, convertTo size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        image?.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let destImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return destImage
    }
    
    //MARK:- UIButon Action
    @objc func buttonClicked(_ sender: UIButton?) {
        ChangedOrintation()
    }
    
    @IBAction func getInfoAction(_ sender: Any) {
        let videoConnection = stillImageOutput!.connection(with: AVMediaType.video)
        if(videoConnection != nil) {
            //Get image for camera view
            stillImageOutput?.captureStillImageAsynchronously(from: videoConnection!, completionHandler: { (sampleBuffer, error) -> Void in
                if sampleBuffer != nil {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer!)
                    let dataProvider = CGDataProvider(data: imageData! as CFData)
                    let cgImageRef = CGImage.init(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.relativeColorimetric)
                    let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImage.Orientation.right)
                    self.session!.stopRunning() //Stop camera view
                    self.img.isHidden = false
                    
                    self.originalImage = self.croppIngimage(byImageName: image, to: self.frameView.frame) //Crop image
                    self.img.image = nil
                    
                    if (UIDevice.current.orientation == .landscapeLeft) {
                        self.originalImage = self.imageRotated(byDegrees: self.originalImage, deg: .pi * 1.5)
                        self.img.image = self.originalImage
                    } else if (UIDevice.current.orientation == .landscapeRight) {
                        self.originalImage = self.imageRotated(byDegrees: self.originalImage, deg: .pi * 90 / 180.0)
                        self.img.image = self.originalImage
                    } else {
                        self.img.image = self.originalImage
                    }
                    
                    self.videoPreviewLayer?.removeFromSuperlayer()
                    self.view.bringSubviewToFront(self.img)
                    self.btn_get_info.isHidden = true
                    self.btnUse.isHidden = false
                    self.frameView.isHidden = true
                    
                }
            })
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func usePhotoAction(_ sender: Any) {
        SVProgressHUD.show(withStatus: "Loading...")
        
        if originalImage == nil {
            
            SVProgressHUD.dismiss()
            
            let alert = UIAlertController(title: "", message: "No Image", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        } else {
            
            var with: CGFloat = UIScreen.main.bounds.size.width
            var hite: CGFloat = UIScreen.main.bounds.size.height
            with = with * 0.95
            hite = hite * 0.35
            originalImage = self.image(withResize: originalImage, convertTo: CGSize(width: with, height: hite))
            
            self.imageUploadRequest() //Call Livness Api
        }
    }
    
    
    //MARK: API CAlling
    func imageUploadRequest() {
        
        var dicParam: [String : String] = [:]
        if _pageType == .ScanPan{
            dicParam["card_type"] = "2"
        }else if _pageType == .ScanAadhar{
            dicParam["card_type"] = "3"
        }else{
            dicParam["card_type"] = "4"
        }
        
        
        let url = URL(string: "https://accurascan.com/v2/api")
        
        var request: NSMutableURLRequest? = nil
        if let url = url {
            request = NSMutableURLRequest(url: url)
        }
        
        request?.httpMethod = "POST"
        request?.setValue("1544605430AuefLvgk7yWX4nnApjO3f90MRARt9dkmJ4EQFVL7", forHTTPHeaderField: "Api-Key")
        let boundary = generateBoundaryString()
        request?.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        if let image = originalImage {
            
            let imageData = image.jpegData(compressionQuality: 1)
            if (imageData == nil) {
                return;
            }
            
            request?.httpBody = createBodyWithParameters(parameters: dicParam, filePathKey: "scan_image", imageDataKey: imageData! as NSData, boundary: boundary) as Data
            
            let task =  URLSession.shared.dataTask(with: request! as URLRequest, completionHandler: {
                (data, response, error) -> Void in
                
                if let data = data {
                    // do what you want in success case
                    let responseString = String(data: data, encoding: .utf8)
                    print("responseString = \(String(describing: responseString))")
                    
                    DispatchQueue.main.async {
                        do {
                            if let json = responseString?.data(using: String.Encoding.utf8) {
                                if let jsonData = try JSONSerialization.jsonObject(with: json, options: .allowFragments) as? [String:AnyObject]{
                                    
                                    if let intStatus = jsonData["status"] as? Int {
                                        if intStatus == 0 {
                                            
                                            let strMsg = jsonData["message"] as? String ?? "Failed to recognize"
                                            
                                            SVProgressHUD.dismiss()
                                            let alert = UIAlertController(title: APP_NAME, message: strMsg, preferredStyle: UIAlertController.Style.alert)
                                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
                                                self.navigationController?.popViewController(animated: true)
                                            }))
                                            self.present(alert, animated: true, completion: nil)
                                        }
                                            
                                        else {
                                            ///
                                            if let arr_value = jsonData["data"] as? [[String:Any]] {
                                                //Print
                                                debugPrint(arr_value)
                                                
                                                if arr_value.count == 1 {
                                                    var data_dict = arr_value.first ?? [:]
                                                    
                                                    let card = data_dict["card"] as? String
                                                    let rangeValue: NSRange? = (card as NSString?)?.range(of: "back", options: .caseInsensitive)
                                                    if rangeValue!.length > 0 {
                                                        
                                                        SVProgressHUD.dismiss()
                                                        let showResultVC = self.storyboard?.instantiateViewController(withIdentifier: "ShowResultVC") as! ShowResultVC
                                                        data_dict[KEY_DOC1_IMAGE] = self.originalImage
                                                        appDelegate.dictStoreScanningData = data_dict as NSDictionary
                                                        showResultVC.pageType = .Default
                                                        self.navigationController?.pushViewController(showResultVC, animated: true)
                                                        
                                                    }
                                                    else {
                                                        SVProgressHUD.dismiss()
                                                        let showResultVC = self.storyboard?.instantiateViewController(withIdentifier: "ShowResultVC") as! ShowResultVC
                                                        data_dict[KEY_DOC1_IMAGE] = self.originalImage
                                                        appDelegate.dictStoreScanningData = data_dict as NSDictionary
                                                        showResultVC.pageType = self._pageType
                                                        self.navigationController?.pushViewController(showResultVC, animated: true)
                                                    }
                                                }
                                                else {
                                                    SVProgressHUD.dismiss()
                                                    
                                                    let alert = UIAlertController(title: APP_NAME, message: jsonData["message"] as? String ?? "", preferredStyle: UIAlertController.Style.alert)
                                                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                                                    self.present(alert, animated: true, completion: nil)
                                                }
                                            }
                                            else {
                                                SVProgressHUD.dismiss()
                                                let alert = UIAlertController(title: APP_NAME, message: jsonData["message"] as? String ?? "", preferredStyle: UIAlertController.Style.alert)
                                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                                                self.present(alert, animated: true, completion: nil)
                                            }
                                        }
                                        
                                    }
                                }
                                
                            }
                        }
                        catch {
                            SVProgressHUD.dismiss()
                            print(error.localizedDescription)
                        }
                    }
                    
                }
                else if let error = error {
                    SVProgressHUD.dismiss()
                    print(error.localizedDescription)
                }
                
            })
            task.resume()
        }
    }
    
    // Create Parameter for Api
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString(string: "--\(boundary)\r\n")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString(string: "\(value)\r\n")
            }
        }
        
        let filename = "user-profile.jpg"
        
        let mimetype = "image/jpg"
        
        body.appendString(string: "--\(boundary)\r\n")
        body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey as Data)
        body.appendString(string: "\r\n")
        
        body.appendString(string: "--\(boundary)--\r\n")
        
        return body
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    /**
    * This method use image crop particular size
    * Parameters to Pass: UIImage and croping size
    *
    * This method will return crop UIImage
    */
    
    func croppIngimage(byImageName imageToCrop: UIImage, to rect: CGRect) -> UIImage? {
        let image: UIImage? = imageToCrop
        let deviceScreen: CGRect = UIScreen.main.bounds
        let width: CGFloat = deviceScreen.size.width
        let height: CGFloat = deviceScreen.size.height
        
        print("WIDTH \(width)")
        print("HEIGHT \(height)")
        //      UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 1.0)
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        image?.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        let smallImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        var tempRect = rect
        tempRect.origin.y = tempRect.origin.y - 20 //- 50
        if (UIDevice.current.orientation == .portrait) {
            tempRect.size.height = tempRect.size.height + (UIScreen.main.bounds.height * 0.075)
        }
        else {
            tempRect.origin.y = tempRect.origin.y - (UIScreen.main.bounds.height * 0.045)
            tempRect.size.height = tempRect.size.height + (UIScreen.main.bounds.height * 0.15)
        }
        
        let imageRef = smallImage?.cgImage?.cropping(to: tempRect)
        var cropped: UIImage? = nil
        if let imageRef = imageRef {
            cropped = UIImage(cgImage: imageRef)
        }
        return cropped
    }
}

// extension for impage uploading
extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
