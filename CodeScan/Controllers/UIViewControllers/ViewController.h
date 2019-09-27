/*****************************************************************************
 *   ViewController.h
 ******************************************************************************/


#import <UIKit/UIKit.h>
#import "opencv2/highgui/ios.h"
#include "zinterface.h"


@interface ViewController : UIViewController<CvVideoCameraDelegate>

{
    CvVideoCamera* _videoCamera;
    BOOL _isCapturing;
    cv::Mat _matOrg;
    UIImageView* _imageView;
}

@property (nonatomic, strong) IBOutlet UIView* _viewLayer;
@property (nonatomic, strong) CvVideoCamera* _videoCamera;
@property (nonatomic, strong) IBOutlet UIImageView* _imageView;
@property (nonatomic, strong) IBOutlet UIImageView* _imgPicView;
@property (nonatomic, strong) IBOutlet UIImageView *_imgFlipView;
//@property (nonatomic, strong) IBOutlet UILabel* _lblInfoText;
@property (nonatomic, strong) IBOutlet UILabel *_lblTitle;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint* _constant_heigtt;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint* _constant_width;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint* _constant_Headerheigtt;

extern NSMutableDictionary *shareScanningListing;

@property (weak, nonatomic) IBOutlet UISwitch *switchPickPhoto;
-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue;
- (IBAction)menuAction:(id)sender;

@end
