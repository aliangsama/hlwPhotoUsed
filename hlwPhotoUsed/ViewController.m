//
//  ViewController.m
//  hlwPhotoUsed
//
//  Created by hlw on 2016/10/11.
//  Copyright © 2016年 hlw. All rights reserved.
//

#import "ViewController.h"
#import "Utils.h"
#import "VPImageCropperViewController.h"
#import "PhotoListViewController.h"
#import "MBProgressHUD+Add.h"
#define picW 90
#define picJJ 10
typedef NS_ENUM(NSInteger, picType)
{
    Pic_danz = 0x1,
    Pic_duoz,
    Pic_toux,
};

@interface ViewController ()<UINavigationControllerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,ChoosePhotoDelegate,VPImageCropperDelegate>{
    UIView*picView;
    UIButton*danzBtn,*duozBtn,*touXbtn;
    int maxPic;
    CGFloat picX,picY;
}
@property(nonatomic,assign)picType type;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIImage * image = [Utils imageWithColor:TINTCOLOR Size:CGSizeMake(SCREEN_WIDTH, 64)];
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    UILabel *titleView = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2.0-30, 0, 60, 40)];
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.text = @"选择图片";
    titleView.font = [UIFont boldSystemFontOfSize:17];
    titleView.textColor = [UIColor whiteColor];
    [self.navigationItem setTitleView:titleView];
    
    maxPic=3;
    picX=0;
    picY=0;
    
    picView=[[UIView alloc] initWithFrame:CGRectMake(15, 80, SCREEN_WIDTH-30, 300)];
    [self.view addSubview:picView];
    
    danzBtn=[[UIButton alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(picView.frame)+30, (SCREEN_WIDTH-60)/3, 40)];
    [danzBtn setTitle:@"选择单张" forState:UIControlStateNormal];
    [danzBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    danzBtn.layer.borderWidth=1;
    danzBtn.layer.borderColor=[[UIColor blackColor] CGColor];
    [danzBtn addTarget:self action:@selector(onDanzClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:danzBtn];
    
    duozBtn=[[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(danzBtn.frame)+15, CGRectGetMaxY(picView.frame)+30, (SCREEN_WIDTH-60)/3, 40)];
    [duozBtn setTitle:@"选择多张" forState:UIControlStateNormal];
    [duozBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    duozBtn.layer.borderWidth=1;
    duozBtn.layer.borderColor=[[UIColor blackColor] CGColor];
    [duozBtn addTarget:self action:@selector(onDuozClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:duozBtn];
    
    touXbtn=[[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(duozBtn.frame)+15, CGRectGetMaxY(picView.frame)+30, (SCREEN_WIDTH-60)/3, 40)];
    [touXbtn setTitle:@"选择头像" forState:UIControlStateNormal];
    [touXbtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    touXbtn.layer.borderWidth=1;
    touXbtn.layer.borderColor=[[UIColor blackColor] CGColor];
    [touXbtn addTarget:self action:@selector(onTouxClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:touXbtn];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//选择图片后显示
-(void)setupPic:(UIImage*)image{
    UIImageView*imageView=[[UIImageView alloc] initWithFrame:CGRectMake(picX, picY, picW, picW)];
    [imageView setImage:image];
    [picView addSubview:imageView];
    picX=CGRectGetMaxX(imageView.frame)+picJJ;
    if (picX>picView.frame.size.width) {
        picY=CGRectGetMaxY(imageView.frame)+picJJ;
        picX=0;
    }
}

-(void)onDanzClick{
    self.type=Pic_danz;
    [self showAlert];
}

-(void)onDuozClick{
    self.type=Pic_duoz;
    [self showAlert];
}

-(void)onTouxClick{
    self.type=Pic_toux;
    [self showAlert];
}

-(void)showAlert{
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册获取", nil];
    actionSheet.tag = 1;
    [actionSheet showInView:self.view];
}

#pragma mark 图片处理
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(actionSheet.tag == 1) {
        if(buttonIndex == 0) {
            [Utils takePhoto:self TakeDelegate:self];
        }
        else if(buttonIndex == 1) {
            if (_type==Pic_duoz) {
                [Utils pickPhotosLimit:maxPic Orignal:NO ChooseDelegate:self ViewController:self];
            }else{
                [Utils pickPhotosLimit:1 Orignal:NO ChooseDelegate:self ViewController:self];
            }
        }
    }
}

//当相机选择一张图片后进入这里
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    //当选择的类型是图片
    if ([mediaType isEqualToString:@"public.image"]) {
        //关闭相册界面
        [picker dismissViewControllerAnimated:YES completion:nil];
        UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        image = [Utils fixOrientation:image];
        if(_type==Pic_toux){
            VPImageCropperViewController *imgEditorVC = [[VPImageCropperViewController alloc] initWithImage:image limitScaleRatio:3.0];
            imgEditorVC.delegate = self;
            [self.navigationController pushViewController:imgEditorVC animated:YES];
        }else{
            [self setupPic:image];
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo NS_DEPRECATED_IOS(2_0, 3_0) {
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ChoosePhotoDelegate
- (void)choosePhotos:(NSArray*)data {
    if (data.count != 1) {
        return;
    }
    UIImage* image = [data objectAtIndex:0];
    if (_type==Pic_toux) {
        VPImageCropperViewController *imgEditorVC = [[VPImageCropperViewController alloc] initWithImage:image limitScaleRatio:3.0];
        imgEditorVC.delegate = self;
        UINavigationController*nav=[[UINavigationController alloc] initWithRootViewController:imgEditorVC];
        [self.navigationController pushViewController:imgEditorVC animated:YES];
        image=nil;
    }else{
        [self setupPic:image];
    }
    
    
}
- (void)chooseCancel {
    
}

- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    UIImage* image = [Utils ZIPUIImage:editedImage];
    if (image) {
        [self setupPic:image];
    } else {
        [MBProgressHUD showError:@"获取头像失败" toView:nil];
    }
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    
}

@end
