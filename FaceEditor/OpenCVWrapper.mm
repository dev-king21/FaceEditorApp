//
//  OpenCVWrapper.m
//  FaceEditor
//
//  Created by Loyal Lauzier on 11/12/20.
//  Copyright © 2020 Loyal Lauzier. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import "OpenCVWrapper.h"
#import <opencv2/imgcodecs/ios.h>
#import <UIKit/UIKit.h>

@implementation OpenCVWrapper
+ (NSString *)openCVVersionString {
return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
}

+ (UIImage *)blur:(UIImage *)image radius:(double)radius{
    cv::Mat mat;
    UIImageToMat(image, mat);
    cv::GaussianBlur(mat,mat,cv::Size(NULL,NULL), radius);
    UIImage *blurredImage = MatToUIImage(mat);
    return blurredImage;
}

//Users/loyal/Documents/FaceEditor/FaceEditor/ToolbarViewController.swift
+ (UIImage *)blemish:(UIImage *)image bsize:(double)bsize x: (int)x y: (int)y w: (double)w h: (double)h {
    cv::Mat mat;
    UIImageToMat(image, mat);
    int im_width = mat.size().width;
    int im_height = mat.size().height;
    int smp_size = bsize; // blue size
    double scale = im_width/w;
    int r_x = (int) x * scale;
    int r_y = (int) y * scale - (h*scale-im_height)/2;
    cv::Rect rect;
    rect.x = r_x - smp_size > 0 ? r_x - smp_size : 0;
    rect.y = r_y - smp_size > 0 ? r_y - smp_size : 0;
    rect.width = r_x + smp_size > im_width ? im_width - rect.x : r_x + smp_size - rect.x;

	rect.height = r_y + smp_size > im_height ? im_height - rect.y : r_y + smp_size - rect.y;
    
    cv::Mat blRegion = mat(rect);
    cv::Mat rblRegion;
    cv::GaussianBlur(blRegion, rblRegion, cv::Size(0.7, 0.7), 5, 5);
 
    for(int j=1; j < rect.height; j++){
        
        cv::Rect dltRect, _dltRect;
        double w0 = sqrt(pow(rect.width / 2, 2) - pow((rect.width / 2 - j), 2)) * 2;
        dltRect.x = rect.width / 2 - w0 / 2;
        dltRect.y = j;
        dltRect.width = w0;
        dltRect.height = 1;
        _dltRect.x = rect.x + dltRect.x;
        _dltRect.y = rect.y + dltRect.y;
        _dltRect.width = dltRect.width;
        _dltRect.height = dltRect.height;
        
        cv::Mat tmp = rblRegion(dltRect);
	        tmp.copyTo(mat(_dltRect));
    }
 
    UIImage *blurredImage = MatToUIImage(mat);
    return blurredImage;
}

@end
