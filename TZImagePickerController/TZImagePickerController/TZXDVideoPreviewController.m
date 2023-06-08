//
//  TZXDVideoPreviewController.m
//  TZImagePickerController
//
//  Created by jmcl on 2023/6/1.
//

#import "TZXDVideoPreviewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UIView+TZLayout.h"
#import "TZImageManager.h"
#import "TZAssetModel.h"
#import "TZImagePickerController.h"
#import "TZXDVideoGetCoverController.h"
@interface TZXDVideoPreviewController (){
    ///播放器
    AVPlayer *_player;
    ///播放器
    AVPlayerLayer *_playerLayer;
    ///播放｜暂停
    UIButton *_playButton;
}

// iCloud无法同步提示UI
@property (nonatomic, strong) UIView *iCloudErrorView;
// 视频预览底部工具栏
@property (nonatomic, strong) UIView * previewBarView;
// 视频预览底部工具栏 返回按钮
@property (nonatomic, strong) UIButton * previewBackBtn;
// 视频预览底部工具栏 选择封面按钮
@property (nonatomic, strong) UIButton * previewGetCoverBtn;

// 视频预览底部工具栏 选择高清底图
@property (nonatomic, strong) UIView * previewQualityView;
// 视频预览底部工具栏 选择高清按钮
@property (nonatomic, strong) UIButton * previewQualityBtn;
// 视频预览底部工具栏 选择高清提示
@property (nonatomic, strong) UILabel * previewQualityLabel;
// 视频预览底部工具栏 选择高清
@property (nonatomic, assign) BOOL  previewQuality;

@end

@implementation TZXDVideoPreviewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:16/255 green:16/255 blue:16/255 alpha:1];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pausePlayer) name:UIApplicationWillResignActiveNotification object:nil];
    [self configMoviePlayer];
    [self configBottomBar];
}

/*
 * 处理视频进行播放
 * @author selice
 * @date 2023.06.01
 */
-(void)configMoviePlayer{
    NSLog(@"视频预览的新界面～～添加视频播放器～～");
    [[TZImageManager manager] getVideoWithAsset:_model.asset completion:^(AVPlayerItem *playerItem, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_player            = [AVPlayer playerWithPlayerItem:playerItem];
            self->_playerLayer       = [AVPlayerLayer playerLayerWithPlayer:self->_player];
            CGFloat toolBarHeight = ([TZCommonTools tz_safeAreaInsets].bottom > 0) ? ([TZCommonTools tz_safeAreaInsets].bottom  + 17 + 17 + 41): 17 + 17 + 41;
            self->_playerLayer.frame = CGRectMake(0, 0, self.view.tz_width, self.view.tz_height-toolBarHeight);
            [self.view.layer addSublayer:self->_playerLayer];
            [self configPlayButton];
            [self playPlayer];
            [self configVideoQuality];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playPlayer) name:AVPlayerItemDidPlayToEndTimeNotification object:self->_player.currentItem];
        });
    }];
}

/*
 * 创建底部工具栏
 * @author selice
 * @date 2023.06.01
 */
-(void)configBottomBar{
    
    _previewBarView = [[UIView alloc]initWithFrame:CGRectZero];
    CGFloat rgb     = 16 / 255.0;
    _previewBarView.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1];
    [self.view addSubview:_previewBarView];
    
    _previewBackBtn   = [UIButton buttonWithType:UIButtonTypeCustom];
    [_previewBackBtn setImage:[UIImage tz_imageNamedFromMyBundle:@"btn_preview_back"] forState:UIControlStateNormal];
    [_previewBackBtn setImage:[UIImage tz_imageNamedFromMyBundle:@"btn_preview_back"] forState:UIControlStateHighlighted];
    [_previewBackBtn addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_previewBarView addSubview:_previewBackBtn];
    
    _previewGetCoverBtn   = [UIButton buttonWithType:UIButtonTypeCustom];
    [_previewGetCoverBtn setImage:[UIImage tz_imageNamedFromMyBundle:@"btn_preview_next"] forState:UIControlStateNormal];
    [_previewGetCoverBtn setImage:[UIImage tz_imageNamedFromMyBundle:@"btn_preview_next"] forState:UIControlStateHighlighted];
    [_previewGetCoverBtn setTitle:@"封面选择" forState:UIControlStateNormal];
    [_previewGetCoverBtn setTitle:@"封面选择" forState:UIControlStateHighlighted];
    [_previewGetCoverBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_previewGetCoverBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_previewGetCoverBtn addTarget:self action:@selector(nextButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _previewGetCoverBtn.backgroundColor = [UIColor colorWithRed:42/255.0 green:215/255.0 blue:255/255.0 alpha:1];
    _previewGetCoverBtn.layer.cornerRadius = 12;
    _previewGetCoverBtn.clipsToBounds = YES;
    _previewGetCoverBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [_previewBarView addSubview:_previewGetCoverBtn];

    NSLog(@"视频预览的新界面～～添加工具栏～～");
}

/*
 * 创建高清提示UI
 * @author selice
 * @date 2023.06.01
 */
-(void)configVideoQuality{
    
    _previewQualityView                 = [[UIView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:_previewQualityView];
    _previewQualityView.backgroundColor = UIColor.clearColor;
    
    _previewQualityBtn                    = [[UIButton alloc]initWithFrame:CGRectZero];
    _previewQualityBtn.layer.cornerRadius = 5;
    _previewQualityBtn.clipsToBounds      = YES;
    _previewQualityBtn.layer.borderWidth  = 1.5;
    _previewQualityBtn.backgroundColor    = [UIColor colorWithWhite:1 alpha:0.0];
    _previewQualityBtn.layer.borderColor  = [UIColor colorWithWhite:1 alpha:0.7].CGColor;
    [_previewQualityBtn addTarget:self action:@selector(qualityButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_previewQualityView addSubview:_previewQualityBtn];
    
    _previewQualityLabel               = [[UILabel alloc]init];
    _previewQualityLabel.text          = @"高清处理（消耗时间较多哦）";
    _previewQualityLabel.textColor     = [UIColor colorWithWhite:1 alpha:0.7];
    _previewQualityLabel.font          = [UIFont systemFontOfSize:12];
    _previewQualityLabel.textAlignment = NSTextAlignmentLeft;
    [_previewQualityView addSubview:_previewQualityLabel];
    
    UITapGestureRecognizer * gesTure  =  [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(qualityButtonClick)];
    [_previewQualityView addGestureRecognizer:gesTure];
    
}

/*
 * 创建播放暂停按钮
 * @author selice
 * @date 2023.06.01
 */
- (void)configPlayButton {
    _playButton             = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playButton addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playButton];
}


-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    CGFloat toolBarHeight = ([TZCommonTools tz_safeAreaInsets].bottom > 0) ? ([TZCommonTools tz_safeAreaInsets].bottom  + 17 + 17 + 41): 17 + 17 + 41;
    _previewBarView.frame           = CGRectMake(0, self.view.tz_height - toolBarHeight, self.view.tz_width, toolBarHeight);
    _previewBackBtn.frame           = CGRectMake(15, 17, 53, 41);
    _previewGetCoverBtn.frame       = CGRectMake(15+53+15, 17, self.view.tz_width-(15+53+15+15), 41);
    
    _playButton.frame               = CGRectMake(0, 0, self.view.tz_width, self.view.tz_height - toolBarHeight-(10+10+17));
    
    _previewQualityView.frame       = CGRectMake(0, self.view.tz_height - toolBarHeight-(10+10+17), self.view.tz_width, 10+10+17);
    _previewQualityBtn.frame        = CGRectMake(15, (10+10+17-10)/2, 10, 10);
    _previewQualityLabel.frame      = CGRectMake(CGRectGetMaxX(_previewQualityBtn.frame)+5, 0, 200, (10+10+17));
}

/*
 * 点击选择封面
 * @author selice
 * @date 2023.06.01
 */
-(void)qualityButtonClick{
    
    self.previewQuality = !self.previewQuality;
    if (self.previewQuality) {
        _previewQualityBtn.backgroundColor    = [UIColor colorWithRed:42/255.0 green:215/255.0 blue:255/255.0 alpha:1];
        _previewQualityBtn.layer.borderColor  = [UIColor colorWithRed:42/255.0 green:215/255.0 blue:255/255.0 alpha:1].CGColor;
        _previewQualityLabel.textColor        = [UIColor colorWithRed:42/255.0 green:215/255.0 blue:255/255.0 alpha:1];
    } else {
        _previewQualityBtn.backgroundColor    = [UIColor colorWithWhite:1 alpha:0.0];
        _previewQualityBtn.layer.borderColor  = [UIColor colorWithWhite:1 alpha:0.7].CGColor;
        _previewQualityLabel.textColor        = [UIColor colorWithWhite:1 alpha:0.7];
    }
}

#pragma mark - 点击视频视频暂停｜播放
- (void)playButtonClick {
    if (_player.rate == 0.0f) {
        [self playPlayer];
    } else {
        [self pausePlayer];
    }
}
#pragma mark - 点击视频视频播放
-(void)playPlayer{
    
    CMTime currentTime  = _player.currentItem.currentTime;
    CMTime durationTime = _player.currentItem.duration;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TZ_VIDEO_PLAY_NOTIFICATION" object:_player];
    if (currentTime.value == durationTime.value) [_player.currentItem seekToTime:CMTimeMake(0, 1)];
    [_player play];
    [_playButton setImage:nil forState:UIControlStateNormal];
    [_playButton setImage:nil forState:UIControlStateHighlighted];
}

#pragma mark - 点击视频视频暂停
- (void)pausePlayer {
    [_player pause];
    [_playButton setImage:[UIImage tz_imageNamedFromMyBundle:@"MMVideoPreviewPlay"] forState:UIControlStateNormal];
    [_playButton setImage:[UIImage tz_imageNamedFromMyBundle:@"MMVideoPreviewPlayHL"] forState:UIControlStateHighlighted];
}

#pragma mark - 返回重新选择视频
- (void)backButtonClick {
    [self pausePlayer];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 选择封面
- (void)nextButtonClick {
    
    [self pausePlayer];
    TZImagePickerController *imagePickerVc      = (TZImagePickerController *)self.navigationController;
    TZXDVideoGetCoverController *videoCropVc    = [[TZXDVideoGetCoverController alloc] init];
    videoCropVc.imagePickerVc                   = imagePickerVc;
    videoCropVc.model                           = self.model;
    videoCropVc.previewQuality                  = self.previewQuality;
    [self.navigationController pushViewController:videoCropVc animated:YES];
}

#pragma mark - Notification Method

#pragma mark - lazy
- (UIView *)iCloudErrorView{
    if (!_iCloudErrorView) {
        _iCloudErrorView = [[UIView alloc] initWithFrame:CGRectMake(0, [TZCommonTools tz_statusBarHeight] + 44 + 10, self.view.tz_width, 28)];
        UIImageView *icloud = [[UIImageView alloc] init];
        icloud.image = [UIImage tz_imageNamedFromMyBundle:@"iCloudError"];
        icloud.frame = CGRectMake(20, 0, 28, 28);
        [_iCloudErrorView addSubview:icloud];
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(53, 0, self.view.tz_width - 63, 28);
        label.font = [UIFont systemFontOfSize:10];
        label.textColor = [UIColor whiteColor];
        label.text = [NSBundle tz_localizedStringForKey:@"iCloud sync failed"];
        [_iCloudErrorView addSubview:label];
        [self.view addSubview:_iCloudErrorView];
        _iCloudErrorView.hidden = YES;
    }
    return _iCloudErrorView;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}


@end
