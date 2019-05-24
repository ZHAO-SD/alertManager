







#import "SDAlertManager.h"

#define IS_IPAD           (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define IS_IPHONE_X ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )812 ) < DBL_EPSILON )

//判断iPHoneXr
#define IS_IPHONE_Xr ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) && !IS_IPAD : NO)
//判断iPhoneXs
#define IS_IPHONE_Xs ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !IS_IPAD : NO)
//判断iPhoneXs Max
#define IS_IPHONE_Xs_Max ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) && !IS_IPAD : NO)

//判断全面屏
#define IS_IPHONE_X_ALL (IS_IPHONE_X || IS_IPHONE_Xr || IS_IPHONE_Xs || IS_IPHONE_Xs_Max)
#define SAFE_MARGIN_BOTTOM         (IS_IPHONE_X_ALL ? 34.f : 0.f)


#define KEYWINDOW     [[UIApplication sharedApplication] keyWindow]
#define ANIMATION_TIME 0.5
#define SDWEAKSELF __weak typeof(self) weakSelf = self;
@interface SDAlertManager ()
///遮罩层
@property (nonatomic, strong) UIView *maskLayer;
//响应事件的控件
@property (nonatomic, strong) UIControl *control;
//保存弹出视图
@property (nonatomic, strong) UIView *contentView;
///弹出模式
@property (nonatomic, assign) SDAlertViewStyle alertStyle;
///动画前的位置
@property (nonatomic, assign) CGAffineTransform starTransForm;
///关闭按钮
@property (nonatomic, strong) UIButton *closeBtn;

@end

@implementation SDAlertManager
+ (SDAlertManager *)sharedMask{
    static SDAlertManager *alertView;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!alertView) {
            alertView = [[SDAlertManager alloc] init];
        }
    });
    return alertView;
}

- (UIControl *)control{
    
    if(!_control){
        
        _control = [[UIControl alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        
        [_control addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        _control.enabled = NO;
    }
    return _control;
}
- (UIButton *)closeBtn{
    
    if(!_closeBtn){
        //添加按钮关闭
        _closeBtn = [[UIButton alloc] init];
        //        _closeBtn.backgroundColor = [UIColor whiteColor];
        //        _closeBtn.layer.cornerRadius = 15.0;
        [_closeBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        _closeBtn.frame = CGRectMake(_contentView.frame.size.width - 30, 0, 30, 30);
        [_contentView addSubview:_closeBtn];
    }
    return _closeBtn;
}
- (void)show:(UIView *)contentView withType:(SDAlertViewStyle)style{
    //判断是否赋于大小
    CGFloat contentViewHeight =  contentView.frame.size.height;
    CGFloat contentViewWidth  =  contentView.frame.size.width;
    if(contentViewHeight == 0.00||contentViewWidth == 0.00){
        NSLog(@"弹出视图 必须 赋予宽高");
        return;
    }
    _contentView = contentView;
    _contentView.center = KEYWINDOW.center;
    _alertStyle = style;
    _on = YES;
    if (!_maskLayer) {
        [self addMaskLayer];
        // 根据弹出模式 添加动画
        switch (_alertStyle) {
            case SDAlertViewStyleAlert:
                _starTransForm = CGAffineTransformMakeScale(0.01, 0.01);
                break;
            case SDAlertViewStyleActiAlertLeft:
                _starTransForm = CGAffineTransformMakeTranslation(-SCREEN_WIDTH, 0);
                break;
            case SDAlertViewStyleActiAlertRight:
                _starTransForm = CGAffineTransformMakeTranslation(SCREEN_WIDTH, 0);
                break;
            case SDAlertViewStyleActionSheetTop:
                
                _starTransForm = CGAffineTransformMakeTranslation(0, -_contentView.frame.size.height);
                break;
            case SDAlertViewStyleActionSheetDown:
                
                _starTransForm = CGAffineTransformMakeTranslation(0, SCREEN_HEIGHT);
            
                break;
                
            case SDAlertViewStyleActiAlertSheetBottom:{
                
                CGFloat x = (KEYWINDOW.frame.size.width - contentView.frame.size.width)*0.5;
                CGFloat y = (KEYWINDOW.frame.size.height-contentView.frame.size.height - SAFE_MARGIN_BOTTOM);
                CGFloat w = contentView.frame.size.width;
                CGFloat h = contentView.frame.size.height;
                 _contentView.frame = CGRectMake(x, y, w, h);
                
                _starTransForm = CGAffineTransformMakeTranslation(0, SCREEN_HEIGHT);
            }
                
            default:
                break;
        }
        [self alertAnimatedPrensent];
        
    }else {
        
        //
        _maskLayer = nil;
    }
    
    
}
//  自定义的alert或actionSheet内容view必须初始化大小
- (void)show:(UIView *)contentView withType:(SDAlertViewStyle)style animationFinish:(showBlock)show dismissHandle:(dismissBlock)dismiss {
    //保存 回调
    if (show) {
        _showBlock = [show copy];
    }
    if(dismiss){
        _dismissBlock = [dismiss copy];
    }
    [self show:contentView withType:style];
}


///添加遮罩
- (void)addMaskLayer{
    _maskLayer = [UIView new];
    [_maskLayer setFrame:[[UIScreen mainScreen] bounds]];
    [_maskLayer setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.30]];
    [KEYWINDOW  addSubview:_maskLayer];
    //判断关闭方式
    [self setCloseStyle:_closeStyle];
    [KEYWINDOW addSubview:_control];
    /// 默认开启
    self.on = YES;
}
//关闭 自带事件 由用户自己写事件关闭弹窗
- (void)setOn:(BOOL)on{
    _on = on;
    _control.enabled = _on;
    _closeBtn.hidden = !_on;
}
- (void)setCloseImage:(UIImage *)closeImage{
    
    [_closeBtn setImage:closeImage forState:UIControlStateNormal];
}
- (void)setCloseStyle:(SDAlertCloseStyle)closeStyle{
    _closeStyle = closeStyle;
    //判断关闭方式
    if (_closeStyle == SDAlertCloseStyleTapClose)
    {
        self.control.enabled = YES;
        self.closeBtn.hidden = YES;
    }else{
        self.control.enabled = NO;
        self.closeBtn.hidden = NO;
    }
    
}
- (void)dismiss{
    //设置初始值
    // 移除遮罩
    if (_maskLayer) {
        [_maskLayer removeFromSuperview];
        [_control removeFromSuperview];
        [_closeBtn removeFromSuperview];
        _maskLayer = nil;
        _control = nil;
        _closeBtn = nil;
    }
    //移除弹出框
    [self alertAnimatedOut];
    //回调动画完成回调
    if (_dismissBlock) {
        
        _dismissBlock();
    }
    
}
- (void)alertAnimatedPrensent{
    _contentView.transform = _starTransForm;
    [KEYWINDOW addSubview:_contentView];
    SDWEAKSELF
    CGFloat damping = _alertStyle == SDAlertViewStyleActiAlertSheetBottom? 1:0.7;
    [UIView animateWithDuration:ANIMATION_TIME delay:0.0 usingSpringWithDamping:damping initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        weakSelf.contentView.transform = CGAffineTransformIdentity;
        KEYWINDOW.userInteractionEnabled = NO;
    } completion:^(BOOL finished) {
        KEYWINDOW.userInteractionEnabled = YES;
        if (weakSelf.showBlock) {
            //动画完成后回调
            weakSelf.showBlock();
        }
    }];
}
- (void)addCoreAnimation{
    
    CATransition *animation = [CATransition animation];
    animation.type = @"rippleEffect";
    animation.duration = ANIMATION_TIME;
    [_contentView.layer addAnimation:animation forKey:@""];
    
}
- (void)alertAnimatedOut{
    SDWEAKSELF
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
        weakSelf.contentView.transform = weakSelf.starTransForm;
        KEYWINDOW.userInteractionEnabled = NO;
    } completion:^(BOOL finished) {
        KEYWINDOW.userInteractionEnabled = YES;
        [weakSelf.contentView removeFromSuperview];
        weakSelf.contentView = nil;
    }];
    
}
@end
