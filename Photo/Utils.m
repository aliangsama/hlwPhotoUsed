//
//  Utils.m
//  hlwPhotoUsed
//
//  Created by 黄黎雯 on 2016/10/21.
//  Copyright © 2016年 hlw. All rights reserved.
//

#import "Utils.h"
#import "PhotoListViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
@implementation Utils
+ (UIImage *)imageWithColor:(UIColor *)color Size:(CGSize) size {
    @autoreleasepool {
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        UIGraphicsBeginImageContextWithOptions(size, 0, [UIScreen mainScreen].scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [color CGColor]);
        CGContextFillRect(context, rect);
        UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
}

+ (void)pickPhotosLimit:(NSInteger)limit Orignal:(BOOL)orignal ChooseDelegate:(id<ChoosePhotoDelegate>)delegate ViewController:(UIViewController*)controller {
    
    UIStoryboard* story = [UIStoryboard storyboardWithName:@"photo" bundle:nil];
    UINavigationController* nav = [story instantiateViewControllerWithIdentifier:@"ChoosePhotoNav"];
    PhotoListViewController* listController = [nav.viewControllers objectAtIndex:0];
    listController.orignal = orignal;
    listController.delegate = delegate;
    listController.limit = limit;
    nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [controller presentViewController:nav animated:YES completion:nil];
    
}

+ (void)takePhoto:(UIViewController *)controller TakeDelegate:(id<UINavigationControllerDelegate,UIImagePickerControllerDelegate>)takeDelegate {

    BOOL authed = YES;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
    if(!([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusAuthorized)) {
        authed =  NO;
    }
#endif
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = takeDelegate;
    //设置拍照后的图片不可被编辑，因为使用自己的剪裁
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [controller presentViewController:picker animated:YES completion:nil];
}

//跳转图片旋转
+ (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

//最大公约数
+ (int)gcda:(int)a b:(int)b {
    int r;
    while(b != 0) {
        r = a % b;
        a = b;
        b = r;
    }
    if(a <= 0) {
        return 1;
    }
    return a;
}

//缩放尺寸到size
+ (UIImage*)scaleImage:(UIImage*)image toSize:(CGSize) size {
    UIImage *finalImage = [Utils fixOrientation:image];
    CGImageRef imgRef = [finalImage CGImage];
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    if(width <= size.width || height <= size.height) {
        return finalImage;
    }
    
    int r = [Utils gcda:width b:height];
    int width1 = width / r;
    int height1 = height / r;
    
    float vRadio = size.height*1.0/height1;
    float hRadio = size.width*1.0/width1;
    float radio = 1;
    if(vRadio>1 && hRadio>1) {
        radio = hRadio > vRadio ? vRadio : hRadio;
        radio = ceil(radio);
    }
    
    width = width1*radio;
    height = height1*radio;
    
    CGSize newSize = CGSizeMake(width, height);
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, width, height)];
    
    UIImage* scaleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaleImage;
}


//压缩图片，尺寸默认屏幕尺寸
+ (UIImage*)ZIPUIImage:(UIImage*)image {
    CGSize size = [[UIScreen mainScreen] bounds].size;
    return [Utils ZIPUIImage:image size:size];
}

//压缩图片，尺寸为size
+ (UIImage*)ZIPUIImage:(UIImage*)image size:(CGSize)size {
    NSData* data = [Utils ZIPUIImageBackData:image size:size];
    return [UIImage imageWithData:data];
}

//压缩图片，返回nsdata
+ (NSData*)ZIPUIImageBackData:(UIImage*)image size:(CGSize)size {
    UIImage* scaleImage = [self scaleImage:image toSize:CGSizeMake(size.width, size.height)];
    return [Utils ZIPImageSize:scaleImage];
}

//质量压缩图片
+ (NSData*)ZIPImageSize:(UIImage*)image {
    CGFloat rate = 0.7;
    NSData* data = UIImageJPEGRepresentation(image, rate);
    while([data length] > 184320 && rate > 0.05) {
        rate -= 0.1;
        data = UIImageJPEGRepresentation(image, rate);
    }
    return data;
}

//对于一个图片进行中间剪裁
+ (UIImage*)imageWithCenterCrop:(UIImage *)src targetSize:(CGSize)targetSize {
    
    CGFloat width = CGImageGetWidth(src.CGImage);
    CGFloat height = CGImageGetHeight(src.CGImage);
    
    CGRect rect;
    if(width * targetSize.height > height * targetSize.width) {
        rect = CGRectMake((CGImageGetWidth(src.CGImage) - (targetSize.width/targetSize.height) * height) / 2, 0, width, height);
    }
    else {
        rect = CGRectMake(0, (CGImageGetHeight(src.CGImage) - (targetSize.height/targetSize.width) * width) / 2, width, height);
    }
    
    CGImageRef subImageRef = CGImageCreateWithImageInRect(src.CGImage, rect);
    
    CGRect smallBounds = CGRectMake(0, 0, targetSize.width, targetSize.height);
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    CGImageRelease(subImageRef);
    UIGraphicsEndImageContext();
    return smallImage;
}
@end
