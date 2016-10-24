//
//  ChoosePhotoViewController.m
//  hlwPhotoUsed
//
//  Created by hlw on 16/7/20.
//  Copyright © 2016年 hlw. All rights reserved.
//

#import "ChoosePhotoViewController.h"
#import "ChoosePhotoBottom.h"
#import "PhotoCell.h"
#import "Utils.h"
#import "MBProgressHUD+Add.h"

#define ADD_TAG 10000
#define IMAGE_WIDTH 35
@interface ChoosePhotoViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,PhotoCelldelegate>{
    NSInteger lastIndex;
}
@property(nonatomic,strong)NSMutableArray*dataImage;

@end

@implementation ChoosePhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupBack];
    
    setIndex = [[NSMutableOrderedSet alloc] init];
    setRow = [[NSMutableOrderedSet alloc] init];
    _dataImage=[NSMutableArray array];
    //加载图片资源
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
    
    photoList = [PHAsset fetchAssetsInAssetCollection:_assetsGroup options:options];
    
    if(_limit != 1) {
        //选择多张的情况
        NSArray* array = [[NSBundle mainBundle] loadNibNamed:@"ChoosePhotoBottom" owner:nil options:nil];
        addView = [array objectAtIndex:0];
        addView.frame = CGRectMake(0, 0, self.navigationController.toolbar.frame.size.width, self.navigationController.toolbar.frame.size.height);
        [addView.bottomButton addTarget:self action:@selector(doneClicked) forControlEvents:UIControlEventTouchDown];
        UIImage* imageNor = [Utils imageWithColor:[UIColor whiteColor] Size:addView.bottomButton.frame.size];
        UIImage* imageSel = [Utils imageWithColor:[UIColor grayColor] Size:addView.bottomButton.frame.size];
        [addView.bottomButton setBackgroundImage:imageNor forState:UIControlStateNormal];
        [addView.bottomButton setBackgroundImage:imageSel forState:UIControlStateHighlighted];
        [addView.bottomButton setTintColor:TINTCOLOR];
        addView.bottomButton.layer.cornerRadius = 6;
        addView.bottomButton.layer.masksToBounds = YES;
        [addView setBackgroundColor:[UIColor clearColor]];
        [[self.navigationController toolbar] setBackgroundImage:[Utils imageWithColor:TINTCOLOR Size:[self.navigationController toolbar].frame.size] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        
        [[self.navigationController toolbar] addSubview:addView];
    }
    self.collectionView.delegate=self;
    self.collectionView.dataSource=self;
    self.collectionView.backgroundColor=BACKGOUND_COLOR;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(_limit != 1) {
        [self.navigationController setToolbarHidden:NO animated:NO];
    }
    //[self scrollToBottom];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if(_limit != 1) {
        [self.navigationController setToolbarHidden:YES animated:NO];
    }
    
}

-(void)dealloc{
    if(_delegate!=nil){
        _delegate=nil;
    }
    self.assetsGroup=nil;
    photoList=nil;
    setIndex=nil;
    setRow=nil;
    self.dataImage=nil;
    if(addView != nil) {
        [addView removeFromSuperview];
    }
}

#pragma mark - 重载popbydrag
- (void)popByDrag {
    if(addView != nil) {
        [addView removeFromSuperview];
    }
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return photoList.count;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    PhotoCell *cell = (PhotoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"photoCell" forIndexPath:indexPath];
    PHAsset *asset = [photoList objectAtIndex:row];
    cell.delegate=self;
    cell.limit=_limit;
    [cell setAsset:asset setIndex:setIndex];
    return cell;
}

//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat wh=(SCREEN_WIDTH-30)/4;
    return CGSizeMake(wh, wh);
}

// 设置最小行间距，也就是前一行与后一行的中间最小间隔
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 8;
}

-(void)shuaxin:(PHAsset *)asset{
    [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:lastIndex inSection:0], nil]];
    lastIndex =[photoList indexOfObject:asset];
}

-(void)onSelect:(PHAsset *)asset image:(UIImage *)img{
    @autoreleasepool {
    NSInteger item =[photoList indexOfObject:asset];
    lastIndex=item;
    if([setIndex containsObject:asset]) {
        //多张图片时底部显示图片改变
        UIImageView* imageview = (UIImageView*)[addView.bottomScrollview viewWithTag:item+ADD_TAG];
        [imageview removeFromSuperview];
        NSInteger index = [setIndex indexOfObject:asset];
        [setIndex removeObject:asset];
        [setRow removeObject:@(item+ADD_TAG)];
        [_dataImage removeObject:img];
        for(int i = index; i < [setIndex count]; i ++) {
            NSInteger newItem = [[setRow objectAtIndex:i] intValue];
            UIImageView* imageNext = (UIImageView*)[addView.bottomScrollview viewWithTag:newItem];
            imageNext.frame = CGRectMake(imageNext.frame.origin.x-IMAGE_WIDTH+5, imageNext.frame.origin.y, imageNext.frame.size.width, imageNext.frame.size.height);
        }
    }
    else {
        if(_limit != 0 && [setIndex count] >= _limit) {
            [MBProgressHUD showMessageAutoHide:[NSString stringWithFormat:@"最多选择%ld张照片", _limit] toView:nil];
        }
        else {
            if(_limit != 1) {
                UIImageView* imageview = [[UIImageView alloc] init];
                imageview.frame = CGRectMake([setIndex count]*(IMAGE_WIDTH+5)+5, (44-IMAGE_WIDTH)/2.0, IMAGE_WIDTH, IMAGE_WIDTH);
                imageview.tag = item+ADD_TAG;
                [imageview setImage:img];

                [addView.bottomScrollview addSubview:imageview];
            }
            [_dataImage addObject:img];
            [setIndex addObject:asset];
            [setRow addObject:@(item+ADD_TAG)];
        }
    }
    if(_limit != 1) {
        addView.bottomScrollview.contentSize = CGSizeMake((IMAGE_WIDTH+5)*[setIndex count], addView.bottomScrollview.frame.size.height);
        if(addView.bottomScrollview.contentSize.width < addView.bottomScrollview.frame.size.width) {
            addView.bottomScrollview.contentOffset = CGPointMake(0, 0);
        }
        else {
            addView.bottomScrollview.contentOffset = CGPointMake(addView.bottomScrollview.contentSize.width-addView.bottomScrollview.frame.size.width, 0);
        }
    }
    [self.navigationItem setTitle:[NSString stringWithFormat:@"选择照片(%ld)", [setIndex count]]];

    [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:item inSection:0], nil]];
    if(_limit == 1 && [setIndex count] == 1) {
        [self doneClicked];
    }
    }
}

//完成图片选择
- (void)doneClicked {
    if([_dataImage count] == 0) {
        [MBProgressHUD showMessageAutoHide:@"请选择照片" toView:nil];
        return ;
    }
    [MBProgressHUD showMessage:@"正在处理图片，请稍等" toView:nil];
     @autoreleasepool {
    for(int i = 0; i < [_dataImage count]; i ++) {
       
            @try {
                NSMutableArray* data = [[NSMutableArray alloc] init];
                UIImage * result = [_dataImage objectAtIndex:i];
                
                if (result) {
                    if(_orignal) {
                        [data addObject:result];
                    }
                    else {
                        //压缩图片
                        UIImage* scaleImage = [Utils ZIPUIImage:result];
                        [data addObject:scaleImage];
                    }
                    
                    [MBProgressHUD hideAllHUDsForView:nil animated:NO];
                    if(_delegate != nil && [_delegate respondsToSelector:@selector(choosePhotos:)]) {
                        [_delegate choosePhotos:data];
                    }
                    if (i==[setIndex count]-1) {
                        
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                }
                
                
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
        }
    }
    
}

#pragma mark - 滚动到底部
- (void)scrollToBottom {
    if(photoList != nil && [photoList count] > 0) {
        CGFloat y = self.collectionView.contentSize.height + 44;
        if(y > 0) {
            self.collectionView.contentOffset = CGPointMake(0, y);
        }
    }
}

@end
