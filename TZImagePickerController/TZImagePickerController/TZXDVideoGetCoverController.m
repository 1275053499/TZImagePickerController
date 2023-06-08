//
//  TZXDVideoGetCoverController.m
//  TZImagePickerController
//
//  Created by jmcl on 2023/6/1.
//

#import "TZXDVideoGetCoverController.h"
#import "TZAssetModel.h"
#import "TZImagePickerController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UIView+TZLayout.h"
#import "TZImageManager.h"

@interface TZXDVideoGetCoverController ()<UICollectionViewDelegate, UICollectionViewDataSource>{
    ///预留封面
    UIImage                 *_cover;
    ///返回清晰度处理的视频地址
    NSString                *_outputPath;
    ///分解视频封面工具
    AVAssetImageGenerator   *_imageGenerator;
    ///资源内容
    AVAsset                 *_asset;
    ///选中封面下标
    NSInteger                _selectedIndex;
}

///底图
@property(nonatomic,strong) UIView *baseView;
///大图展示
@property(nonatomic,strong) UIImageView *showImgView;
@property(strong,nonatomic) NSMutableArray *videoImgArray;
@property(strong,nonatomic) UICollectionView *collectionView;
@property(strong,nonatomic) UILabel * coverTipLabel;
@end

@implementation TZXDVideoGetCoverController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor       = [UIColor colorWithRed:16/255 green:16/255 blue:16/255 alpha:1];
    self.baseView                   = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.tz_width, self.view.tz_height-151)];
    self.baseView.backgroundColor   = [UIColor colorWithRed:0/255.0 green:0 blue:0 alpha:0.7];
    [self.view addSubview:self.baseView];
    
    self.showImgView                = [[UIImageView alloc]initWithFrame:CGRectMake(15, [TZCommonTools tz_statusBarHeight]+44,self.view.tz_width-30, self.view.tz_height-151-[TZCommonTools tz_statusBarHeight]-44)];
    self.showImgView.contentMode = UIViewContentModeScaleAspectFit;
    self.showImgView.clipsToBounds = YES;
    [self.baseView addSubview:self.showImgView];
    
    [self configMoviePlayer];
    [self generateVideoImage];
    [self configNavBar];
}

- (void)configMoviePlayer {
    
    _selectedIndex = 0;//默认选择第一个封面
    //分解获取一个预留的封面
    [[TZImageManager manager] getPhotoWithAsset:_model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (!isDegraded && photo) {
            self->_cover = photo;
        }
    }];
    //将媒体的PHAsset转为视频的AVAsset 为下一步分解封面准备
    [[TZImageManager manager] getVideoWithAsset:_model.asset completion:^(AVPlayerItem *playerItem, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_asset = playerItem.asset;
            [self configVideoImageCollectionView];
            [self generateVideoImage];
        });
    }];
}

/*
 * 创建显示封面的列表
 * @author selice
 * @date 2023.06.01
 */
- (void)configVideoImageCollectionView {
  
    UICollectionViewFlowLayout *layout = UICollectionViewFlowLayout.new;
    layout.scrollDirection      = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize             = CGSizeMake(46, 54);
    layout.minimumLineSpacing      = 12;
    layout.minimumInteritemSpacing = 12;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.dataSource      = self;
    _collectionView.delegate        = self;
    _collectionView.contentInset    = UIEdgeInsetsMake(0, 15 , 0, 10);
    _collectionView.frame           = CGRectMake(0, self.view.tz_height-100, self.view.tz_width, 54);
    _collectionView.clipsToBounds   = NO;
    _collectionView.showsHorizontalScrollIndicator  = NO;
    _collectionView.alwaysBounceHorizontal          = YES;
    [_collectionView registerClass:TZXDCoverVideoPictureCell.class forCellWithReuseIdentifier:@"TZXDCoverVideoPictureCell"];
    [self.view addSubview:_collectionView];
    _collectionView.backgroundColor  = UIColor.clearColor;
    
    _coverTipLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, self.view.tz_height-151+14, 100, 20)];
    _coverTipLabel.text = @"点击选择封面";
    _coverTipLabel.font = [UIFont systemFontOfSize:14];
    _coverTipLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.6];
    [self.view addSubview:_coverTipLabel];
}

/*
 * 分解视频的没秒第一帧作为封面的
 * @author selice
 * @date 2023.06.01
 */
- (void)generateVideoImage {
    
    _imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:_asset];
    _imageGenerator.requestedTimeToleranceBefore    = kCMTimeZero;
    _imageGenerator.requestedTimeToleranceAfter     = kCMTimeZero;
 
    NSTimeInterval durationSeconds  = self.model.asset.duration;
    NSUInteger imageCount           = self.model.asset.duration;

    Float64 frameRate = [[_asset tracksWithMediaType:AVMediaTypeVideo][0] nominalFrameRate];;
    NSMutableArray *times = NSMutableArray.array;
    NSTimeInterval intervalSecond = durationSeconds/imageCount;
    CMTime timeFrame;
    for (NSInteger i = 0; i < imageCount; i++) {
        timeFrame    = CMTimeMake(intervalSecond * i *frameRate, frameRate);
        NSValue *timeValue = [NSValue valueWithCMTime:timeFrame];
        [times addObject:timeValue];
    }
    self.videoImgArray    = NSMutableArray.new;
    typeof(self) weakSelf = self;
    [_imageGenerator generateCGImagesAsynchronouslyForTimes:times completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        if (image) {
            UIImage *img = [[UIImage alloc] initWithCGImage:image];
            [weakSelf.videoImgArray addObject:img];
            NSLog(@"解析每一秒的图片数据：视频时长:%f--个数：%ld",weakSelf.model.asset.duration,weakSelf.videoImgArray.count);
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.collectionView reloadData];
                [weakSelf showBigAction];
            });
        }
    }];
}

/*
 * 显示封面的大图
 * @author selice
 * @date 2023.06.01
 */
-(void)showBigAction{
    
    if (self.videoImgArray.count) {
        self.showImgView.image = self.videoImgArray[_selectedIndex];
    }
}

/*
 * 创建导航栏
 * @author selice
 * @date 2023.06.01
 */
-(void)configNavBar{
    
    UIView * cusNavView = [[UIView alloc]initWithFrame:CGRectMake(0, [TZCommonTools tz_statusBarHeight], self.view.tz_width, 44)];
    [self.view addSubview:cusNavView];
    cusNavView.backgroundColor = UIColor.clearColor;
    
    UIButton * backBtn         = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage tz_imageNamedFromMyBundle:@"btn_tz_cover_back"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage tz_imageNamedFromMyBundle:@"btn_tz_cover_back@2x"] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [cusNavView addSubview:backBtn];
    backBtn.frame           = CGRectMake(15, (44-31)/2, 35, 31);
    
    UILabel * titleLabel    = [[UILabel alloc]init];
    titleLabel.text         = @"封面选择";
    titleLabel.textColor     = UIColor.whiteColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font         =  [UIFont boldSystemFontOfSize:18];
    titleLabel.frame        = CGRectMake((self.view.tz_width-100)/2,0, 100, 44);
    [cusNavView addSubview:titleLabel];
    
    UIButton * nextBtn   = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [nextBtn setTitle:@"完成" forState:UIControlStateNormal];
    [nextBtn setTitle:@"完成" forState:UIControlStateHighlighted];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [nextBtn addTarget:self action:@selector(nextButtonClick) forControlEvents:UIControlEventTouchUpInside];
    nextBtn.backgroundColor    = [UIColor colorWithRed:105/255.0 green:227/255.0 blue:255/255.0 alpha:1];
    nextBtn.layer.cornerRadius = 7;
    nextBtn.clipsToBounds      = YES;
    nextBtn.titleLabel.font    = [UIFont boldSystemFontOfSize:12];
    [cusNavView addSubview:nextBtn];
    nextBtn.frame              = CGRectMake(self.view.tz_width-15-50, (44-27)/2, 50, 27);
}


/*
 * 返回重新选择视频
 * @author selice
 * @date 2023.06.01
 */
- (void)backButtonClick {
    [self.navigationController popViewControllerAnimated:YES];
}

/*
 * 【确定选择封面｜并进行清晰度质量压缩】返回参数
 * @author selice
 * @date 2023.06.01
 */
#pragma mark -
- (void)nextButtonClick {
    NSLog(@"选择封面下一步");
    TZImagePickerController *imagePickerVc      = (TZImagePickerController *)self.navigationController;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (imagePickerVc.autoDismiss) {
            [imagePickerVc dismissViewControllerAnimated:YES completion:^{
                [self callDelegateMethod];
            }];
        } else {
            [self callDelegateMethod];
        }
    });    
}

/*
 * 确定选择封面｜并进行清晰度质量压缩【返回参数】
 * @author selice
 * @date 2023.06.01
 */
#pragma mark -
- (void)callDelegateMethod {
     
    UIImage * coverImage = _cover;
    if (self.videoImgArray.count) {
        coverImage = self.videoImgArray[_selectedIndex];
    }
    
    TZImagePickerController *imagePickerVc = (TZImagePickerController *)self.navigationController;
    if ([imagePickerVc.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingAndQualityAndGetCoverVideo:sourceAssets:isHeightQuality:error:)]) {
        [imagePickerVc.pickerDelegate imagePickerController:imagePickerVc didFinishPickingAndQualityAndGetCoverVideo:coverImage sourceAssets:_model.asset isHeightQuality:self.previewQuality error:nil];
    }
    if (imagePickerVc.didFinishPickingAndQualityAndGetCoverVideoHandle) {
        imagePickerVc.didFinishPickingAndQualityAndGetCoverVideoHandle(coverImage,_model.asset,self.previewQuality,nil);
    }
}
#pragma mark - UICollectiobViewDataSource & UIcollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.videoImgArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TZXDCoverVideoPictureCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TZXDCoverVideoPictureCell" forIndexPath:indexPath];
    cell.imgView.image = self.videoImgArray[indexPath.item];
    if (_selectedIndex == indexPath.item) {
        cell.contentView.layer.borderColor = UIColor.whiteColor.CGColor;
        cell.coverView.hidden = YES;
    } else {
        cell.contentView.layer.borderColor = UIColor.clearColor.CGColor;
        cell.coverView.hidden = NO;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    _selectedIndex = indexPath.item;
    [self showBigAction];
    [_collectionView reloadData];
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

@implementation TZXDCoverVideoPictureCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 6;
        self.clipsToBounds = YES;
        self.contentView.layer.cornerRadius = 6;
        self.contentView.clipsToBounds      = YES;
        self.contentView.layer.borderWidth  = 1.5;
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    
    _imgView                    = [[UIImageView alloc] initWithFrame:CGRectMake(1, 1, 44, 52)];
    _imgView.contentMode        = UIViewContentModeScaleAspectFit;
    _imgView.clipsToBounds      = YES;
    _imgView.layer.cornerRadius = 6;
    [self.contentView addSubview:_imgView];
    
    _coverView                  = [[UIView alloc] initWithFrame:CGRectMake(1, 1, 44, 52)];
    _coverView.hidden           = YES;
    _coverView.clipsToBounds    = YES;
    _coverView.layer.cornerRadius = 6;
    _coverView.backgroundColor  = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    [self.contentView addSubview:_coverView];
   
}

@end
