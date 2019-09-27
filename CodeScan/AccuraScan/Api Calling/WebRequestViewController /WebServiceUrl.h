//
//  WebServiceUrl.h


#ifndef WebServiceUrl_h
#define WebServiceUrl_h
#define APPNAME @"AccuraScan"
#define hudMessage @"Loading..."
#define MainStoryBoard  [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:[NSBundle mainBundle]]

#define ContactUsTag 1
#define sendImgTag 2
#define FaceMapTag 3
#define FaceAuthTag 4
#define FaceEnrlTag 5
#define LivenessTag 6
#define SaveDataTag 7
#define DelEnrlTag 8
#define SingleEnrlTag 9
#define GetDataTag 10


#define WS_BaseUrl        @"https://accurascan.com/v2/api" // base url live
#define WS_SendEmail        @"https://accurascan.com/sendEmailApi/sendEmail.php" // base url live

#define PLACEHOLDER [UIColor whiteColor]

#define WS_ContactUs             @"https://accurascan.com/api/contactus"
#define WS_SaveDataAPI             @"https://accurascan.com/dev_v1/api/savecardrecdata"
#define WS_GetDataAPI             @"https://accurascan.com/dev_v1/api/getlastcardrecdata"

//zoom api
#define WS_FaceEnrl              @"https://api.zoomauth.com/api/v1/biometrics/enrollment"
#define WS_FaceMap               @"https://api.zoomauth.com/api/v1/biometrics/facemap"
#define WS_FaceAuth              @"https://api.zoomauth.com/api/v1/biometrics/authenticate"
#define WS_liveness               @"https://api.zoomauth.com/api/v1/biometrics/liveness"



#endif /* WebServiceUrl_h */




