/*****************************************************************************
 *   ViewController.m
 ******************************************************************************/


#import "zinterface.h"
#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "WebServiceUrl.h"
#import <AVFoundation/AVFoundation.h>
#import <MessageUI/MessageUI.h>
#include <opencv2/imgproc/imgproc.hpp>
#import "GlobalMethods.h"


@interface ViewController ()<UIActionSheetDelegate,MFMailComposeViewControllerDelegate>
{
    BOOL isPdf;
    NSMutableArray *dataArr,*scanInfoArray;

}
@end

@implementation ViewController

@synthesize _imageView,_videoCamera,_viewLayer, _constant_heigtt, _constant_width , _constant_Headerheigtt;

NSLock *lock = [[NSLock alloc]init];
int retval = 0;
int retface = 0;
int reccnt = 0;

NSString* lines = @"";
NSString* mrzLines = @"";

bool success;
NSString* passportType = @"";
NSString* country = @"";
NSString* surName = @"";
NSString* otherID = @"";

NSString* givenNames = @"";
NSString* passportNumber = @"";
NSString* passportNumberChecksum = @"";
NSString* nationality = @"";
NSString* birth = @"";
NSString* BirthChecksum = @"";
NSString* sex = @"";
NSString* expirationDate = @"";
NSString* expirationDateChecksum = @"";
NSString* personalNumber = @"";
NSString* personalNumberChecksum = @"";
NSString* secondRowChecksum = @"";
NSString* placeOfBirth = @"";
NSString* docSum = @"";
NSString* placeOfIssue = @"";
UIImage* photoImage = nil;
UIImage* documentImage = nil; //mrz document image
UIImage* docfrontImage = nil; //front document image

CGFloat viewScanningLayerWidth = 0.0;
CGFloat viewScanningLayerHeight = 0.0;
CGFloat scanningImgeHeightMultipler =  0.0;
CGFloat scanningImgeWidthMultipler = 0.0;
CGFloat navigationHeight = 0.0;
CGFloat scanningOriginX = 0.0;
NSString* fontImageRotation = @"";
NSString* BackImageRotation = @"";

bool threadrunning = NO;

typedef enum{
    REC_INIT = 1001,
    REC_BOTH,
    REC_FACE,
    REC_MRZ
}RecType;

RecType recType = REC_INIT;
bool bRecDone = false;
bool bFaceReplace = false;
bool bMrzFirst = false;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self ChangedOrintation];
    [[NSNotificationCenter defaultCenter]addObserver:self selector: @selector(buttonClicked:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    CGFloat with = [UIScreen mainScreen].bounds.size.width;
    CGFloat hite = [UIScreen mainScreen].bounds.size.height;
    with = with * 0.95;
    hite = hite * 0.35;
    _constant_heigtt.constant = hite;
    _constant_width.constant = with;
    
    
    //Check camera Permission
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    _viewLayer.layer.borderColor = [UIColor redColor].CGColor;
    _viewLayer.layer.borderWidth = 3.0f;
    
    [self._imgFlipView setHidden:true];
    
    if(status == AVAuthorizationStatusAuthorized) {
        self._videoCamera = [[CvVideoCamera alloc] init];
        self._videoCamera.delegate = self;
        self._videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
        self._videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset1280x720;
        self._videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
        self._videoCamera.defaultFPS = 30;
        self._videoCamera.grayscaleMode = NO;
        self._videoCamera.rotateVideo = NO;
        if(loadDiction() == 0)
        {
            NSLog(@"Load Dic Failed");
        }
        if (threadrunning == NO)
            
            [NSThread detachNewThreadSelector:@selector(Recog_Thread) toTarget:self withObject:nil];
        
        UITapGestureRecognizer *shortTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapToFocus:)];
        shortTap.numberOfTapsRequired=1;
        shortTap.numberOfTouchesRequired=1;
        [self.view addGestureRecognizer:shortTap];
        
        
        // authorized
    } else if(status == AVAuthorizationStatusDenied){
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:APPNAME
                                     message:@"It looks like your privacy settings are preventing us from accessing your camera."
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        //Add Buttons
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Ok"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        UIApplication *application = [UIApplication sharedApplication];
                                        [application openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
                                        
                                    }];
        
        
        [alert addAction:yesButton];
        
        [self presentViewController:alert animated:YES completion:nil];
        // denied
    } else if(status == AVAuthorizationStatusRestricted){
        // restricted
    } else if(status == AVAuthorizationStatusNotDetermined){
        // not determined
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted){
                NSLog(@"Granted access");
         
                //Set Scaning camera view
                self._videoCamera = [[CvVideoCamera alloc] init];
                self._videoCamera.delegate = self;
                self._videoCamera.defaultAVCaptureDevicePosition =
                AVCaptureDevicePositionBack; //Camera position
                self._videoCamera.defaultAVCaptureSessionPreset =
                AVCaptureSessionPreset1280x720; //Camera view size
                self._videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait; //Camera orientation
                self._videoCamera.defaultFPS = 30;
                self._videoCamera.grayscaleMode = NO;
                self._videoCamera.rotateVideo = NO;
                if(loadDiction() == 0)
                {
                    NSLog(@"Load Dic Failed");
                }
                if (threadrunning == NO)
                    
                      [NSThread detachNewThreadSelector:@selector(Recog_Thread) toTarget:self withObject:nil];
                
                UITapGestureRecognizer *shortTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapToFocus:)];
                shortTap.numberOfTapsRequired=1;
                shortTap.numberOfTouchesRequired=1;
                [self.view addGestureRecognizer:shortTap];
                [self->_videoCamera start];
                self->_isCapturing = YES;
                
                
            } else {
                NSLog(@"Not granted access");
            }
        }];
    }
}

/*
 This method use scanning frame
 Device orientation acoding set scanning view frame
 */

-(void)ChangedOrintation {

    if ( ([[UIDevice currentDevice] orientation] ==  UIDeviceOrientationLandscapeLeft)  )
        //device orientation
    {
        //do something or rather
        [self
         shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
        NSLog(@"landscape left");
        
        CGFloat hite = [UIScreen mainScreen].bounds.size.width;
        hite = hite * 0.85;
        
        CGFloat with = [UIScreen mainScreen].bounds.size.height;
        with = with * 0.75;
        scanningImgeHeightMultipler = 0.75;
        scanningImgeWidthMultipler = 0.75;
        navigationHeight = 0.0;
        scanningOriginX = 150.0;
        _constant_width.constant = hite;
        _constant_heigtt.constant = with;
        
        viewScanningLayerWidth = with;
        viewScanningLayerHeight = hite;
        
    }
    if ( ([[UIDevice currentDevice] orientation] ==  UIDeviceOrientationLandscapeRight)  )
    {        //do something or rather
        [self
         shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight];
        NSLog(@"landscape right");
        
        CGFloat hite = [UIScreen mainScreen].bounds.size.width;
        hite = hite * 0.85;
        
        CGFloat with = [UIScreen mainScreen].bounds.size.height;
        with = with * 0.75;
        
        scanningImgeHeightMultipler = 0.75;
        scanningImgeWidthMultipler = 0.75;
        navigationHeight = 0.0;
        scanningOriginX = 150.0;
        _constant_width.constant = hite;
        _constant_heigtt.constant = with;
        
        viewScanningLayerWidth = with;
        viewScanningLayerHeight = hite;
    }
    if ( ([[UIDevice currentDevice] orientation] ==  UIDeviceOrientationPortrait)  )
    {
        //do something or rather
        [self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait];
        NSLog(@"portrait");
        
        CGFloat with = [UIScreen mainScreen].bounds.size.width;
        CGFloat hite = [UIScreen mainScreen].bounds.size.height;
        with = with * 0.95;
        hite = hite * 0.35;
        navigationHeight = 80.0;
        scanningOriginX = 0;
        scanningImgeHeightMultipler = 0.35;
        scanningImgeWidthMultipler = 0.95;
        
        _constant_heigtt.constant = hite;
        _constant_width.constant = with;
        viewScanningLayerWidth = with;
        viewScanningLayerHeight = hite;
        
    }
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseIn  animations:^{
        //code with animation
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        //code for completion
    }];
}

-(void) buttonClicked:(UIButton*)sender {
    [self ChangedOrintation]; //Set Scanning Orintation
}

- (void) viewWillAppear:(BOOL)animated
{
    [_videoCamera start]; //Start Scanning
    _isCapturing = YES;
}
- (void) viewWillDisappear:(BOOL)animated
{
    
    [_videoCamera stop]; //Stop Scanning
    _imageView.image = nil;
    _isCapturing = NO;
    _matOrg.release();
    threadrunning = NO;
    
    
}
/*
 Call to Opencv framework method
 Parameters to Pass: scanning image CV::Mat metrix
 This method will return UIImage
 */

UIImage* uiimageFromCVMat(cv::Mat &cvMat)
{
    //Check input cv::mat empty or not
    @autoreleasepool {
        if (cvMat.empty()) {
            return nil;
        }
        CGColorSpaceRef colorSpace;
        
        if (cvMat.elemSize() == 1) {
            colorSpace = CGColorSpaceCreateDeviceGray();
        } else {
            colorSpace = CGColorSpaceCreateDeviceRGB();
        }
        cv::Mat mat1 = cvMat.clone();
        if (cvMat.elemSize() == 4) {
            cv::cvtColor(mat1, mat1, CV_BGRA2RGBA);
        }
        NSData *data = [NSData dataWithBytes:mat1.data length:mat1.elemSize() * mat1.total()];
        
        CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
        
        CGImageRef imageRef = CGImageCreate(mat1.cols, // Width
                                            mat1.rows, // Height
                                            8, // Bits per component
                                            8 * mat1.elemSize(), // Bits per pixel
                                            mat1.step[0], // Bytes per row
                                            colorSpace, // Colorspace
                                            kCGImageAlphaNone | kCGBitmapByteOrderDefault, // Bitmap info flags
                                            provider, // CGDataProviderRef
                                            NULL, // Decode
                                            false, // Should interpolate
                                            kCGRenderingIntentDefault); // Intent
        
        UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
        CGImageRelease(imageRef);
        CGDataProviderRelease(provider);
        CGColorSpaceRelease(colorSpace);
        mat1.release();
        return image;
        
    }
}

/*
 Call to Opencv framework method
 Parameters to Pass: scanning image
 
 This method will return CV::Mat metrix
 
 */
cv::Mat cvMatFromUIImage(UIImage* image)
{
    if (image == nil) {
        return cv::Mat::zeros(10, 10, CV_8UC4);
    }
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    cv::cvtColor(cvMat, cvMat, CV_RGBA2BGRA);
    return cvMat;
}
- (void)handleTapToFocus:(UITapGestureRecognizer *)tapGesture
{
    AVCaptureDevice *acd=[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (tapGesture.state == UIGestureRecognizerStateEnded)
    {
        CGPoint thisFocusPoint = [tapGesture locationInView:self.view];
        double focus_x = thisFocusPoint.x/self.view.frame.size.width;
        double focus_y = thisFocusPoint.y/self.view.frame.size.height;
        if ([acd isFocusModeSupported:AVCaptureFocusModeAutoFocus] && [acd isFocusPointOfInterestSupported])
        {
            if ([acd lockForConfiguration:nil])
            {
                [acd setFocusMode:AVCaptureFocusModeAutoFocus];
                [acd setFocusPointOfInterest:CGPointMake(focus_x, focus_y)];
                [acd unlockForConfiguration];
            }
        }
    }
}

/*
 Delegate method for processing image frames
 Parameters to Pass: scanning cv::Mat metrix
 */

- (void)processImage:(cv::Mat&)image //This function is called per every frame
{
    [lock lock];
    _matOrg.release();
    //crop
    
    UIImage *img = uiimageFromCVMat(image);
    CGPoint point = CGPointMake((([[UIScreen mainScreen] bounds].size.width / 2 ) - (viewScanningLayerWidth / 2 )), (([[UIScreen mainScreen] bounds].size.height / 2 ) - (viewScanningLayerHeight / 2 )));
    
    CGFloat hite =  0.0;
    CGFloat width = 0.0;
    width = img.size.width * scanningImgeWidthMultipler;
    hite = img.size.height * scanningImgeHeightMultipler;
    
    double fullWidth = img.size.width;
    double withImg = fullWidth * scanningImgeWidthMultipler;
    
    double originX = fullWidth - withImg;
    
    // Setup a rectangle to define your region of interest
    cv::Rect myROI(originX, point.y + navigationHeight, width, hite);
    // Crop the full image to that image contained by the rectangle myROI
    cv::Mat croppedImage = image(myROI);
    
    _matOrg = croppedImage.clone();
    [lock unlock];
    [self performSelectorOnMainThread:@selector(ShowImg) withObject:nil waitUntilDone:NO];
}
- (void) ShowImg
{
    [lock lock];
    if (_matOrg.empty()) {
        [lock unlock];
        return;
    }
    cv::Mat matShow;
    _matOrg.copyTo(matShow);
    [lock unlock];
    [_imageView setImage:nil];
    [_imageView setImage:uiimageFromCVMat(matShow)];
    matShow.release();
}

NSString *previouslines = @"";

- (void) Recog_Thread
{
    threadrunning = YES;
    
    while (true) {
        [NSThread sleepForTimeInterval:0.01];
        if (_isCapturing == NO) {
            continue;
        }
        [lock lock];
        if (_matOrg.empty()) {
            [lock unlock];
            continue;
        }
        CFTimeInterval tf = CACurrentMediaTime();
        cv::Mat splits[4];
        cv::split(_matOrg, splits);
        
        int w = _matOrg.cols;
        int h = _matOrg.rows;
        [lock unlock];
        NSLog(@"%d,%d",w,h);
        char chsurname[100],chgivenname[100];
        char chlines[100];
        char chtype[100];
        char chcountry[100];
        char chpassportnumber[100],chpassportchecksum[100];
        char chnationality[100];
        char chbirth[100];char chbirthchecksum[100];
        char chsex[100];
        char chexpirationdate[100],chexpirationchecksum[100];
        char chpersonalnumber[100],chpersonalnumberchecksum[100];
        char chsecondrowchecksum[100];
        char chplaceofbirth[100];
        char chplaceofissue[100];
        
        unsigned char *photoChannels[3];
        photoChannels[0] = new unsigned char[400*400];
        photoChannels[1] = new unsigned char[400*400];
        photoChannels[2] = new unsigned char[400*400];
        int phoW = 0, phoH = 0;
        
        bool bPickPhoto = YES;
        NSString* path = [[NSBundle mainBundle] pathForResource:@"key" ofType:@"license"];
        if ([path isEqualToString:@""] || path == nil)
        {
            [GlobalMethods showAlertView:@"key not found" withViewController:self];
            break;
        }
        
        // check the rectype
        if (recType == REC_INIT){
            retval = doRecogGrayImg_Passport(splits[2].data, splits[1].data, splits[0].data, w, h, chlines, success, chtype, chcountry, chsurname, chgivenname, chpassportnumber, chpassportchecksum, chnationality, chbirth, chbirthchecksum,chsex, chexpirationdate, chexpirationchecksum, chpersonalnumber, chpersonalnumberchecksum, chsecondrowchecksum,chplaceofbirth,chplaceofissue, photoChannels[0], photoChannels[1], photoChannels[2],&phoW, &phoH, bPickPhoto,(char*)[path UTF8String]);
            
            if (success == false && reccnt > 2)
            {
                if (retface < 1)
                {
                    retface = doFaceDetect(splits[2].data, splits[1].data, splits[0].data, w, h, photoChannels[0], photoChannels[1], photoChannels[2], &phoW, &phoH);
                }
            }
            reccnt++;
        }
        else if (recType == REC_FACE) //have to detect mrz
        {
            retface = 0;
            retval = doRecogGrayImg_Passport(splits[2].data, splits[1].data, splits[0].data, w, h, chlines, success, chtype, chcountry, chsurname, chgivenname, chpassportnumber, chpassportchecksum, chnationality, chbirth, chbirthchecksum,chsex, chexpirationdate, chexpirationchecksum, chpersonalnumber, chpersonalnumberchecksum, chsecondrowchecksum,chplaceofbirth,chplaceofissue, photoChannels[0], photoChannels[1], photoChannels[2],&phoW, &phoH, bPickPhoto,(char*)[path UTF8String]);
        }
        else if (recType == REC_MRZ)
        {
            success = false;
            if (reccnt > 2)
                retface = doFaceDetect(splits[2].data, splits[1].data, splits[0].data, w, h, photoChannels[0], photoChannels[1], photoChannels[2], &phoW, &phoH);
            
            reccnt++;
        }
        
        tf = CACurrentMediaTime() - tf;
        NSLog(@"recogend %f",tf);
        if(success == true)
        {
            lines = [NSString stringWithUTF8String:chlines];
            passportType = [NSString stringWithUTF8String:chtype];
            country = [NSString stringWithUTF8String:chcountry];
            surName = [NSString stringWithUTF8String:chsurname];
            givenNames = [NSString stringWithUTF8String:chgivenname];
            passportNumber = [NSString stringWithUTF8String:chpassportnumber];
            passportNumberChecksum = [NSString stringWithUTF8String:chpassportchecksum];
            nationality = [NSString stringWithUTF8String:chnationality];
            birth = [NSString stringWithUTF8String:chbirth];
            BirthChecksum = [NSString stringWithUTF8String:chbirthchecksum];
            sex = [NSString stringWithUTF8String:chsex];
            expirationDate = [NSString stringWithUTF8String:chexpirationdate];
            expirationDateChecksum = [NSString stringWithUTF8String:chexpirationchecksum];
            personalNumber = [NSString stringWithUTF8String:chpersonalnumber];
            personalNumberChecksum = [NSString stringWithUTF8String:chpersonalnumberchecksum];
            secondRowChecksum = [NSString stringWithUTF8String:chsecondrowchecksum];
            placeOfBirth = [NSString stringWithUTF8String:chplaceofbirth];
            placeOfIssue = [NSString stringWithUTF8String:chplaceofissue];
            cv::Mat colormat;
            cv::Mat faceCh[3];
            faceCh[0] = cv::Mat(phoH,phoW,CV_8UC1);
            faceCh[1] = cv::Mat(phoH,phoW,CV_8UC1);
            faceCh[2] = cv::Mat(phoH,phoW,CV_8UC1);
            memcpy(faceCh[0].data, photoChannels[0], sizeof(uchar)*phoH*phoW);
            memcpy(faceCh[1].data, photoChannels[1], sizeof(uchar)*phoH*phoW);
            memcpy(faceCh[2].data, photoChannels[2], sizeof(uchar)*phoH*phoW);
            
            cv::merge(faceCh, 3, colormat);
            
            if(bPickPhoto == true && phoH*phoW > 0)
            {
                photoImage = uiimageFromCVMat(colormat);
                if (recType == REC_FACE)
                    bFaceReplace = true;
                else if (recType == REC_INIT)
                    bMrzFirst = true;
                
                recType = REC_MRZ;
                bRecDone = true;
            }
            
            reccnt = 0;
            if (phoW*phoH == 0) //face detected failed
            {
                //photoImage = nil;
                if (recType == REC_FACE)
                {
                    recType = REC_MRZ;
                    bRecDone = true;
                }
                else if (recType == REC_INIT)
                    recType = REC_MRZ;
            }
            
            faceCh[0].release();
            faceCh[1].release();
            faceCh[2].release();
            
            colormat.release();
            [self performSelectorOnMainThread:@selector(Recog_Successed) withObject:nil waitUntilDone:YES];
        }
        
        //face detection success
        if (success == false && retface > 0)
        {
            cv::Mat colormat;
            cv::Mat faceCh[3];
            faceCh[0] = cv::Mat(phoH,phoW,CV_8UC1);
            faceCh[1] = cv::Mat(phoH,phoW,CV_8UC1);
            faceCh[2] = cv::Mat(phoH,phoW,CV_8UC1);
            memcpy(faceCh[0].data, photoChannels[0], sizeof(uchar)*phoH*phoW);
            memcpy(faceCh[1].data, photoChannels[1], sizeof(uchar)*phoH*phoW);
            memcpy(faceCh[2].data, photoChannels[2], sizeof(uchar)*phoH*phoW);
            
            cv::merge(faceCh, 3, colormat);
            photoImage = uiimageFromCVMat(colormat);
            colormat.release();
            
            faceCh[0].release();
            faceCh[1].release();
            faceCh[2].release();
            
            reccnt = 0;
            // check the rectype
            if (recType == REC_INIT)
                recType = REC_FACE;
            else if (recType == REC_MRZ)
            {
                recType = REC_FACE;
                bRecDone = true;
            }
            
            [self performSelectorOnMainThread:@selector(Recog_Successed) withObject:nil waitUntilDone:YES];
        }
        
        //remove splites
        splits[0].release();
        splits[1].release();
        splits[2].release();
        
        delete[] photoChannels[0];
        delete[] photoChannels[1];
        delete[] photoChannels[2];
        
    }
    threadrunning = NO;
}


- (void) flipAnimation //This function is called onr slide scan complete
{
    [self._imgFlipView setHidden:false];
    [UIView animateWithDuration:1.5 animations:^{
        
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self._imgFlipView cache:YES];
        AudioServicesPlaySystemSound (1315);
    } completion:^(BOOL finished) {
        [self._imgFlipView setHidden:true];
    }];
}
/*
 * This method call document scan success
*/
- (void) Recog_Successed
{
    NSLog(@"Recog successed");
    //check the rectype
    if (recType == REC_FACE)
    {
        docfrontImage = _imageView.image;
        [self imageRotation:@"FontImg"];
        if (!bRecDone)
        {
            [self._lblTitle setText:@"Scan Back Side of Document"];
            [self flipAnimation];
            return;
        }
    }
    else if (recType == REC_MRZ)
    {
        documentImage = _imageView.image;
        [self imageRotation: @"BackImg"];
        if (bFaceReplace || bMrzFirst)
        {
            docfrontImage = _imageView.image;
            documentImage = nil;
            [self imageRotation:@"FontOnlyImg"];
        }
        
        if (!bRecDone)
        {
            [self._lblTitle setText:@"Scan Front Side of Document"];
            [self flipAnimation];
            return;
        }
    }
    
    //REC_BOTH
    reccnt = 0;
    retface = 0;
    bFaceReplace = false;
    bRecDone = false;
    recType = REC_INIT;
    success = false;
    bMrzFirst = false;
    
    [self._lblTitle setText:@"Scan Front/Back Side of Document"];
    
    [_videoCamera stop];
    _imageView.image = nil;
    _isCapturing = NO;
    _matOrg.release();
    AudioServicesPlaySystemSound (1315);
    [self performSegueWithIdentifier:@"segue_ShowResult" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    //segue method
    if ([[segue identifier] isEqualToString:@"segue_ShowResult"])
    {
        //Scanning data store NSMutableDictionary
        NSMutableDictionary *shareScanningListing = [[NSMutableDictionary alloc]init];
        [shareScanningListing setValue: lines forKey: @"lines"];
        [shareScanningListing setValue: passportType forKey: @"passportType"];
        [shareScanningListing setValue: country forKey: @"country"];
        [shareScanningListing setValue: surName forKey: @"surName"];
        [shareScanningListing setValue: givenNames forKey: @"givenNames"];
        [shareScanningListing setValue: passportNumber forKey: @"passportNumber"];
        [shareScanningListing setValue: passportNumberChecksum forKey: @"passportNumberChecksum"];
        [shareScanningListing setValue: nationality forKey: @"nationality"];
        [shareScanningListing setValue: birth forKey: @"birth"];
        [shareScanningListing setValue: BirthChecksum forKey: @"BirthChecksum"];
        [shareScanningListing setValue: sex forKey: @"sex"];
        [shareScanningListing setValue: expirationDate forKey: @"expirationDate"];
        [shareScanningListing setValue: expirationDateChecksum forKey: @"expirationDateChecksum"];
        [shareScanningListing setValue: personalNumber forKey: @"personalNumber"];
        [shareScanningListing setValue: personalNumberChecksum forKey: @"personalNumberChecksum"];
        [shareScanningListing setValue: secondRowChecksum forKey: @"secondRowChecksum"];
        [shareScanningListing setValue: placeOfBirth forKey: @"placeOfBirth"];
        [shareScanningListing setValue: [NSString stringWithFormat:@"%d",retval] forKey: @"retval"];
        [shareScanningListing setValue: placeOfIssue forKey: @"placeOfIssue"];
        [shareScanningListing setValue: UIImagePNGRepresentation(photoImage) forKey: @"photoImage"];
        [shareScanningListing setValue: UIImagePNGRepresentation(documentImage) forKey: @"documentImage"];
        [shareScanningListing setValue: UIImagePNGRepresentation(docfrontImage) forKey: @"docfrontImage"];
        [shareScanningListing setValue: fontImageRotation forKey: @"fontImageRotation"];
        [shareScanningListing setValue: BackImageRotation forKey: @"backImageRotation"];
        
        //Scanning Data Store in UserDefaults
        [[NSUserDefaults standardUserDefaults] setObject:shareScanningListing forKey:@"ScanningData"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (_isCapturing)
    {
        [_videoCamera stop]; //Stop Scanning
        _isCapturing = NO;
    }
}
- (void)dealloc
{
    _videoCamera.delegate = nil;
}
#pragma unwind segues

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue
{
    
}

- (IBAction)menuAction:(id)sender
{
  
    if (_isCapturing)
    {
        reccnt = 0;
        retface = 0;
        bFaceReplace = false;
        bRecDone = false;
        recType = REC_INIT;
        success = false;
        bMrzFirst = false;
        [_videoCamera stop];
        _imageView.image = nil;
        _isCapturing = NO;
        _matOrg.release();
    }
    [self performSelector:@selector(backToViewController) withObject:nil afterDelay:1.0];;
}

-(void)backToViewController
{
    if (_isCapturing)
    {
        [_videoCamera stop]; //Stop Scanning
        _isCapturing = NO;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backAction:(id)sender
{
    if (_isCapturing)
    {
        reccnt = 0;
        retface = 0;
        bFaceReplace = false;
        bRecDone = false;
        recType = REC_INIT;
        success = false;
        bMrzFirst = false;
        [_videoCamera stop]; //Stop Scanning
        _isCapturing = NO;
        _imageView.image = nil;
        _matOrg.release();
        
    }
    [self.navigationController popViewControllerAnimated:YES];
}

/*
 This method in identified image orientation
 */
- (void)imageRotation:(NSString* )imageRotation
{
    NSString *strRotation = @"";
    if ( ([[UIDevice currentDevice] orientation] ==  UIDeviceOrientationLandscapeRight)  ) {
        strRotation = @"Right";
    }else if ( ([[UIDevice currentDevice] orientation] ==  UIDeviceOrientationLandscapeLeft)  ) {
        strRotation = @"Left";
    }
    if ([imageRotation  isEqual: @"FontImg"]){//@"FontImg"
        fontImageRotation = strRotation;
    }else if ([imageRotation  isEqual: @"BackImg"]){// @"BackImg"
        BackImageRotation = strRotation;
    }
    else{//@"FontOnlyImg"
        fontImageRotation = strRotation;
    }
}

@end
