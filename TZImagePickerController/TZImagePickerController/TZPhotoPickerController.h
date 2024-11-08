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

@end


@interface TZCollectionView : UICollectionView

@end
