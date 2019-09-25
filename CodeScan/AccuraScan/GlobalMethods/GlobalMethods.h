//
//  GlobalMethods.h
//
//
// ****************************** file use for display alert and declare method which use globally ******************************

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface GlobalMethods : NSObject


//+(void) showLoadingViewOnView:(UIView*)view;
//+(void) showLoadingViewOnView:(UIView*)view :(NSString *)text;
+(BOOL) IsValidEmail:(NSString *)checkString;
+ (NSString *) getNotNullString:(NSString *) aString ;

+(NSString *)dateStringFromDate:(NSDate *)selectedDate;
-(NSDate *)dateFromDateString:(NSString *)dateString;
-(NSString *)dateStringFromTime:(NSDate *)selectedDate;
-(NSString *)dateStringFromTime24:(NSDate *)selectedDate;
 //+(void)showAlertViewToView :(UIViewController *)VC  andTitle:(NSString *)title andMessage:(NSString *)message ;
//+(void)showTopAlertViewToView :(UIViewController *)VC  andTitle:(NSString *)title andMessage:(NSString *)message ;
+(void)showAlertView:(NSString *)text withViewController:(UIViewController *)view;
+ (NSString*)encodeStringTo64:(NSString*)fromString ;
+ (NSString *)encodeToBase64String:(UIImage *)image ;
+(NSString *)getJsonFromArray :(NSArray *)arrValue ;

// Push View Controller Methods
//+(void)pushViewcontrollerInRegistrationStoriboardTo: (UIViewController *)viewcontroller andIndentifier :(NSString *)VCidentfier ;
+(void)pushViewcontrollerInSearchStoriboardTo: (UIViewController *)viewcontroller andIndentifier :(NSString *)VCidentfier wintNavigation :(UINavigationController *)navigationController;
+(void)pushViewcontrollerMessageStoriboardTo: (UIViewController *)viewcontroller andIndentifier :(NSString *)VCidentfier wintNavigation :(UINavigationController *)navigationController;
+(void)pushViewcontrollerProfileStoriboardTo: (UIViewController *)viewcontroller andIndentifier :(NSString *)VCidentfier wintNavigation :(UINavigationController *)navigationController;
+(void)pushViewcontrollerMainStoriboardTo: (UIViewController *)viewcontroller andIndentifier :(NSString *)VCidentfier wintNavigation :(UINavigationController *)navigationController;
+(void)showAlertView:(NSString *)text withNextviewController:(UIViewController *)nextviewcontroller withviewController:(UIViewController *)viewcontroller wintNavigation :(UINavigationController *)navigationController;
+(void)showAlertViewWithAction:(NSString *)text withTitle:(NSString *)title withViewController:(UIViewController *)view;

// CRToast Method
+ (NSString *)extractNumberFromText:(NSString *)text ;
+(NSArray *)getArrayFromString :(NSString *)jsonString ;
+(UIImage *)fixOrientationForImage:(UIImage*)neededImage ;

@end
