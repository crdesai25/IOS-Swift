//
//  CardResultViewController.h
//  AccuraSDK
//
//  *********************** file use to display result after send image of pan card and aadhar card to server ****************

#import <UIKit/UIKit.h>
@protocol senddataProtocol <NSObject>

-(void)sendDataToA:(BOOL)dissmiss; //I am thinking my data is NSArray, you can use another object for store your information.

@end
@interface CardResultViewController : UIViewController
{
    __weak IBOutlet UIImageView *docImg;
    __weak IBOutlet UIImageView *imgPhoto;
    __weak IBOutlet UITableView *tlbRes;
    
    __weak IBOutlet NSLayoutConstraint *view_heg;
    __weak IBOutlet NSLayoutConstraint *cons_height;
}
@property(nonatomic,assign)id delegate;
@property (strong,atomic) NSDictionary *dict;
@property (weak, nonatomic) NSString *isFrom;
@property (weak, nonatomic) UIImage *docImgPass;

- (IBAction)cancelAction:(id)sender;
- (IBAction)saveAction:(id)sender;

@end
