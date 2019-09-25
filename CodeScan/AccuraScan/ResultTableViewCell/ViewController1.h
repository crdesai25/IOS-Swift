/*****************************************************************************
 *   ViewController.h
 ******************************************************************************
 *   by Kirill Kornyakov and Alexander Shishkov, 13th May 2013
 ******************************************************************************
 *   Chapter 10 of the "OpenCV for iOS" book
 *
 *   Capturing Video from Camera shows how to capture video
 *   stream from camera.
 *
 *   Copyright Packt Publishing 2013.
 *   http://bit.ly/OpenCV_for_iOS_book
 *****************************************************************************/

#import <UIKit/UIKit.h>
//#import "opencv2/highgui/ios.h" -- for opencv 2.4.10
#import "opencv2/imgcodecs/ios.h"
#import "opencv2/videoio/cap_ios.h"
#include "zinterface.h"
#import "NDHTMLtoPDF.h"


@interface ViewController : UIViewController<CvVideoCameraDelegate>

{
    CvVideoCamera* _videoCamera;
    BOOL _isCapturing;
    cv::Mat _matOrg;
    UIImageView* _imageView;
}
@property (nonatomic, strong) NDHTMLtoPDF *PDFCreator;
@property (nonatomic, strong) IBOutlet UIView* _viewLayer;
@property (nonatomic, strong) CvVideoCamera* _videoCamera;
@property (nonatomic, strong) IBOutlet UIImageView* _imgPicView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint* _constant_heigtt;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint* _constant_width;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint* _constant_Headerheigtt;
@property (nonatomic, strong) IBOutlet UIImageView *_imgFlipView;
@property (nonatomic, strong) IBOutlet UILabel *_lblTitle;

@property (nonatomic, strong) IBOutlet UIImageView* _imageView;
@property (weak, nonatomic) IBOutlet UISwitch *switchPickPhoto;
-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue;
- (IBAction)exportDataAction:(id)sender;
- (IBAction)menuAction:(id)sender;

@end
