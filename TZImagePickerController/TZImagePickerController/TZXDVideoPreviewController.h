//
//  TZXDVideoPreviewController.h
//  TZImagePickerController
//
//  Created by jmcl on 2023/6/1.
//  喜第V3.9视频预览页面


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class TZAssetModel;
@interface TZXDVideoPreviewController : UIViewController
///当前选择的视频源
@property (nonatomic, strong) TZAssetModel *model;

@end

NS_ASSUME_NONNULL_END
