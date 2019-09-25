//
//  DectectShape.h
//  DectectShape
//
//  Created by apple on 7/20/15.
//  Copyright (c) 2015 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>
#include "opencv2/core/core.hpp"

int loadDiction();

//photoImgR,G,B = 200*200 should be allocated first.
int doRecogGrayImg_Passport(unsigned char* rImg,unsigned char* gImg,unsigned char* bImg, int w, int h,/*int left,int top,int width,int height,*/char* lines, bool& success, char* passportType, char* country,char* surName,char* givenNames,char* passportNumber,char* passportChecksum,char* nationality, char* birth,char* birthChecksum,char* sex,char* expirationDate,char* expirationChecksum,char* personalNumber,char* personalNumberChecksum,char* secondRowChecksum,char* placeOfBirth,char* placeOfIssue,unsigned char* photoImgR,unsigned char* photoImgG,unsigned char* photoImgB, int *phoW, int *phoH, bool bCropPhoto,char* licenseFilePath);

int doFaceDetect(unsigned char* rImg, unsigned char* gImg, unsigned char* bImg, int w, int h, unsigned char* photoImgR, unsigned char* photoImgG, unsigned char* photoImgB, int* phoW, int *phoH);

