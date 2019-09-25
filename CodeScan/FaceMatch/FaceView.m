//
//  FaceView.m
//  FaceMatch
//
//  Created by Caroll on 3/12/19.
//  Copyright © 2019 Caroll. All rights reserved.
//

#import "FaceView.h"
#import "NSFaceRegion.h"

@implementation FaceView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    if (faceImage == nil)
        return;
    
    CGRect rects = self.bounds;
    float fx = rects.size.width * 1.0 / faceImage.size.width;
    float fy = rects.size.height * 1.0 / faceImage.size.height;
    float f = fx;
    if (f > fy)
        f = fy;
    float dw = f * faceImage.size.width;
    float dh = f * faceImage.size.height;
    float dx = (rects.size.width - dw) / 2;
    float dy = (rects.size.height - dh) / 2;
    [faceImage drawInRect:CGRectMake(dx, dy, dw, dh)];
    
    if (faceRegion == nil)
        return;
    
    // Drawing code
    if ([faceRegion face] == 1) {
        [[UIColor greenColor] set];
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        
        CGFloat x1, y1, x2, y2;
        x1 = faceRegion.bound.origin.x * f + dx;
        x2 = (faceRegion.bound.origin.x + faceRegion.bound.size.height) * f + dx;
        y1 = faceRegion.bound.origin.y * f + dy;
        y2 = (faceRegion.bound.origin.y + faceRegion.bound.size.height) * f + dy;
        
        /* Set the width for the line */
        CGContextSetLineWidth(currentContext,
                              2.0f);
        /* Start the line at this point */
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
        /* Use the context's current color to draw the line */
        CGContextStrokePath(currentContext);
    }
}


- (void) setImage:(UIImage*) image {
    faceImage = image;
}

- (void) setFaceRegion:(NSFaceRegion *)region {
    faceRegion = region;
}


- (UIImage*) getImage {
    return faceImage;
}

- (NSFaceRegion*) getFaceRegion {
    return faceRegion;
}


@end
