//
//  VPImageCropperViewController.h
//  VPolor
//
//  Created by Vinson.D.Warm on 12/30/13.
//  Copyright (c) 2013 Huang Vinson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "hlwBaseViewController.h"
@class VPImageCropperViewController;

@protocol VPImageCropperDelegate <NSObject>

- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage;
- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController;

@end

@interface VPImageCropperViewController : hlwBaseViewController

@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, weak) id<VPImageCropperDelegate> delegate;
@property (nonatomic, assign) CGRect cropFrame;

- (id)initWithImage:(UIImage *)originalImage limitScaleRatio:(NSInteger)limit;
- (id)initWithImage:(UIImage *)originalImage limitScaleRatio:(NSInteger)limit jiancai:(CGFloat)jc;

@end
