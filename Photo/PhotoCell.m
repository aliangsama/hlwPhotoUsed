//
//  PhotoCell.m
//  hlwPhotoUsed
//
//  Created by hlw on 16/7/20.
//  Copyright © 2016年 hlw. All rights reserved.
//

#import "PhotoCell.h"
// 弱引用
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
@implementation PhotoCell
- (void)awakeFromNib {
    // Initialization code
    UITapGestureRecognizer* gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemClicked:)];
    [_imagePic setUserInteractionEnabled:YES];
    [_imagePic addGestureRecognizer:gr];
    
}

-(void)dealloc{
    if (_delegate) {
        _delegate=nil;
    }
    _asset=nil;
    [_imageSelect setImage:nil];
    [_imagePic setImage:nil];
    
}

-(void)setAsset:(PHAsset *)asset setIndex:(NSMutableOrderedSet*)setIndex{
    _asset=asset;
    _setIndex=setIndex;
    _labJd.text=@"";
    _labJd.hidden=YES;
    [_imageSelect setImage:nil];
    [_imagePic setImage:nil];
    PHImageRequestOptions *imageoptions = [[PHImageRequestOptions alloc] init];
    [imageoptions setResizeMode:PHImageRequestOptionsResizeModeFast];
    [imageoptions setDeliveryMode:PHImageRequestOptionsDeliveryModeFastFormat];
    [[PHImageManager defaultManager] requestImageForAsset:_asset targetSize:(CGSize){250,250} contentMode:PHImageContentModeAspectFit options:imageoptions resultHandler:^(UIImage * result, NSDictionary * info){
        if (result) {
            
            [_imagePic setImage:result];
            
        }
    }];
    
    if([_setIndex containsObject:_asset]) {
        [_imageSelect setImage:[UIImage imageNamed:@"photo_state_selected"]];
    }
    else {
        [_imageSelect setImage:[UIImage imageNamed:@"photo_state_normal"]];
    }
    if(_limit == 1) {
        [_imageSelect setHidden:YES];
    }
    else {
        [_imageSelect setHidden:NO];
    }
}

- (void)itemClicked:(UITapGestureRecognizer*)gr {
    _labJd.hidden=NO;
    if (_delegate&&_limit == 1) {
        [_delegate shuaxin:_asset];
    }
    //选择图片，icloud中的话下载
    @autoreleasepool {
    PHImageRequestOptions *imageoptions = [[PHImageRequestOptions alloc] init];
    imageoptions.synchronous=NO;
    imageoptions.networkAccessAllowed=YES;
    [imageoptions setResizeMode:PHImageRequestOptionsResizeModeFast];
    [imageoptions setDeliveryMode:PHImageRequestOptionsDeliveryModeFastFormat];
        WS(weakSelf);
    [imageoptions setProgressHandler:^(double progress, NSError *__nullable error, BOOL *stop, NSDictionary *__nullable info){
        dispatch_async(dispatch_get_main_queue(),(^{
            if(error){
                weakSelf.labJd.hidden=YES;
            }
            weakSelf.labJd.text=[NSString stringWithFormat:@"%0.0f%%",progress*100];
        }));
        
    }];
    [[PHImageManager defaultManager] requestImageForAsset:_asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:imageoptions resultHandler:^(UIImage * result, NSDictionary * info){
        @autoreleasepool {
        weakSelf.labJd.hidden=YES;
        if (result) {
            if (weakSelf.delegate) {
                [weakSelf.delegate onSelect:_asset image:result];
            }
        }
        }
    }];
    }
}

-(void)layoutSubviews{
    CGFloat wh=(SCREEN_WIDTH-9)/4;
    CGRect frame=[self frame];
    frame.size.width=wh;
    frame.size.height=wh;
    self.frame=frame;
    frame=[_imagePic frame];
    frame.size.width=wh;
    frame.size.height=wh;
    _imagePic.frame=frame;
    frame=[_labJd frame];
    frame.size.width=wh;
    frame.size.height=wh;
    _labJd.frame=frame;
    frame=[_imageSelect frame];
    frame.origin.x=wh-frame.size.width-8;
    frame.origin.y=wh-frame.size.height-8;
    _imageSelect.frame=frame;
}
@end
