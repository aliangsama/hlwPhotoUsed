//
//  Utils.h
//  hlwPhotoUsed
//
//  Created by 黄黎雯 on 2016/10/21.
//  Copyright © 2016年 hlw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ChoosePhotoViewController.h"

#define STATUS_BAR_HEIGHT ([[UIApplication sharedApplication] statusBarFrame].size.height)
//导航栏状态栏高度
#define TITLE_HEIGHT_WITH_BAR (STATUS_BAR_HEIGHT+44)

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
//获取RGB实现
#define RGBA(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define HexRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define TINTCOLOR HexRGB(0x252525)
#define BACKGOUND_COLOR RGBA(248, 248, 248, 1.0)
@interface Utils : NSObject
+ (UIImage*) imageWithColor:(UIColor*) color Size:(CGSize) size;
//压缩图片，尺寸默认屏幕尺寸
+ (UIImage*)ZIPUIImage:(UIImage*)image;

//旋转图片
+ (UIImage *)fixOrientation:(UIImage *)aImage;

// 从相册获取图片
+ (void)pickPhotosLimit:(NSInteger)limit Orignal:(BOOL)orignal ChooseDelegate:(id<ChoosePhotoDelegate>)delegate ViewController:(UIViewController*)controller;

// 从相机获取图片
+ (void)takePhoto:(UIViewController *)controller TakeDelegate:(id<UINavigationControllerDelegate,UIImagePickerControllerDelegate>)takeDelegate;
@end
