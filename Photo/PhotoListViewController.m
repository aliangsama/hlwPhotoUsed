//
//  PhotoListViewController.m
//  hlwPhotoUsed
//
//  Created by hlw on 16/7/20.
//  Copyright © 2016年 hlw. All rights reserved.
//

#import "PhotoListViewController.h"
#define RGBA(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
@interface PhotoListViewController ()

@end

@implementation PhotoListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc{
    if (self.delegate) {
        self.delegate=nil;
    }
    self.albumList=nil;
    self.assetCollection=nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = RGBA(52, 52, 52, 1);
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setupBack];
    
    _filterType = QBImagePickerFilterTypeAllPhotos;
    
    _albumList = [[NSMutableArray alloc] init];
 
    PHAssetCollectionSubtype smartAlbumSubtype = PHAssetCollectionSubtypeSmartAlbumUserLibrary | PHAssetCollectionSubtypeSmartAlbumScreenshots | PHAssetCollectionSubtypeSmartAlbumVideos;
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:smartAlbumSubtype options:nil];
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
    for (NSInteger i=0; i<smartAlbums.count; i++) {
        // 获取一个相册PHAssetCollection
        @autoreleasepool {
        PHCollection *collection = smartAlbums[i];
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
            if (fetchResult.count>0) {
                [_albumList addObject:collection];
            }
            
        }else {
            NSAssert(NO, @"Fetch collection not PHCollection: %@", collection);
        }
        }
        
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:NO];
}

#pragma mark - 重载返回按钮
// 返回
- (void) setupBack {
    UIButton* back = [UIButton buttonWithType:UIButtonTypeCustom];
    back.frame = CGRectMake(0, 0, 50, 20);
    [back setTitle:@"返回" forState:UIControlStateNormal];
    back.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [back setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    // [back setImage:[UIImage imageNamed:@"back_highlight"] forState:UIControlStateHighlighted];
    [back setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    // [back setTitleEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
    [back addTarget:self action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc] initWithCustomView:back];
    self.navigationItem.leftBarButtonItem = rightItem;
}

#pragma mark - 重载onback
- (void)onBack {
    UIViewController * controller=[self.navigationController.viewControllers objectAtIndex:0];
    if(controller == self) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Table view data source

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSLog(@"%ld", [_albumList count]);
    return [_albumList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    NSString *CellIdentifier = @"PhotoListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    UIImageView* imageview = (UIImageView*)[cell viewWithTag:1];
    [imageview setContentMode:UIViewContentModeScaleAspectFill];
    UILabel* titleLabel = (UILabel*)[cell viewWithTag:2];
    PHCollection *collection = [_albumList objectAtIndex:row];
    PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
    PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
    imageview.layer.cornerRadius = 4;
    imageview.layer.masksToBounds = YES;
    PHAsset *asset = nil;
    asset = fetchResult[0];
    PHImageRequestOptions *imageoptions = [[PHImageRequestOptions alloc] init];
    imageoptions.synchronous=YES;
    [imageoptions setResizeMode:PHImageRequestOptionsResizeModeFast];
    [imageoptions setDeliveryMode:PHImageRequestOptionsDeliveryModeFastFormat];
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:(CGSize){250,250} contentMode:PHImageContentModeAspectFit options:imageoptions resultHandler:^(UIImage * result, NSDictionary * info){
        if (result) {
            [imageview setImage:result];
        }
    }];
    NSLog(@"assetsGroup:%@",asset.creationDate);
    
    titleLabel.text = [NSString stringWithFormat:@"%@(%ld)", [self transformAblumTitle:collection.localizedTitle], fetchResult.count];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _assetCollection = [_albumList objectAtIndex:row];
    [self performSegueWithIdentifier:@"ChoosePhotoSeg" sender:self];
}

- (NSString *)transformAblumTitle:(NSString *)title
{
    if ([title isEqualToString:@"Slo-mo"]) {
        return @"慢动作";
    } else if ([title isEqualToString:@"Recently Added"]) {
        return @"最近添加";
    } else if ([title isEqualToString:@"Favorites"]) {
        return @"最爱";
    } else if ([title isEqualToString:@"Recently Deleted"]) {
        return @"最近删除";
    } else if ([title isEqualToString:@"Videos"]) {
        return @"视频";
    } else if ([title isEqualToString:@"All Photos"]) {
        return @"所有照片";
    } else if ([title isEqualToString:@"Selfies"]) {
        return @"自拍";
    } else if ([title isEqualToString:@"Screenshots"]) {
        return @"屏幕快照";
    } else if ([title isEqualToString:@"Camera Roll"]) {
        return @"相机胶卷";
    }else{
        return title;
    }
    return nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    @autoreleasepool {
    if([segue.identifier isEqualToString:@"ChoosePhotoSeg"]) {
        ChoosePhotoViewController* controller = (ChoosePhotoViewController*)segue.destinationViewController;
        controller.assetsGroup = _assetCollection;
        controller.limit = _limit;
        controller.orignal = _orignal;
        controller.delegate = _delegate;
    }
    }
}


@end
