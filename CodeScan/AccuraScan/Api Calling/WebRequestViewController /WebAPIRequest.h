
#import <Foundation/Foundation.h>
#import "JSON.h"
#import "WebServiceUrl.h"
#import <UIKit/UIKit.h>


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


@interface WebAPIRequest : NSObject

+ (void)getBannerImages:(NSObject*)delegate
                        country_id:(NSString *)strCountryId;

# pragma mark - post methods -

+ (void)postConatctData:(NSObject *)delegate
                   name:(NSString *)strName
                  phone:(NSString *)strPhone
                  email:(NSString *)strEmail
            companyName:(NSString *)strCompanyName
                country:(NSString *)strCountry
                      q:(NSString *)strQ
                message:(NSString *)strMsg;

+ (void)postConatctData:(NSObject *)delegate
                   userID:(NSString *)strUserID
                  contryID:(NSString *)strContryID;
+ (void)CountryList:(NSObject*)delegate;
+ (void)screenView:(NSString *)screenName;
+ (void)sendImage:(NSObject *)delegate
              img:(UIImage *)img
           isFrom:(NSString *)isFrom;
+ (void)sendMultiImage:(NSObject *)delegate
                   img:(UIImage *)img
                  img2:(UIImage *)img2
             facematch:(NSString*)facematch
              liveness:(NSString*)liveness
           mailSubject:(NSString*)mailSubject
              mailBody:(NSString*)mailBody;


@end
