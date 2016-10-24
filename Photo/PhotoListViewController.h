//
//  PhotoListViewController.h
//  hlwPhotoUsed
//
//  Created by hlw on 16/7/20.
//  Copyright © 2016年 hlw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChoosePhotoViewController.h"
@import Photos;
typedef enum {
    QBImagePickerFilterTypeAllAssets,
    QBImagePickerFilterTypeAllPhotos,
    QBImagePickerFilterTypeAllVideos
} QBImagePickerFilterType;

@protocol ChoosePhotoDelegate <NSObject>

@required
- (void)choosePhotos:(NSArray*)data;
- (void)chooseCancel;

@end

@interface PhotoListViewController : UITableViewController

//跳转参数
@property (nonatomic, assign) NSInteger limit;
@property (nonatomic, assign) BOOL orignal;
@property (nonatomic, weak) id<ChoosePhotoDelegate> delegate;

@property (nonatomic, assign) QBImagePickerFilterType filterType;
@property (nonatomic, strong) NSMutableArray* albumList;
@property (nonatomic, strong) PHAssetCollection *assetCollection;

@end
