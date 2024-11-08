//
//  TZXDAlbumCategoryView.h
//  TZImagePickerController
//
//  Created by jmcl-Selice on 2024/11/8.
//  Copyright © 2024 谭真. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TZAssetCell.h"
#import "TZImageManager.h"
NS_ASSUME_NONNULL_BEGIN

@class TZAlbumCell, TZAssetCell;

@interface TZXDAlbumCategoryView : UIView
///使用XD相册数据源
@property (nonatomic, strong) NSMutableArray *albumArr;
///使用XD相册数据源
@property (nonatomic, strong)UINavigationController *navigationController;
///使用XD相册选择回调
@property (nonatomic, copy) void (^albumCellDidBackModelBlock)(TZAlbumModel *model);

@end

NS_ASSUME_NONNULL_END
