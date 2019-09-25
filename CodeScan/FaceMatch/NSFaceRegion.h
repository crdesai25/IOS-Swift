//
//  NSFaceRegion.h
//  FamousPeople
//
//  Created by cal on 9/29/14.
//  Copyright (c) 2014 caldctor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface NSFaceRegion : NSObject
{
}

@property (assign, atomic) int face;
@property (assign, atomic) CGRect  bound;
@property (assign, atomic) double confidence;
@property (nonatomic, strong) NSData *feature;
@property (assign, atomic) UIImage* image;

@end
