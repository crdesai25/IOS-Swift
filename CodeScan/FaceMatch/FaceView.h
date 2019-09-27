//
//  FaceView.h


#import <UIKit/UIKit.h>
#import "NSFaceRegion.h"

@interface FaceView : UIView {
    UIImage*    faceImage;
    NSFaceRegion* faceRegion;
}


- (void) setImage:(UIImage*) image;
- (void) setFaceRegion:(NSFaceRegion*) faceRegion;
- (UIImage*) getImage;
- (NSFaceRegion*) getFaceRegion;


@end
