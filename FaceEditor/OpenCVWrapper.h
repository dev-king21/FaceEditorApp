//
//  OpenCVWrapper.h
//  FaceEditor
//
//  Created by Loyal Lauzier on 11/12/20.
//  Copyright © 2020 Loyal Lauzier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject
+ (NSString *)openCVVersionString;
+ (UIImage *)blur:(UIImage *)image radius:(double)radius;
+ (UIImage *)blemish:(UIImage *)image bsize:(double)bsize x: (int)x y: (int)y w: (double)w h: (double)h;
@end
			
NS_ASSUME_NONNULL_END
