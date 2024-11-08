//
//  TZXDAlbumCategoryView.m
//  TZImagePickerController
//
//  Created by jmcl-Selice on 2024/11/8.
//  Copyright © 2024 谭真. All rights reserved.
//

#import "TZXDAlbumCategoryView.h"
#import "TZImagePickerController.h"
#import "UIView+TZLayout.h"
@interface TZXDAlbumCategoryView ()<UITableViewDataSource, UITableViewDelegate, PHPhotoLibraryChangeObserver> {
    UITableView *_tableView;
}

@end
@implementation TZXDAlbumCategoryView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self xd_initView];
        [self xd_initNoti];
        [self xd_initAction];
    }
    return self;
}

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    dispatch_async(dispatch_get_main_queue(), ^{
        //[self configTableView];
    });
}

-(void)xd_initView{
    if (@available(iOS 13.0, *)) {
        self.backgroundColor = UIColor.tertiarySystemBackgroundColor;
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
    
    self->_tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self->_tableView.rowHeight = 70;
    if (@available(iOS 13.0, *)) {
        self->_tableView.backgroundColor = [UIColor tertiarySystemBackgroundColor];
    } else {
        self->_tableView.backgroundColor = [UIColor whiteColor];
    }
    self->_tableView.tableFooterView = [[UIView alloc] init];
    self->_tableView.dataSource = self;
    self->_tableView.delegate = self;
    [self->_tableView registerClass:[TZAlbumCell class] forCellReuseIdentifier:@"TZAlbumCell"];
    [self addSubview:self->_tableView];
}

-(void)xd_initNoti{
    
}

-(void)xd_initAction{
    
}

-(void)setAlbumArr:(NSMutableArray *)albumArr{
    _albumArr = albumArr;
    [self configTableView];
}

- (void)configTableView{
    [self->_tableView reloadData];
}

#pragma mark - UITableViewDataSource && Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _albumArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TZAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TZAlbumCell"];
    if (@available(iOS 13.0, *)) {
        cell.backgroundColor = UIColor.tertiarySystemBackgroundColor;
    }
    TZImagePickerController *imagePickerVc = (TZImagePickerController *)self.navigationController;
    cell.albumCellDidLayoutSubviewsBlock = imagePickerVc.albumCellDidLayoutSubviewsBlock;
    cell.albumCellDidSetModelBlock = imagePickerVc.albumCellDidSetModelBlock;
    cell.selectedCountButton.backgroundColor = imagePickerVc.iconThemeColor;
    cell.model = _albumArr[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TZAlbumModel *model = _albumArr[indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.albumCellDidBackModelBlock) {
        self.albumCellDidBackModelBlock(model);
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    _tableView.frame = self.bounds;
}
@end
