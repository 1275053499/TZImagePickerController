//
//  TZPhotoPickerController.h
//  TZImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TZAlbumModel;
@interface TZPhotoPickerController : UIViewController

@property (nonatomic, assign) BOOL isFirstAppear;
@property (nonatomic, assign) NSInteger columnNumber;
@property (nonatomic, strong) TZAlbumModel *model;
///使用XD相册数据源
@property (nonatomic, strong) NSMutableArray *albumArr;
///使用XD相册标题按钮
@property (nonatomic, strong)UIButton * albumTitleView;
///使用XD相册自定义下拉条
@property(nonatomic, strong)UIImageView * rightSliderView;
///使用XD相册滑动手势
@property(nonatomic, strong) UIPanGestureRecognizer *sliderPanGes;

@end


@interface TZCollectionView : UICollectionView

@end
