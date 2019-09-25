//
//  WebServiceUrl.h
//  Passport
//
//  Created by akshay on 3/14/17.
//  Copyright © 2017 Alexander Shishkov & Kirill Kornyakov. All rights reserved.
//

#ifndef WebServiceUrl_h
#define WebServiceUrl_h
#define APPNAME @"AccuraScan"
#define hudMessage @"Loading..."
#define MainStoryBoard  [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:[NSBundle mainBundle]]


//#define WS_BaseUrl        @"https://api.accurascan.com/api/"
//#define WS_BaseUrl        @"https://accurascan.com/dev_v1/apiV1" // base url
//#define WS_BaseUrl        @"https://api.accurascan.com/v2/api" // base url live
#define WS_BaseUrl        @"https://accurascan.com/v2/api" // base url live
#define WS_SendEmail        @"https://accurascan.com/sendEmailApi/sendEmail.php" // base url live

#define PLACEHOLDER [UIColor whiteColor]

#define WS_ContactUs             @"https://accurascan.com/api/contactus"
#define WS_SaveDataAPI             @"https://accurascan.com/dev_v1/api/savecardrecdata"
#define WS_GetDataAPI             @"https://accurascan.com/dev_v1/api/getlastcardrecdata"

// accura api for zoom

//#define WS_FaceEnrl              @"https://accurascan.com/dev_v1/biometrics/enrollment"
//#define WS_FaceMap               @"https://accurascan.com/dev_v1/biometrics/facemap"
//#define WS_FaceAuth              @"https://accurascan.com/dev_v1/biometrics/authenticate"
//#define WS_liveness               @"https://accurascan.com/dev_v1/biometrics/liveness"


//zoom api
#define WS_FaceEnrl              @"https://api.zoomauth.com/api/v1/biometrics/enrollment"
#define WS_FaceMap               @"https://api.zoomauth.com/api/v1/biometrics/facemap"
#define WS_FaceAuth              @"https://api.zoomauth.com/api/v1/biometrics/authenticate"
#define WS_liveness               @"https://api.zoomauth.com/api/v1/biometrics/liveness"



#endif /* WebServiceUrl_h */




