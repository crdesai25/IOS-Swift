//
//  AFWrapper.swift
//  swiftyjsondemo


import UIKit
import Alamofire
import SwiftyJSON


class AFWrapper: Alamofire.SessionManager
{
    // get method
    class func requestGETURL(_ strURL: String, params : [String : AnyObject]?, headers : [String : String]?, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        
        self.default.request(strURL, method: .get, parameters: params, encoding: URLEncoding(destination: .httpBody), headers: headers).responseJSON { (responseObject) in
            print(responseObject)
            
            if responseObject.result.isSuccess {
                let resJson = JSON(responseObject.result.value!)
                success(resJson)
            }
            if responseObject.result.isFailure {
                let error : Error = responseObject.result.error!
                failure(error)
            }
        }
    }
    
    
    // post method
    class func requestPOSTURL(_ strURL : String, params : [String : AnyObject]?, headers : [String : String]?, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void){
        
            self.default.request(strURL, method: .post, parameters: params, encoding: URLEncoding(destination: .httpBody), headers: headers).responseJSON { (responseObject) in
                print(responseObject)
                
                if responseObject.result.isSuccess {
                    let resJson = JSON(responseObject.result.value!)
                    success(resJson)
                }
                if responseObject.result.isFailure {
                    let error : Error = responseObject.result.error!
                    failure(error)
                }
        }
        
    //        Alamofire.SessionManager.request(strURL, method: .post, parameters: params, encoding: URLEncoding(destination: .httpBody), headers: headers).responseJSON { (responseObject) -> Void in
    //            
    //            
    //        }
        }
    
    // Delete method
    class func requestDeleteURL(_ strURL: String, params : [String : AnyObject]?, headers : [String : String]?, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        
        self.default.request(strURL, method: .delete, parameters: params, encoding: URLEncoding(destination: .httpBody), headers: headers).responseJSON { (responseObject) in
            print(responseObject)
            
            if responseObject.result.isSuccess {
                let resJson = JSON(responseObject.result.value!)
                success(resJson)
            }
            if responseObject.result.isFailure {
                let error : Error = responseObject.result.error!
                failure(error)
            }
        }
    }
    // upload image with peram
    class func requestPOSTURLwithUplodeImage(_ strURL : String, params : [String: String]?, image : UIImageView, headers : [String : String]?, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void){
        
        self.default.upload(multipartFormData:
            {
                multipartFormData in
                
                if let imageData = image.image!.pngData()
                {
                    multipartFormData.append(imageData, withName: "image", fileName: "image.png", mimeType: "image/png")
                }
                
                for (key, value) in params!
                {
                    multipartFormData.append((value.data(using: .utf8))!, withName: key)
                }
                
        }, to: strURL, method: .post, headers: headers,
           encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    let resJson = JSON(response.result.value!)
                    success(resJson)
                }
            case .failure(let encodingError):
                let error : Error = encodingError
                failure(error)
                
            }
        })
    }
    
    // upload image with peram
    class func requestPOSTURLwithUplodeImageMulti(_ strURL : String, params : [String: String]?, image : NSMutableArray, headers : [String : String]?, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void)
    {
        
        self.default.upload(multipartFormData:
            {
                multipartFormData in
                 var count = 1
                for img in image
                {
                    let imgdata = (img as! UIImage).jpegData(compressionQuality: 1.0)
                    multipartFormData.append(imgdata!,withName: "documents[]", fileName: "documents\(count).jpg", mimeType: "image/jpeg")
                    count += 1
                }
                for (key, value) in params!
                {
                    multipartFormData.append((value.data(using: .utf8))!, withName: key)
                }
                
        }, to: strURL, method: .post, headers: headers,
           encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    let resJson = JSON(response.result.value!)
                    success(resJson)
                }
            case .failure(let encodingError):
                let error : Error = encodingError
                failure(error)
                
            }
        })
    }
    
   
}
