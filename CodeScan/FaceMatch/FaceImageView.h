//
//  FaceImageView.h
//  FaceMatch
//
//  Created by Caroll on 3/12/19.
//  Copyright © 2019 Caroll. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FaceImageView : UIView {
    UIImage*    faceImage;
    NSMutableArray* featureArray;
    float scale;
    float dx, dy;
}

- (void) setImage:(UIImage*) image;
- (void) setFeatures:(NSMutableArray*) features;
- (UIImage*) getImage;
- (NSMutableArray*) getFeatures;
- (float) getScale;
- (float) getDx;
- (float) getDy;

@end
