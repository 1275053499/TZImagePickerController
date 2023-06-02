//
//  TZXDVideoGetCoverController.h
//  TZImagePickerController
//
//  Created by jmcl on 2023/6/1.
//  喜第V3.9视频预览页面-----获取选择封面

#import <UIKit/UIKit.h>

@class TZAssetModel,TZImagePickerController;
NS_ASSUME_NONNULL_BEGIN

@interface TZXDVideoGetCoverController : UIViewController<UIViewControllerTransitioningDelegate>
///当前选择的视频源
@property (nonatomic, strong) TZAssetModel *model;
///TZ导航栏
@property (nonatomic, weak  ) TZImagePickerController *imagePickerVc;
///是否选择用高清
@property (nonatomic, assign) BOOL  previewQuality;

@end

@interface TZXDCoverVideoPictureCell : UICollectionViewCell
///显示小封面
@property (strong, nonatomic) UIImageView *imgView;
///马赛克模糊图
@property (strong, nonatomic) UIView * coverView;


@end

NS_ASSUME_NONNULL_END
