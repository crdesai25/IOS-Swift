//
//  FaceImageView.m
//  FaceMatch
//
//  Created by Caroll on 3/12/19.
//  Copyright © 2019 Caroll. All rights reserved.
//

#import "FaceImageView.h"
#import "NSFaceRegion.h"

@implementation FaceImageView

- (void)drawRect:(CGRect)rect {
    if (faceImage == nil)
        return;
    
    CGRect rects = self.bounds;
    float fx = rects.size.width * 1.0 / faceImage.size.width;
    float fy = rects.size.height * 1.0 / faceImage.size.height;
    float f = fx;
    if (f > fy)
        f = fy;
    scale = f;
    float dw = f * faceImage.size.width;
    float dh = f * faceImage.size.height;
    dx = (rects.size.width - dw) / 2;
    dy = (rects.size.height - dh) / 2;
    [faceImage drawInRect:CGRectMake(dx, dy, dw, dh)];
    
    if (featureArray == nil)
        return;

    // Drawing code
    [[UIColor greenColor] set];
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    
    /* Set the width for the line */
    CGContextSetLineWidth(currentContext,
                          2.0f);
    
    for (int i = 0; i < [featureArray count]; i++) {
        NSFaceRegion* faceRegion = [featureArray objectAtIndex:i];
        CGFloat x1, y1, x2, y2;
        x1 = faceRegion.bound.origin.x * f + dx;
        x2 = (faceRegion.bound.origin.x + faceRegion.bound.size.height) * f + dx;
        y1 = faceRegion.bound.origin.y * f + dy;
        y2 = (faceRegion.bound.origin.y + faceRegion.bound.size.height) * f + dy;
        
        CGContextMoveToPoint(currentContext,
                             x1,
                             y1);
        //    CGContextAddLineToPoint(currentContext, currentContext, 0);
        
        /* And end it at this point */
        CGContextAddLineToPoint(currentContext,
                                x2,
                                y1);
        CGContextAddLineToPoint(currentContext,
                                x2,
                                y2);
        CGContextAddLineToPoint(currentContext,
                                x1,
                                y2);
        CGContextAddLineToPoint(currentContext,
                                x1,
                                y1);
    }
    /* Use the context's current color to draw the line */
    CGContextStrokePath(currentContext);
}

- (void) setImage:(UIImage*) image {
    faceImage = image;
}

- (void) setFeatures:(NSMutableArray*) features {
    featureArray = features;
}

- (UIImage*) getImage {
    return faceImage;
}

- (NSMutableArray*) getFeatures {
    return featureArray;
}

- (float) getScale {
    return scale;
}

- (float) getDx {
    return dx;
}

- (float) getDy {
    return dy;
}

@end
