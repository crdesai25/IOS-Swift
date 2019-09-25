/*****************************************************************************
 *   ViewController.m
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

#import "zinterface.h"
#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "ModelManager.h"
#import "WebServiceUrl.h"
#import <AVFoundation/AVFoundation.h>
#import <MessageUI/MessageUI.h>
#import "NDHTMLtoPDF.h"
#import "MenuViewController.h"
#include "LibXL/libxl.h"
#import "WebAPIRequest.h"
#include <opencv2/imgproc/imgproc.hpp>
#import "PlaceHolderViewController.h"
#import "GlobalMethods.h"
#import "ViewControllerShowResult.h"

@interface ViewController ()<UIActionSheetDelegate,NDHTMLtoPDFDelegate,MFMailComposeViewControllerDelegate>
{
    BOOL isPdf;
    NSMutableArray *dataArr,*scanInfoArray;
   ModelManager *mgrObj;


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
NSString* birthChecksum = @"";
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
//   [_videoCamera start];
//    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    [self ChangedOrintation];
    [[NSNotificationCenter defaultCenter]addObserver:self selector: @selector(buttonClicked:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    CGFloat with = [UIScreen mainScreen].bounds.size.width;
    CGFloat hite = [UIScreen mainScreen].bounds.size.height;
    with = with * 0.95;
    hite = hite * 0.35;
    _constant_heigtt.constant = hite;
    _constant_width.constant = with;
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    _viewLayer.layer.borderColor = [UIColor redColor].CGColor;
    _viewLayer.layer.borderWidth = 3.0f;

    [self._imgFlipView setHidden:true];
    
    if(status == AVAuthorizationStatusAuthorized) {
        self->mgrObj=[ModelManager getInstance];
        
        self._videoCamera = [[CvVideoCamera alloc] init];
        self._videoCamera.delegate = self;
        self._videoCamera.defaultAVCaptureDevicePosition =
        AVCaptureDevicePositionBack;
        self._videoCamera.defaultAVCaptureSessionPreset =
        AVCaptureSessionPreset1280x720;
        self._videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
        //AVCaptureVideoOrientationLandscapeRight;
        //AVCaptureVideoOrientationPortrait;
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
//                                        BOOL canOpenSettings = (&UIApplicationOpenSettingsURLString != NULL);
//                                        if (canOpenSettings) {
                                            UIApplication *application = [UIApplication sharedApplication];
                                            [application openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];

//                                        }
                                        
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
                self->mgrObj=[ModelManager getInstance];
                
                self._videoCamera = [[CvVideoCamera alloc] init];
                self._videoCamera.delegate = self;
                self._videoCamera.defaultAVCaptureDevicePosition =
                AVCaptureDevicePositionBack;
                self._videoCamera.defaultAVCaptureSessionPreset =
                AVCaptureSessionPreset1280x720;
                self._videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
                //AVCaptureVideoOrientationLandscapeRight;
                //AVCaptureVideoOrientationPortrait;
                self._videoCamera.defaultFPS = 30;
                self._videoCamera.grayscaleMode = NO;
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
//                self._videoCamera = [[CvVideoCamera alloc] init];
//                self._videoCamera.delegate = self;
//                self._videoCamera.defaultAVCaptureDevicePosition =
//                AVCaptureDevicePositionBack;
//                self._videoCamera.defaultAVCaptureSessionPreset =
//                AVCaptureSessionPreset1280x720;
//                self._videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
////                //AVCaptureVideoOrientationLandscapeRight;
////                //AVCaptureVideoOrientationPortrait;
//                self._videoCamera.defaultFPS = 30;
//                self._videoCamera.grayscaleMode = NO;
//                [_videoCamera start];
//                _isCapturing = YES;
////                if(loadDiction() == 0)
////                {
////                    NSLog(@"Load Dic Failed");
////                }
//               if (threadrunning == NO)
//
//                    [NSThread detachNewThreadSelector:@selector(Recog_Thread) toTarget:self withObject:nil];
////
////                UITapGestureRecognizer *shortTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapToFocus:)];
////                shortTap.numberOfTapsRequired=1;
////                shortTap.numberOfTouchesRequired=1;
////                [self.view addGestureRecognizer:shortTap];
//                [_videoCamera start];
//                _isCapturing = YES;
                
            }
        }];
    }
    
    
   
    
}
-(void)ChangedOrintation {
    if ( ([[UIDevice currentDevice] orientation] ==  UIDeviceOrientationLandscapeLeft)  )
    {
        //do something or rather
        [self
         shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
        NSLog(@"landscape left");
        
        CGFloat hite = [UIScreen mainScreen].bounds.size.width;
        hite = hite * 0.85;
        
        CGFloat with = [UIScreen mainScreen].bounds.size.height;
        with = with * 0.75;
        _constant_width.constant = hite;
        _constant_heigtt.constant = with;
        
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
        _constant_width.constant = hite;
        _constant_heigtt.constant = with;
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
        
        _constant_heigtt.constant = hite;
        _constant_width.constant = with;
        
    }
    
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseIn  animations:^{
        //code with animation
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        //code for completion
    }];
}

-(void) buttonClicked:(UIButton*)sender {
    [self ChangedOrintation];
}

- (void) viewWillAppear:(BOOL)animated
{
    [_videoCamera start];
    _isCapturing = YES;
}
- (void) viewWillDisappear:(BOOL)animated
{
   
    [_videoCamera stop];
    _imageView.image = nil;
    _isCapturing = NO;
    _matOrg.release();
     threadrunning = NO;


}

//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskPortrait;
//}

UIImage* uiimageFromCVMat(cv::Mat &cvMat)
{
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
                /*
                 if ([acd isExposureModeSupported:AVCaptureExposureModeAutoExpose] && [acd isExposurePointOfInterestSupported])
                 {
                 [acd setExposureMode:AVCaptureExposureModeAutoExpose];
                 [acd setExposurePointOfInterest:CGPointMake(focus_x, focus_y)];
                 }*/
                [acd unlockForConfiguration];
            }
        }
    }
}
- (void)processImage:(cv::Mat&)image //This function is called per every frame
{
    [lock lock];
    _matOrg.release();
    _matOrg = image.clone();
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
//        UIImage* img11 = uiimageFromCVMat(_matOrg);
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

//        bool bPickPhoto = [self.switchPickPhoto isOn];
        
        bool bPickPhoto = YES;
        NSString* path = [[NSBundle mainBundle] pathForResource:@"key" ofType:@"license"];
        if ([path isEqualToString:@""] || path == nil)
        {
            [GlobalMethods showAlertView:@"key not found" withViewController:self];
            break;
        }
 
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
        //splits[0].release();
        //splits[1].release();
        //splits[2].release();
        if(success == true)
        {
            lines = [NSString stringWithUTF8String:chlines];
            //if ([lines isEqualToString:previouslines])
           // {
            passportType = [NSString stringWithUTF8String:chtype];
            country = [NSString stringWithUTF8String:chcountry];
            surName = [NSString stringWithUTF8String:chsurname];
            givenNames = [NSString stringWithUTF8String:chgivenname];
            passportNumber = [NSString stringWithUTF8String:chpassportnumber];
            passportNumberChecksum = [NSString stringWithUTF8String:chpassportchecksum];
            nationality = [NSString stringWithUTF8String:chnationality];
            birth = [NSString stringWithUTF8String:chbirth];
            birthChecksum = [NSString stringWithUTF8String:chbirthchecksum];
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


- (void) flipAnimation
{
    [self._imgFlipView setHidden:false];
    [UIView animateWithDuration:1.5 animations:^{
        
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self._imgFlipView cache:YES];
        AudioServicesPlaySystemSound (1315);
    } completion:^(BOOL finished) {
        [self._imgFlipView setHidden:true];
    }];
}

- (void) Recog_Successed
{
    NSLog(@"Recog successed");
    //check the rectype
    if (recType == REC_FACE)
    {
        docfrontImage = [self imageByCroppingImage:_imageView.image toSize:CGSizeMake(0, 0)];
        if (!bRecDone)
        {
            [self._lblTitle setText:@"Scan Back Side of Document"];
            [self flipAnimation];
            return;
        }
    }
    else if (recType == REC_MRZ)
    {
        documentImage = [self imageByCroppingImage:_imageView.image toSize:CGSizeMake(0, 0)];
        if (bFaceReplace || bMrzFirst)
        {
            docfrontImage = [self imageByCroppingImage:_imageView.image toSize:CGSizeMake(0, 0)];
            documentImage = nil;
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
//     documentImage = _imageView.image;
//    documentImage = [self imageByCroppingImage:_imageView.image toSize:CGSizeMake(0, 0)];
    _imageView.image = nil;
    _isCapturing = NO;
    _matOrg.release();
    //AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    AudioServicesPlaySystemSound (1315);
    [self performSegueWithIdentifier:@"segue_ShowResult" sender:self];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"segue_ShowResult"])
    {
        // Get reference to the destination view controller
        ViewControllerShowResult *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
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
        [_videoCamera stop];
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
    NSLog(@"I did an unwind segway! Holy crap!");
    
}
- (IBAction)exportDataAction:(id)sender
{
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select Sharing option:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            @"Export Excel Sheet",
                            @"Export PDF",
                            nil];
    popup.tag = 1;
    [popup showInView:self.view];
}

- (IBAction)menuAction:(id)sender
{
//    MenuViewController *control;
//    control =[[MenuViewController alloc]initWithNibName:@"MenuViewController" bundle:nil];
//    control.view.frame = CGRectMake(-self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
//
//    [self.view addSubview:control.view];
//
//    [control didMoveToParentViewController:self];
//    [self addChildViewController:control];
//
//    [UIView beginAnimations:@"UpAnimation" context:nil];
//    [UIView setAnimationDelegate:self];
//    [UIView setAnimationDuration:0.2];
//    control.view.frame = CGRectMake(0, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
//    [UIView commitAnimations];
    
    if (_isCapturing)
    {
        [_videoCamera stop];
        _isCapturing = NO;
    }
    [self performSelector:@selector(backToViewController) withObject:nil afterDelay:1.0];;
}

-(void)backToViewController
{
    if (_isCapturing)
    {
        [_videoCamera stop];
        _isCapturing = NO;
    }
    //    [self.navigationController popToRootViewControllerAnimated:YES];
    for (UIViewController *controller in self.navigationController.viewControllers) {
        
        //Do not forget to import AnOldViewController.h
        if ([controller isKindOfClass:[PlaceHolderViewController class]]) {
           // [self.navigationController popViewControllerAnimated:YES];
           [self.navigationController popToViewController:controller
                                                 animated:YES];
           break;
        }
    }
}

- (IBAction)backAction:(id)sender
{
    if (_isCapturing)
    {
        [_videoCamera stop];
        _isCapturing = NO;
    }
//    [self.navigationController popToRootViewControllerAnimated:YES];
    for (UIViewController *controller in self.navigationController.viewControllers) {
        
        //Do not forget to import AnOldViewController.h
        if ([controller isKindOfClass:[PlaceHolderViewController class]]) {
            
            [self.navigationController popToViewController:controller
                                                  animated:YES];
            break;
        }
    }
}

#pragma  action sheet delegate
- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    [self createExcel];
                    break;
                case 1:
                    [self createPdf];
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}
-(void)createExcel
{
    isPdf=NO;
    dataArr = [mgrObj displayData:@"forScanData"];
    NSLog(@"%@",dataArr);
    scanInfoArray=[[NSMutableArray alloc]init];
    
    for (int i = 0;i<dataArr.count;i++)
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setValue:[NSString stringWithFormat:@"%d",i+1] forKey:@"SR NO"];
        [dict setValue:[[dataArr objectAtIndex:i]valueForKey:@"docType"] forKey:@"DOCUMENT TYPE"];
        [dict setValue:[[dataArr objectAtIndex:i]valueForKey:@"first_name"] forKey:@"FIRST NAME"];
        [dict setValue:[[dataArr objectAtIndex:i]valueForKey:@"last_name"] forKey:@"LAST NAME"];
        [dict setValue:[[dataArr objectAtIndex:i] valueForKey:@"DOB"] forKey:@"DOB"];
        [dict setValue:[[dataArr objectAtIndex:i] valueForKey:@"DOE"] forKey:@"DOE"];
        [dict setValue:[[dataArr objectAtIndex:i] valueForKey:@"country"] forKey:@"COUNTRY"];
        //        [dict setValue:[[dataArr objectAtIndex:i] valueForKey:@"date"] forKey:@"DATE"];
        [dict setValue:[[dataArr objectAtIndex:i] valueForKey:@"gender"]forKey:@"GENDER"];
        [dict setValue:[[dataArr objectAtIndex:i] valueForKey:@"passport_no"] forKey:@"DOCUMENT NO"];
        [dict setValue:[[dataArr objectAtIndex:i] valueForKey:@"address"] forKey:@"ADDRESS"];
        
        [dict setValue:[[dataArr objectAtIndex:i] valueForKey:@"is_auth"] forKey:@"AUTHENTICATED"];
        [dict setValue:[[dataArr objectAtIndex:i] valueForKey:@"glass_des"] forKey:@"GLASSES DECISION"];
        [dict setValue:[[dataArr objectAtIndex:i] valueForKey:@"glass_scr"] forKey:@"GLASSES SCORE"];
        [dict setValue:[[dataArr objectAtIndex:i] valueForKey:@"live_res"] forKey:@"LIVENESS RESULT"];
        [dict setValue:[[dataArr objectAtIndex:i] valueForKey:@"live_scr"] forKey:@"LIVENESS SCORE"];
        [dict setValue:[[dataArr objectAtIndex:i] valueForKey:@"match_scr"] forKey:@"MATCH SCORE"];
        [scanInfoArray addObject:dict];
        
    }
    if ([dataArr count] == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APPNAME
                                                            message:@"No data to export"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
    else
    {
        [self callExcel];
        
    }
    
    
}
-(void)createPdf
{
    isPdf=YES;
    
    dataArr = [mgrObj displayData:@"forScanData"];
    NSLog(@"%@",dataArr);
    scanInfoArray=[[NSMutableArray alloc]init];
    
    for (int i = 0;i<dataArr.count;i++)
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setValue:[NSString stringWithFormat:@"%d",i+1] forKey:@"SR NO"];
        [dict setValue:[[dataArr objectAtIndex:i]valueForKey:@"docType"] forKey:@"DOCUMENT TYPE"];
        [dict setValue:[[dataArr objectAtIndex:i]valueForKey:@"first_name"] forKey:@"FIRST NAME"];
        [dict setValue:[[dataArr objectAtIndex:i]valueForKey:@"last_name"] forKey:@"LAST NAME"];
        [dict setValue:[[dataArr objectAtIndex:i] valueForKey:@"DOB"] forKey:@"DOB"];
        [dict setValue:[[dataArr objectAtIndex:i] valueForKey:@"DOE"] forKey:@"DOE"];
        [dict setValue:[[dataArr objectAtIndex:i] valueForKey:@"country"] forKey:@"COUNTRY"];
        //        [dict setValue:[[dataArr objectAtIndex:i] valueForKey:@"date"] forKey:@"DATE"];
        [dict setValue:[[dataArr objectAtIndex:i] valueForKey:@"gender"]forKey:@"GENDER"];
        [dict setValue:[[dataArr objectAtIndex:i] valueForKey:@"passport_no"] forKey:@"DOCUMENT NO"];
        [dict setValue:[[dataArr objectAtIndex:i] valueForKey:@"address"] forKey:@"ADDRESS"];
        // zoom
        [dict setValue:[[dataArr objectAtIndex:i] valueForKey:@"is_auth"] forKey:@"AUTHENTICATED"];
        [dict setValue:[[dataArr objectAtIndex:i] valueForKey:@"glass_des"] forKey:@"GLASSES DECISION"];
        [dict setValue:[[dataArr objectAtIndex:i] valueForKey:@"glass_scr"] forKey:@"GLASSES SCORE"];
        [dict setValue:[[dataArr objectAtIndex:i] valueForKey:@"live_res"] forKey:@"LIVENESS RESULT"];
        [dict setValue:[[dataArr objectAtIndex:i] valueForKey:@"live_scr"] forKey:@"LIVENESS SCORE"];
        [dict setValue:[[dataArr objectAtIndex:i] valueForKey:@"match_scr"] forKey:@"MATCH SCORE"];
        [scanInfoArray addObject:dict];
        
    }
    if ([dataArr count] == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APPNAME
                                                            message:@"No data to export"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
    else
    {
        [self callPdf];
        
    }
    
}
-(void)callCsv
{
    
    NSMutableString *csvString = [[NSMutableString alloc]initWithCapacity:0];
    [csvString appendString:@"SRNO, DOCUMENTTYPE, FIRSTNAME, LASTNAME, DOB, DOE, COUNTRY, GENDER, DOCUMENTNO, PHOTO\n"];
    int i=1;
    
    for (NSDictionary *dct in dataArr)
    {
        UIImage *img1=[self loadImage:[dct valueForKey:@"img"]];
        NSString *img = [self imageToNSString:img1];
        [csvString appendString:@"\n"];
        
        [csvString appendString:[NSString stringWithFormat:@"%d, %@, %@, %@, %@, %@, %@, %@, %@, %@",i,[dct valueForKey:@"docType"],[dct valueForKey:@"first_name"],[dct valueForKey:@"last_name"],[dct valueForKey:@"DOB"],[dct valueForKey:@"DOE"],[dct valueForKey:@"country"],[dct valueForKey:@"gender"],[dct valueForKey:@"passport_no"],img]];
        i++;
    }
    
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, @"scanneddata.csv"];
    [csvString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSMutableDictionary* attributes = [[NSMutableDictionary alloc] init];
    NSNumber* permission = [NSNumber numberWithLong: 0640];
    [attributes setObject: permission forKey: NSFilePosixPermissions];
    NSFileManager* fileSystem = [NSFileManager defaultManager];
    if (![fileSystem createFileAtPath: @"scanneddata.csv" contents: nil attributes: attributes])
    {
        [self mail:csvString];
        
    }
    
}

-(void)callExcel
//{
//
//    NSMutableString *excel = [[NSMutableString alloc] init];
//    [excel appendString:@"<?xml version=\"1.0\"?>\n<?mso-application progid=\"Excel.Sheet\"?>\n<Workbook xmlns=\"urn:schemas-microsoft-com:office:spreadsheet\" xmlns:o=\"urn:schemas-microsoft-com:office:office\" "];
//    [excel appendString:@"xmlns:x=\"urn:schemas-microsoft-com:office:excel\" xmlns:ss=\"urn:schemas-microsoft-com:office:spreadsheet\" xmlns:html=\"http://www.w3.org/TR/REC-html40\">\n<DocumentProperties xmlns=\"urn:schemas-microsoft-com:office:office\">"];
//    [excel appendString:@"<LastAuthor>Kuzora</LastAuthor>"];
//    [excel appendString:[NSString stringWithFormat:@"<Created>%@</Created>",[NSDate date]]];
//    [excel appendString:@"<Version>11.5606</Version>\n</DocumentProperties>\n<ExcelWorkbook xmlns=\"urn:schemas-microsoft-com:office:excel\">\n<WindowHeight>6690</WindowHeight>\n<WindowWidth>14355</WindowWidth>"];
//    [excel appendString:@"<WindowTopX>360</WindowTopX>\n<WindowTopY>75</WindowTopY>\n<ProtectStructure>False</ProtectStructure>\n<ProtectWindows>False</ProtectWindows>\n</ExcelWorkbook>\n<Styles>"];
//    [excel appendString:@"<Style ss:ID=\"Default\" ss:Name=\"Normal\">\n<Alignment ss:Vertical=\"Bottom\"/>\n<Borders/>\n<Font/>\n<Interior/>\n<NumberFormat/>\n<Protection/>\n</Style>"];
//    [excel appendString:@"<Style ss:ID=\"s21\">\n<NumberFormat ss:Format=\"Medium Date\"/>\n</Style><Style ss:ID=\"s22\">\n<NumberFormat ss:Format=\"Short Date\"/>\n</Style></Styles>"];
//
//    [excel appendString:@"<Worksheet ss:Name=\"User\">"];
//    [excel appendString:@"<Table ss:ExpandedColumnCount=\"8\" ss:ExpandedRowCount=\"2\" x:FullColumns=\"1\" x:FullRows=\"1\">"];
//    [excel appendString:@"<Row>"];
//    [excel appendString:@"<Cell><Data ss:Type=\"String\">SR NO</Data></Cell>"];
//    [excel appendString:@"<Cell><Data ss:Type=\"String\">DOCUMENT TYPE</Data></Cell>"];
//    [excel appendString:@"<Cell><Data ss:Type=\"String\">FIRST NAME</Data></Cell>"];
//    [excel appendString:@"<Cell><Data ss:Type=\"String\">LAST NAME</Data></Cell>"];
//    [excel appendString:@"<Cell><Data ss:Type=\"String\">DOB</Data></Cell>"];
//    [excel appendString:@"<Cell><Data ss:Type=\"String\">DOE</Data></Cell>"];
//    [excel appendString:@"<Cell><Data ss:Type=\"String\">COUNTRY</Data></Cell>"];
//    [excel appendString:@"<Cell><Data ss:Type=\"String\">GENDER</Data></Cell>"];
//    [excel appendString:@"<Cell><Data ss:Type=\"String\">DOCUMENT NO</Data></Cell>"];
//    [excel appendString:@"<Cell><Data ss:Type=\"String\">PHOTO</Data></Cell></Row>"];
//
//    int i=1;
//
//    for (NSDictionary *dct in dataArr)
//    {
//        UIImage *img1=[self loadImage:[dct valueForKey:@"img"]];
//        NSString *img = [self imageToNSString:img1];
//        [excel appendString:@"<Row>"];
//        [excel appendString:[NSString stringWithFormat:@"<Cell><Data ss:Type=\"Number\">%d</Data></Cell>",i]];
//        if ([dct valueForKey:@"docType"] == (id)[NSNull null] || [[dct valueForKey:@"docType"] length] == 0 || [[dct valueForKey:@"docType"] isEqualToString:@""])
//        {
//            [excel appendString:[NSString stringWithFormat:@"<Cell><Data ss:Type=\"String\"></Data></Cell>"]];
//        }
//        else
//        {
//            [excel appendString:[NSString stringWithFormat:@"<Cell><Data ss:Type=\"String\">%@</Data></Cell>",[dct valueForKey:@"docType"]]];
//        }
//        if ([dct valueForKey:@"first_name"] == (id)[NSNull null] || [[dct valueForKey:@"first_name"] length] == 0 || [[dct valueForKey:@"first_name"] isEqualToString:@""])
//        {
//            [excel appendString:[NSString stringWithFormat:@"<Cell><Data ss:Type=\"String\"></Data></Cell>"]];
//        }
//        else
//        {
//            NSCharacterSet *alphanumericSet = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
//            alphanumericSet = alphanumericSet.invertedSet;
//            NSString *firstname = [dct valueForKey:@"first_name"];
//            NSString *result = [firstname stringByTrimmingCharactersInSet:alphanumericSet];
//            [excel appendString:[NSString stringWithFormat:@"<Cell><Data ss:Type=\"String\">%@</Data></Cell>",result]];
//        }
//        if ([dct valueForKey:@"last_name"] == (id)[NSNull null] || [[dct valueForKey:@"last_name"] length] == 0 || [[dct valueForKey:@"last_name"] isEqualToString:@""])
//        {
//            [excel appendString:[NSString stringWithFormat:@"<Cell><Data ss:Type=\"String\"></Data></Cell>"]];
//        }
//        else
//        {
//            NSCharacterSet *alphanumericSet = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
//            alphanumericSet = alphanumericSet.invertedSet;
//            NSString *lastname = [dct valueForKey:@"last_name"];
//            NSString *result = [lastname stringByTrimmingCharactersInSet:alphanumericSet];
//            [excel appendString:[NSString stringWithFormat:@"<Cell><Data ss:Type=\"String\">%@</Data></Cell>",result]];
//        }
//        if ([dct valueForKey:@"DOB"] == (id)[NSNull null] || [[dct valueForKey:@"DOB"] length] == 0 ||[[dct valueForKey:@"DOB"] isEqualToString:@""] )
//        {
//            [excel appendString:[NSString stringWithFormat:@"<Cell><Data ss:Type=\"String\"></Data></Cell>"]];
//        }
//        else
//        {
//            [excel appendString:[NSString stringWithFormat:@"<Cell><Data ss:Type=\"String\">%@</Data></Cell>",[dct valueForKey:@"DOB"]]];
//        }
//        if ([dct valueForKey:@"DOE"] == (id)[NSNull null] || [[dct valueForKey:@"DOE"] length] == 0 || [[dct valueForKey:@"DOE"] isEqualToString:@""])
//        {
//            [excel appendString:[NSString stringWithFormat:@"<Cell><Data ss:Type=\"String\"></Data></Cell>"]];
//        }
//        else
//        {
//            [excel appendString:[NSString stringWithFormat:@"<Cell><Data ss:Type=\"String\">%@</Data></Cell>",[dct valueForKey:@"DOE"]]];
//        }
//        if ([dct valueForKey:@"country"] == (id)[NSNull null] || [[dct valueForKey:@"country"] length] == 0 || [[dct valueForKey:@"country"] isEqualToString:@""])
//        {
//            [excel appendString:[NSString stringWithFormat:@"<Cell><Data ss:Type=\"String\"></Data></Cell>"]];
//        }
//        else
//        {
//
//            NSCharacterSet *alphanumericSet = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
//            alphanumericSet = alphanumericSet.invertedSet;
//            NSString *country = [dct valueForKey:@"country"];
//            NSString *result = [country stringByTrimmingCharactersInSet:alphanumericSet];
//
//            [excel appendString:[NSString stringWithFormat:@"<Cell><Data ss:Type=\"String\">%@</Data></Cell>",result]];
//        }
//        if ([dct valueForKey:@"gender"] == (id)[NSNull null] || [[dct valueForKey:@"gender"] length] == 0 || [[dct valueForKey:@"gender"] isEqualToString:@""])
//        {
//            [excel appendString:[NSString stringWithFormat:@"<Cell><Data ss:Type=\"String\"></Data></Cell>"]];
//        }
//        else
//        {
//            [excel appendString:[NSString stringWithFormat:@"<Cell><Data ss:Type=\"String\">%@</Data></Cell>",[dct valueForKey:@"gender"]]];
//        }
//        if ([dct valueForKey:@"passport_no"] == (id)[NSNull null] || [[dct valueForKey:@"passport_no"] length] == 0 ||[[dct valueForKey:@"passport_no"] isEqualToString:@""])
//        {
//            [excel appendString:[NSString stringWithFormat:@"<Cell><Data ss:Type=\"String\"></Data></Cell>"]];
//        }
//        else
//        {
//            [excel appendString:[NSString stringWithFormat:@"<Cell><Data ss:Type=\"String\">%@</Data></Cell>",[dct valueForKey:@"passport_no"]]];
//        }
//
//        [excel appendString:[NSString stringWithFormat:@"<Cell><Data ss:Type=\"String\">%@</Data></Cell>",img]];
//        [excel appendString:@"</Row>"];
//        i++;
//    }
//    [excel appendString:@"</Table><WorksheetOptions xmlns=\"urn:schemas-microsoft-com:office:excel\">"];
//    [excel appendString:@"<Selected/><LeftColumnVisible>4</LeftColumnVisible><Panes><Pane>"];
//    [excel appendString:@"<Number>3</Number><ActiveRow>2</ActiveRow><ActiveCol>2</ActiveCol>"];
//    [excel appendString:@"</Pane></Panes><ProtectObjects>False</ProtectObjects>"];
//    [excel appendString:@"<ProtectScenarios>False</ProtectScenarios></WorksheetOptions></Worksheet>"];
//    [excel appendString:@"</Workbook>"];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, @"scanneddata.xls"];
//    [excel writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
//    NSMutableDictionary* attributes = [[NSMutableDictionary alloc] init];
//    NSNumber* permission = [NSNumber numberWithLong: 0640];
//    [attributes setObject: permission forKey: NSFilePosixPermissions];
//    NSFileManager* fileSystem = [NSFileManager defaultManager];
//    if (![fileSystem createFileAtPath: @"scanneddata.xls" contents: nil attributes: attributes])
//    {
//        [self mail:excel];
//    }
//
//}
{
    BookHandle book = xlCreateBook(); // use xlCreateXMLBook() for working with xlsx files
    
    SheetHandle sheet = xlBookAddSheet(book, "Sheet1", NULL);
    FormatHandle boldFormat = xlBookAddFormat(book, 0);
    
    xlSheetWriteStr(sheet, 1, 0, "SR NO", boldFormat);
    xlSheetWriteStr(sheet, 1, 1, "DOCUMENT TYPE", boldFormat);
    xlSheetWriteStr(sheet, 1, 2, "FIRST NAME", boldFormat);
    xlSheetWriteStr(sheet, 1, 3, "LAST NAME", boldFormat);
    xlSheetWriteStr(sheet, 1, 4, "DOB", boldFormat);
    xlSheetWriteStr(sheet, 1, 5, "DOE", boldFormat);
    xlSheetWriteStr(sheet, 1, 6, "COUNTRY", boldFormat);
    xlSheetWriteStr(sheet, 1, 7, "GENDER", boldFormat);
    xlSheetWriteStr(sheet, 1, 8, "DOCUMENT NO", boldFormat);
    xlSheetWriteStr(sheet, 1, 9, "ADDRESS", boldFormat);
    xlSheetWriteStr(sheet, 1, 10, "AUTHENTICATED", boldFormat);
    xlSheetWriteStr(sheet, 1, 11, "GLASSESDECISION", boldFormat);
    xlSheetWriteStr(sheet, 1, 12, "GLASSESSCORE", boldFormat);
    xlSheetWriteStr(sheet, 1, 13, "LIVENESSRESULT", boldFormat);
    xlSheetWriteStr(sheet, 1, 14, "LIVENESSSCORE", boldFormat);
    xlSheetWriteStr(sheet, 1, 15, "MATCHSCORE", boldFormat);

    //    xlSheetWriteStr(sheet, 1, 9, "PHOTO", boldFormat);
    
    int i=1;
    
    for (NSDictionary *dct in dataArr)
    {
        UIImage *img1=[self loadImage:[dct valueForKey:@"img"]];
        
        NSString *img = [self imageToNSString:img1];
        
        
        //        i,[dct valueForKey:@"docType"],[dct valueForKey:@"first_name"],[dct valueForKey:@"last_name"],[dct valueForKey:@"DOB"],[dct valueForKey:@"DOE"],[dct valueForKey:@"country"],[dct valueForKey:@"gender"],[dct valueForKey:@"passport_no"],img]];
        NSString *no = [NSString stringWithFormat:@"%d",i];
        const char *converted_back = [no UTF8String];
        const char *converted_back1,*converted_back2,*converted_back3,*converted_back4,*converted_back5,*converted_back6,*converted_back7,*converted_back8,*converted_back9,*converted_back10,*converted_back11,*converted_back12,*converted_back13,*converted_back14,*converted_back15,*converted_back16,*converted_back17,*converted_back18,*converted_back19,*converted_back20,*converted_back21;
        if ([dct valueForKey:@"docType"] == (id)[NSNull null] || [[dct valueForKey:@"docType"] length] == 0 || [[dct valueForKey:@"docType"] isEqualToString:@""])
        {
            converted_back1 = [@"" UTF8String];
        }
        else
        {
            converted_back1 = [[dct objectForKey:@"docType"] UTF8String];
            
        }
        if ([dct valueForKey:@"first_name"] == (id)[NSNull null] || [[dct valueForKey:@"first_name"] length] == 0 || [[dct valueForKey:@"first_name"] isEqualToString:@""])
        {
            converted_back2 = [@"" UTF8String];
            
        }
        else
        {
            converted_back2 = [[dct objectForKey:@"first_name"] UTF8String];
            
        }
        if ([dct valueForKey:@"last_name"] == (id)[NSNull null] || [[dct valueForKey:@"last_name"] length] == 0 || [[dct valueForKey:@"last_name"] isEqualToString:@""])
        {
            converted_back3 = [@"" UTF8String];
            
        }
        else
        {
            converted_back3 = [[dct objectForKey:@"last_name"] UTF8String];
            
        }
        if ([dct valueForKey:@"DOB"] == (id)[NSNull null] || [[dct valueForKey:@"DOB"] length] == 0 || [[dct valueForKey:@"DOB"] isEqualToString:@""])
        {
            converted_back4 = [@"" UTF8String];
            
        }
        else
        {
            converted_back4 = [[dct objectForKey:@"DOB"] UTF8String];
            
        }
        if ([dct valueForKey:@"DOE"] == (id)[NSNull null] || [[dct valueForKey:@"DOE"] length] == 0 || [[dct valueForKey:@"DOE"] isEqualToString:@""])
        {
            converted_back5 = [@"" UTF8String];
            
        }
        else
        {
            converted_back5 = [[dct objectForKey:@"DOE"] UTF8String];
            
        }
        if ([dct valueForKey:@"country"] == (id)[NSNull null] || [[dct valueForKey:@"country"] length] == 0 || [[dct valueForKey:@"country"] isEqualToString:@""])
        {
            converted_back6 = [@"" UTF8String];
            
        }
        else
        {
            converted_back6 = [[dct objectForKey:@"country"] UTF8String];
            
        }
        if ([dct valueForKey:@"gender"] == (id)[NSNull null] || [[dct valueForKey:@"gender"] length] == 0 || [[dct valueForKey:@"gender"] isEqualToString:@""])
        {
            converted_back7 = [@"" UTF8String];
            
        }
        else
        {
            converted_back7 = [[dct objectForKey:@"gender"] UTF8String];
            
        }
        if ([dct valueForKey:@"passport_no"] == (id)[NSNull null] || [[dct valueForKey:@"passport_no"] length] == 0 || [[dct valueForKey:@"passport_no"] isEqualToString:@""])
        {
            converted_back8 = [@"" UTF8String];
            
        }
        else
        {
            converted_back8 = [[dct objectForKey:@"passport_no"] UTF8String];
            
        }
        if ([dct valueForKey:@"img"] == (id)[NSNull null] || [[dct valueForKey:@"img"] length] == 0 || [[dct valueForKey:@"img"] isEqualToString:@""])
        {
            converted_back9 = [@"" UTF8String];
            
        }
        else
        {
            converted_back9 = [img UTF8String];
            
        }
        if ([dct valueForKey:@"address"] == (id)[NSNull null] || [[dct valueForKey:@"address"] length] == 0 || [[dct valueForKey:@"address"] isEqualToString:@""])
        {
            converted_back10 = [@"" UTF8String];
            
        }
        else
        {
            converted_back10 = [[dct objectForKey:@"address"] UTF8String];
            
        }
        if ([dct valueForKey:@"is_auth"] == (id)[NSNull null] || [[dct valueForKey:@"is_auth"] length] == 0 || [[dct valueForKey:@"is_auth"] isEqualToString:@""])
        {
            converted_back11 = [@"" UTF8String];
            
        }
        else
        {
            converted_back11 = [[dct objectForKey:@"is_auth"] UTF8String];
            
        }
        if ([dct valueForKey:@"glass_des"] == (id)[NSNull null] || [[dct valueForKey:@"glass_des"] length] == 0 || [[dct valueForKey:@"glass_des"] isEqualToString:@""])
        {
            converted_back12 = [@"" UTF8String];
            
        }
        else
        {
            converted_back12 = [[dct objectForKey:@"glass_des"] UTF8String];
            
        }
        if ([dct valueForKey:@"glass_scr"] == (id)[NSNull null] || [[dct valueForKey:@"glass_scr"] length] == 0 || [[dct valueForKey:@"glass_scr"] isEqualToString:@""])
        {
            converted_back13 = [@"" UTF8String];
            
        }
        else
        {
            converted_back13 = [[dct objectForKey:@"glass_scr"] UTF8String];
            
        }
        if ([dct valueForKey:@"live_res"] == (id)[NSNull null] || [[dct valueForKey:@"live_res"] length] == 0 || [[dct valueForKey:@"live_res"] isEqualToString:@""])
        {
            converted_back14 = [@"" UTF8String];
            
        }
        else
        {
            converted_back14 = [[dct objectForKey:@"live_res"] UTF8String];
            
        }
        if ([dct valueForKey:@"live_res_auth_face"] == (id)[NSNull null] || [[dct valueForKey:@"live_res_auth_face"] length] == 0 || [[dct valueForKey:@"live_res_auth_face"] isEqualToString:@""])
        {
            converted_back15 = [@"" UTF8String];
            
        }
        else
        {
            converted_back15 = [[dct objectForKey:@"live_res_auth_face"] UTF8String];
            
        }
        if ([dct valueForKey:@"live_res_enrl_face"] == (id)[NSNull null] || [[dct valueForKey:@"live_res_enrl_face"] length] == 0 || [[dct valueForKey:@"live_res_enrl_face"] isEqualToString:@""])
        {
            converted_back16 = [@"" UTF8String];
            
        }
        else
        {
            converted_back16 = [[dct objectForKey:@"live_res_enrl_face"] UTF8String];
            
        }
        if ([dct valueForKey:@"live_scr"] == (id)[NSNull null] || [[dct valueForKey:@"live_scr"] length] == 0 || [[dct valueForKey:@"live_scr"] isEqualToString:@""])
        {
            converted_back17 = [@"" UTF8String];
            
        }
        else
        {
            converted_back17 = [[dct objectForKey:@"live_scr"] UTF8String];
            
        }
        if ([dct valueForKey:@"live_scr_auth_face"] == (id)[NSNull null] || [[dct valueForKey:@"live_scr_auth_face"] length] == 0 || [[dct valueForKey:@"live_scr_auth_face"] isEqualToString:@""])
        {
            converted_back18 = [@"" UTF8String];
            
        }
        else
        {
            converted_back18 = [[dct objectForKey:@"live_scr_auth_face"] UTF8String];
            
        }
        if ([dct valueForKey:@"live_scr_enrl_face"] == (id)[NSNull null] || [[dct valueForKey:@"live_scr_enrl_face"] length] == 0 || [[dct valueForKey:@"live_scr_enrl_face"] isEqualToString:@""])
        {
            converted_back19 = [@"" UTF8String];
            
        }
        else
        {
            converted_back19 = [[dct objectForKey:@"live_scr_enrl_face"] UTF8String];
            
        }
        if ([dct valueForKey:@"match_scr"] == (id)[NSNull null] || [[dct valueForKey:@"match_scr"] length] == 0 || [[dct valueForKey:@"match_scr"] isEqualToString:@""])
        {
            converted_back20 = [@"" UTF8String];
            
        }
        else
        {
            converted_back20 = [[dct objectForKey:@"match_scr"] UTF8String];
            
        }
        if ([dct valueForKey:@"retry_sug"] == (id)[NSNull null] || [[dct valueForKey:@"retry_sug"] length] == 0 || [[dct valueForKey:@"retry_sug"] isEqualToString:@""])
        {
            converted_back21 = [@"" UTF8String];
            
        }
        else
        {
            converted_back21 = [[dct objectForKey:@"retry_sug"] UTF8String];
            
        }
        
        
      
        
        
        xlSheetWriteStr(sheet, i+2, 0, converted_back, 0);
        xlSheetWriteStr(sheet, i+2, 1, converted_back1, 0);
        xlSheetWriteStr(sheet, i+2, 2, converted_back2, 0);
        xlSheetWriteStr(sheet, i+2, 3, converted_back3, 0);
        xlSheetWriteStr(sheet, i+2, 4, converted_back4, 0);
        xlSheetWriteStr(sheet, i+2, 5, converted_back5, 0);
        xlSheetWriteStr(sheet, i+2, 6, converted_back6, 0);
        xlSheetWriteStr(sheet, i+2, 7, converted_back7, 0);
        xlSheetWriteStr(sheet, i+2, 8, converted_back8, 0);
        xlSheetWriteStr(sheet, i+2, 9, converted_back10, 0);
        // ZOOM
        xlSheetWriteStr(sheet, i+2, 10, converted_back11, 0);
        xlSheetWriteStr(sheet, i+2, 11, converted_back12, 0);
        xlSheetWriteStr(sheet, i+2, 12, converted_back13, 0);
        xlSheetWriteStr(sheet, i+2, 13, converted_back14, 0);
        xlSheetWriteStr(sheet, i+2, 14, converted_back17, 0);
        xlSheetWriteStr(sheet, i+2, 15, converted_back20, 0);
        
        //        xlSheetWriteComment(sheet, i+2, 9, converted_back9,nil,200,50);
        
        i++;
    }
    
    
    NSString *documentPath =
    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filename = [documentPath stringByAppendingPathComponent:@"scanneddata.xls"];
    xlBookSave(book, [filename UTF8String]);
    
    xlBookRelease(book);
    
    NSURL *URL = [NSURL fileURLWithPath:filename];
    NSArray *activityItems = [NSArray arrayWithObjects:URL, nil];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    
    [self presentViewController:activityViewController animated:YES completion:nil];
    
}

-(void)callPdf
{
    NSMutableString *csvString = [[NSMutableString alloc]initWithCapacity:0];
    //    [csvString appendString:@"<table  border=\"1\" cellspacing=\"0\" style=\"font-family:Calibri\">"];
    [csvString appendString:@"<table style=\"font-family:Arial\" border=\"1\" cellspacing=\"0\">"];
    [csvString appendString:@"<tr>"];
    [csvString appendString:@"<th>SR NO</th><th>DOCUMENT TYPE</th><th>FIRST NAME</th><th>LAST NAME</th><th>DOB</th><th>DOE</th><th>COUNTRY</th><th>GENDER</th><th>DOCUMENT NO</th><th>ADDRESS</th><th>AUTHENTICATED</th><th>GLASSES DECISION</th><th>GLASSES SCORE</th><th>LIVENESS RESULT</th><th>LIVENESS SCORE</th><th>MATCH SCORE</th><th>PHOTO</th>"];
    [csvString appendString:@"</tr>"];
    int i = 1;
    
    for (NSDictionary *dct in dataArr)
    {
        [csvString appendString:@"<tr>"];
        
        UIImage *img1=[self loadImage:[dct valueForKey:@"img"]];
        
        NSString *img = [self imageToNSString:img1];
        
        [csvString appendString:[NSString stringWithFormat:@"<td>%d</td><td>%@</td><td>%@</td><td>%@</td><td>%@</td><td>%@</td><td>%@</td><td>%@</td><td>%@</td><td>%@</td><td>%@</td><td>%@</td><td>%@</td><td>%@</td><td>%@</td><td>%@</td><td><img src=\"data:image/jpg;base64,%@\" alt=\"\" style=\"width: 100px;\"/></td>",i,[dct valueForKey:@"docType"],[dct valueForKey:@"first_name"],[dct valueForKey:@"last_name"],[dct valueForKey:@"DOB"],[dct valueForKey:@"DOE"],[dct valueForKey:@"country"],[dct valueForKey:@"gender"],[dct valueForKey:@"passport_no"],[dct valueForKey:@"address"],[dct valueForKey:@"is_auth"],[dct valueForKey:@"glass_des"],[dct valueForKey:@"glass_scr"],[dct valueForKey:@"live_res"],[dct valueForKey:@"live_scr"],[dct valueForKey:@"match_scr"],img]];
        [csvString appendString:@"</tr>"];
        i++;
        
    }
    [csvString appendString:@"<table>"];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, @"scanneddata.pdf"];
    self.PDFCreator = [NDHTMLtoPDF createPDFWithHTML:csvString pathForPDF:filePath delegate:self pageSize:kPaperSizeA4 margins:UIEdgeInsetsMake(10, 5, 10, 5)];
    
    
    
    
}
- (UIImage *)loadImage:(NSString *)imageName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:
                      [NSString stringWithString:imageName] ];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
}
- (NSString *)imageToNSString:(UIImage *)image
{
    NSData *imageData = UIImagePNGRepresentation(image);
    
    return [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}
- (void) mail: (NSString*) filePath
{
    
    if (![MFMailComposeViewController canSendMail])
    {
        //Show alert that device cannot send email, this is because an email account     hasn't been setup.
    }
    
    else
    {
        
        //**EDIT HERE**
        //Use this to retrieve your recently saved file
        if (isPdf)
        {
            NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
            NSString *filename = [documentPath stringByAppendingPathComponent:@"scanneddata.pdf"];
            NSURL *URL = [NSURL fileURLWithPath:filename];
            NSArray *activityItems = [NSArray arrayWithObjects:URL, nil];
            UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
            [self presentViewController:activityViewController animated:YES completion:nil];
            //            //**END OF EDIT**
            //
            //            NSString *mimeType = @"application/pdf"; //This should be the MIME type for els files. May want to double check.
            //            NSData *fileData = [NSData dataWithContentsOfFile:filename];
            //            NSString *fileNameWithExtension = @"scanneddata.pdf"; //This is what you want the file to be called on the email along with it's extension:
            //
            //            //If you want to then delete the file:
            //            NSError *error;
            //            if (![[NSFileManager defaultManager] removeItemAtPath:filename error:&error])
            //                NSLog(@"ERROR REMOVING FILE: %@", [error localizedDescription]);
            //
            //
            //            //Send email
            //            MFMailComposeViewController *mailMessage = [[MFMailComposeViewController alloc] init];
            //            [mailMessage setMailComposeDelegate:self];
            //            [mailMessage addAttachmentData:fileData mimeType:mimeType fileName:fileNameWithExtension];
            //            [self presentViewController:mailMessage animated:YES completion:nil];
        }
        else
        {
            NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
            NSString *filename = [documentPath stringByAppendingPathComponent:@"scanneddata.xls"];
            NSURL *URL = [NSURL fileURLWithPath:filename];
            NSArray *activityItems = [NSArray arrayWithObjects:URL, nil];
            UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
            [self presentViewController:activityViewController animated:YES completion:nil];
            //            //**END OF EDIT**
            //
            //            NSString *mimeType = @"application/vnd.ms-excel"; //This should be the MIME type for els files. May want to double check.
            //            NSData *fileData = [NSData dataWithContentsOfFile:filename];
            //            NSString *fileNameWithExtension = @"scanneddata.xls"; //This is what you want the file to be called on the email along with it's extension:
            //
            //            //If you want to then delete the file:
            //            NSError *error;
            //            if (![[NSFileManager defaultManager] removeItemAtPath:filename error:&error])
            //                NSLog(@"ERROR REMOVING FILE: %@", [error localizedDescription]);
            //
            //
            //            //Send email
            //            MFMailComposeViewController *mailMessage = [[MFMailComposeViewController alloc] init];
            //            [mailMessage setMailComposeDelegate:self];
            //            [mailMessage addAttachmentData:fileData mimeType:mimeType fileName:fileNameWithExtension];
            //            [self presentViewController:mailMessage animated:YES completion:nil];
        }
    }
}
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark NDHTMLtoPDFDelegate

- (void)HTMLtoPDFDidSucceed:(NDHTMLtoPDF*)htmlToPDF
{
    NSString *result = [NSString stringWithFormat:@"%@", htmlToPDF.PDFpath];
    NSLog(@"%@",result);
    [self mail:result];
    
}

- (void)HTMLtoPDFDidFail:(NDHTMLtoPDF*)htmlToPDF
{
    NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did fail (%@)", htmlToPDF];
    NSLog(@"%@",result);
}


- (UIImage *)imageByCroppingImage:(UIImage* )image toSize:(CGSize)size
{
    // not equivalent to image.size (which depends on the imageOrientation)!
    
    double width = (size.width * 2);
    double hidth = (size.height * 2);
    double fullWidth = image.size.width;
    double getX = fullWidth - width;
    
    double fullHeigtht = image.size.height;
    double getY = fullHeigtht / 2;
    getY = hidth / 4;
    
    if ( ([[UIDevice currentDevice] orientation] ==  UIDeviceOrientationPortrait)  ) {
        double with = fullWidth * 0.95;
        double hite = fullHeigtht * 0.35;

        width = with ;
        hidth = hite;
        getX = fullWidth - with;
        getY = (fullHeigtht / 2);
        getY = getY - (hite / 2);
    }
    
    if ( ([[UIDevice currentDevice] orientation] ==  UIDeviceOrientationLandscapeRight)  ) {
        double with = fullWidth * 0.85;
        double hite = fullHeigtht * 0.80;
        
        width = with ;
        hidth = hite;
        hidth = hidth;
        getX = fullWidth - with;
        getY = fullHeigtht / 2;
        getY = getY - (hite / 2);
    }
    
    if ( ([[UIDevice currentDevice] orientation] ==  UIDeviceOrientationLandscapeLeft)  ) {
        double with = fullWidth * 0.85;
        double hite = fullHeigtht * 0.80;

        width = with ;
        hidth = hite;
        getX = fullWidth - with;
        getY = fullHeigtht / 2;
        getY = getY - (hite / 2);
        hidth = hidth;
    }
    
    CGRect cropRect = CGRectMake((getX/2), getY - 40 , width, hidth);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage],  cropRect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return cropped;
}

@end
