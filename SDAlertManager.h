







#import <UIKit/UIKit.h>
///弹窗模式
typedef NS_ENUM(NSInteger,SDAlertViewStyle){
    ///默认 从窗口正中 弹出
    SDAlertViewStyleAlert = 0,
    ///下
    SDAlertViewStyleActionSheetDown,
    ///上
    SDAlertViewStyleActionSheetTop,
    ///左
    SDAlertViewStyleActiAlertLeft,
    ///右边
    SDAlertViewStyleActiAlertRight,
    
    ///底部显示
    SDAlertViewStyleActiAlertSheetBottom,
    
};

///关闭模式
typedef NS_ENUM(NSInteger,SDAlertCloseStyle){
    ///触摸整个窗口 关闭 【默认】
    SDAlertCloseStyleTapClose = 0,
    /// 点击关闭按钮关闭  自带【右上角 需要自己设置图片】
    SDAlertCloseStyleButtonClose,
    
};


typedef void(^showBlock)(void);;
typedef void(^dismissBlock)(void);


@interface SDAlertManager : NSObject
///弹出动画完成后的 回调
@property (nonatomic, copy) showBlock showBlock;
///关闭回调
@property (nonatomic, copy) dismissBlock dismissBlock;
///关闭模式
@property (nonatomic, assign) SDAlertCloseStyle closeStyle;
/// 当关闭模式为CloseStyleTapClose时 开启或关闭 自带的 移除弹窗事件 默认开启
@property (nonatomic, assign) BOOL on;
/// 关闭按钮 图片 30*30
@property (nonatomic, strong) UIImage *closeImage;

/**  创建弹出试图 */
+ (SDAlertManager *)sharedMask;
/**
 * show:withType:     弹出视图
 * @param contentView 需要弹出的视图
 * @param style       弹出模式
 */
- (void)show:(UIView *)contentView withType:(SDAlertViewStyle)style;
/**
 *  show:withType:animationFinish:dismissHandle: 弹出视图
 *  @param contentView 需要弹出的视图
 *  @param style       弹出模式
 *  @param show        弹出回调
 *  @param dismiss     消失回调
 *
 */
- (void)show:(UIView *)contentView withType:(SDAlertViewStyle)style animationFinish:(showBlock)show dismissHandle:(dismissBlock)dismiss;

/**  移除弹出视图 */
- (void)dismiss;

@end

