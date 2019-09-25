//
//  PostResult.swift
//  Accura Scan
//
//  Created by Mudassir Abbas on 04/08/2019.
//  Copyright © 2019 Elite Development LLC. All rights reserved.
//

import UIKit
import Alamofire

typealias SuccessBlock = (_ response: AnyObject) -> Void
typealias FailureBlock = (_ response: AnyObject) -> Void
typealias ProgressBlock = (_ response: AnyObject) -> Void
@objc
 class PostResult: NSObject {

    @objc func postMethodWithParamsAndImage(parameters: [String:String], forMethod: String, image: [UIImage],faceImg:UIImage?, success:@escaping SuccessBlock, fail:@escaping FailureBlock){
        let manager = Alamofire.SessionManager.default
        let headers: HTTPHeaders?
        headers =  ["Content-Type": "application/json"]
        manager.upload(
            multipartFormData: { multipartFormData in
                print(parameters)
                print(image as Any)
                if !image.isEmpty {
                    for i in 0..<image.count {
                        let img = image[i]
                        let imgData = img.jpeg(.medium)
                        if i == 0{
                            multipartFormData.append(imgData!, withName: "imageFront", fileName: "frontImage.jpg", mimeType: "image/jpg")
                        }else{
                        multipartFormData.append(imgData!, withName: "imageBack", fileName: "backImage.jpg", mimeType: "image/jpg")
                        }
                    }
                    if faceImg != nil{
                        if let faceData: Data = faceImg!.jpeg(.medium){
                            multipartFormData.append(faceData, withName: "imageFace", fileName: "faceImage.jpg", mimeType: "image/jpg")
                        }
                    }
                }
                if !(parameters.isEmpty) {
                    for (key, value) in parameters {
                        print("key: \(key) -> val: \(value)")
                        if let dic = value as? Dictionary<String,AnyObject>{
                            print(key)
                            print(value)
                            do {
                                let jsonData = try JSONSerialization.data(withJSONObject: dic, options: [])
                                let str = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
                                multipartFormData.append(str.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: key)
                            } catch {
                                print(error.localizedDescription)
                            }

                        }else{
                            multipartFormData.append(value.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: key)
                        }

                    }
                }
                print(multipartFormData)
        },
            to: forMethod,  method: .post, headers: headers, encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.uploadProgress(closure: { (progress) in
                        print(progress)
                    })
                    upload.responseJSON { response in

                        success(response.result.value as AnyObject)
                    }
                case .failure(let encodingError):

                    fail(encodingError as AnyObject)
                }
        })
    }
    
}

//extension UIImage {
//    
//    enum JPEGQuality: CGFloat {
//        case lowest  = 0
//        case low     = 0.25
//        case medium  = 0.5
//        case high    = 0.75
//        case highest = 1
//    }
//    
//    var png: Data? { return UIImagePNGRepresentation(self) }
//    
//    func jpeg(_ quality: JPEGQuality) -> Data? {
//        return UIImageJPEGRepresentation(self, quality.rawValue)
//    }
//    
//    
//    
//    func imageWithColor(color1: UIColor) -> UIImage {
//        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
//        color1.setFill()
//        
//        let context = UIGraphicsGetCurrentContext()!
//        context.translateBy(x: 0, y: self.size.height)
//        context.scaleBy(x: 1.0, y: -1.0);
//        context.setBlendMode(CGBlendMode.normal)
//        
//        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
//        context.clip(to: rect, mask: self.cgImage!)
//        context.fill(rect)
//        
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
//        UIGraphicsEndImageContext()
//        
//        return newImage
//    }
//    
//    
//    
//    
//    
//    var rounded: UIImage? {
//        let imageView = UIImageView(image: self)
//        imageView.layer.cornerRadius = min(size.height/2, size.width/2)
//        imageView.layer.masksToBounds = true
//        UIGraphicsBeginImageContext(imageView.bounds.size)
//        guard let context = UIGraphicsGetCurrentContext() else { return nil }
//        imageView.layer.render(in: context)
//        let result = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return result
//    }
//    var circle: UIImage? {
//        let square = CGSize(width: min(size.width, size.height), height: min(size.width, size.height))
//        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
//        imageView.contentMode = .scaleToFill
//        imageView.image = self
//        imageView.layer.cornerRadius = square.width/2
//        imageView.layer.masksToBounds = true
//        UIGraphicsBeginImageContext(imageView.bounds.size)
//        guard let context = UIGraphicsGetCurrentContext() else { return nil }
//        imageView.layer.render(in: context)
//        let result = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return result
//    }
//    
//}
extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return self.jpegData(compressionQuality: jpegQuality.rawValue)
    }
}
