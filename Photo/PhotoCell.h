//
//  PhotoCell.h
//  hlwPhotoUsed
//
//  Created by hlw on 16/7/20.
//  Copyright © 2016年 hlw. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Photos;
@protocol PhotoCelldelegate <NSObject>

-(void)onSelect:(PHAsset*)asset image:(UIImage*)img;
-(void)shuaxin:(PHAsset*)asset;
@end
@interface PhotoCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imagePic;
@property (weak, nonatomic) IBOutlet UIImageView *imageSelect;
@property (weak, nonatomic) IBOutlet UILabel *labJd;

@property (weak, nonatomic) id<PhotoCelldelegate> delegate;

@property(nonatomic,strong)PHAsset *asset;
@property(nonatomic,strong)NSMutableOrderedSet* setIndex;
@property (nonatomic, assign) NSInteger limit;
-(void)setAsset:(PHAsset *)asset setIndex:(NSMutableOrderedSet*)setIndex;
@end
