//
//  ChoosePhotoViewController.m
//  hlwPhotoUsed
//
//  Created by hlw on 16/7/20.
//  Copyright © 2016年 hlw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoListViewController.h"
#import "ChoosePhotoBottom.h"
#import "hlwBaseViewController.h"
@import Photos;
@protocol ChoosePhotoDelegate;
@interface ChoosePhotoViewController : hlwBaseViewController{
    PHFetchResult * photoList;
    NSMutableOrderedSet* setIndex;
    NSMutableOrderedSet* setRow;
    ChoosePhotoBottom* addView;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

//跳转参数
@property (nonatomic, weak) PHAssetCollection *assetsGroup;
@property (nonatomic, assign) NSInteger limit;//旋转图片数量
@property (nonatomic, assign) BOOL orignal;
@property (nonatomic, weak) id<ChoosePhotoDelegate> delegate;
@end
