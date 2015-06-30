//
//  NNAlertView.m
//  NNAlertView
//
//  Created by Dinesh on 10/04/15.


#import "NNAlertView.h"
#import <objc/runtime.h>

//-----------------------------------------------------------------//
#pragma mark - Association Class
//-----------------------------------------------------------------//

@interface NSObject (AssociatedObjects)

- (void)associateValue:(id)value withKey:(void *)key;
- (id)associatedValueForKey:(void *)key;

@end

@implementation NSObject (AssociatedObjects)

- (void)associateValue:(id)value withKey:(void *)key {
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN);
}

- (id)associatedValueForKey:(void *)key {
    return objc_getAssociatedObject(self, key);
}

@end

//-----------------------------------------------------------------//
#pragma mark - Views Controller Fetching
//-----------------------------------------------------------------//

@interface UIView (NNViewsControllerFetching)

-(UIViewController *)parentViewController;
-(id)traverseResponderChainForUIViewController;

@end

@implementation UIView (NNViewsControllerFetching)

-(UIViewController *)parentViewController
{
    // convenience function for casting and to "mask" the recursive function
    return (UIViewController *)[self traverseResponderChainForUIViewController];
}

-(id)traverseResponderChainForUIViewController
{
    
    id nextResponder = [self nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        return nextResponder;
    } else if ([nextResponder isKindOfClass:[UIView class]]) {
        return [nextResponder traverseResponderChainForUIViewController];
    } else {
        return nil;
    }
}
@end


//-----------------------------------------------------------------//
#pragma mark - Activity Indicator View
//-----------------------------------------------------------------//

#define kObjAssoActivityViewKey @"activityView"

@interface NNActivityIndicatorView : UIView

@property (nonatomic,assign) BOOL isVisible;
@property (nonatomic,weak) UIWindow * window;

+(instancetype)sharedInstance;
-(void)setup;
-(void)show;
-(void)hide;

@end

@implementation NNActivityIndicatorView

static NNActivityIndicatorView * sharedInstance = nil;

+ (instancetype)sharedInstance
{
    static dispatch_once_t pred;
    
    if (nil != sharedInstance)
        return sharedInstance;
    
    dispatch_once(&pred, ^{
        sharedInstance = [NNActivityIndicatorView new];
        [sharedInstance setup];
    });
    
    return sharedInstance;
}

-(void)setup
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.window = [UIApplication sharedApplication].keyWindow;
    UIView * selfAlias = self;
    
    UIActivityIndicatorView * activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.color = [UIColor blackColor];
    activityView.translatesAutoresizingMaskIntoConstraints = NO;
    [activityView startAnimating];
    
    [self addSubview:activityView];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[selfAlias]-(<=1)-[activityView]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:NSDictionaryOfVariableBindings(activityView,selfAlias)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[selfAlias]-(<=1)-[activityView]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(activityView,selfAlias)]];
    
    [self.window insertSubview:self atIndex:0];
    NSArray * verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[selfAlias]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(selfAlias)];
    NSArray * horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[selfAlias]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(selfAlias)];
    
    [self.window addConstraints:verticalConstraints];
    [self.window addConstraints:horizontalConstraints];
    self.isVisible = NO;
}

-(void)show
{
    if(self.isVisible) return;
    self.isVisible = YES;
    
    [self.window bringSubviewToFront:self];
    self.alpha = 1.0;
}

-(void)hide
{
    if(!self.isVisible) return;
    self.isVisible = NO;
    self.alpha = 0.0;
    [self.window sendSubviewToBack:self];
}


@end

//-----------------------------------------------------------------//
#pragma mark - Progress View
//-----------------------------------------------------------------//

#define kProgressViewAnimationDuration 0.3
#define kProgressViewAssociationKey    @"ProgressViewAssociationKey"
#define kProgressViewTopConstraintKey  @"ProgressViewTopConstraintKey"

@interface NNProgressView : UIView

@property (nonatomic,assign) CGFloat contentOffset;

@property (nonatomic,assign) float progress;
@property (nonatomic,strong) NSString * progressDescriptionText;

-(void)showOnView:(UIView *)view
       withOffset:(CGFloat)topOffset
   withCompletion:(void(^)(BOOL success))completion;

-(void)showOnController:(UIViewController *)viewController
         withCompletion:(void(^)(BOOL success))completion;

-(void)updateWithProgress:(float)progress
                withTitle:(NSString *)progressDescription;

-(void)hideWithCompletion:(void(^)(BOOL success))completion;

@end

@interface NNProgressView ()

@property (nonatomic,strong) UIProgressView * progressView;
@property (nonatomic,strong) UILabel * progressDescriptionLabel;

@property (nonatomic,strong) NSLayoutConstraint * labelLeadingConstraint;
@property (nonatomic,strong) NSLayoutConstraint * labelTrailingConstraint;
@property (nonatomic,strong) NSLayoutConstraint * labelTopConstraint;
@property (nonatomic,strong) NSLayoutConstraint * labelBottomConstraint;

@property (nonatomic,strong) NSLayoutConstraint * progressViewLeadingConstraint;
@property (nonatomic,strong) NSLayoutConstraint * progressViewTopConstraint;
@property (nonatomic,strong) NSLayoutConstraint * progressViewTrailingConstraint;

@end

@implementation NNProgressView
@dynamic progressDescriptionText;


-(void)setProgressDescriptionText:(NSString *)progressDescriptionText
{
    self.progressDescriptionLabel.text = progressDescriptionText;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = [UIColor colorWithWhite:0.263 alpha:1.000];
        _contentOffset = 12;
        
        _progressView = [UIProgressView new];
        _progressView.translatesAutoresizingMaskIntoConstraints = NO;
        _progressView.progress = 0.0;
        
        _progressDescriptionLabel = [UILabel new];
        _progressDescriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _progressDescriptionLabel.textColor = [UIColor whiteColor];
        _progressDescriptionLabel.numberOfLines = 0;
        _progressDescriptionLabel.font = [UIFont systemFontOfSize:15];
        
        [self addSubview:_progressView];
        [self addSubview:_progressDescriptionLabel];
        
        NSDictionary * views = NSDictionaryOfVariableBindings(_progressView,
                                                              _progressDescriptionLabel);
        NSDictionary * metrics = @{@"offset": @(self.contentOffset)};
        
        NSArray * verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(offset)-[_progressView]-(offset)-[_progressDescriptionLabel]-(offset)-|" options:NSLayoutFormatAlignAllLeading | NSLayoutFormatAlignAllTrailing metrics:metrics views:views];
        NSArray * horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-(offset)-[_progressView]-(offset)-|" options:0 metrics:metrics views:views];
        
        [self addConstraints:verticalConstraints];
        [self addConstraints:horizontalConstraints];
    }
    return self;
}

-(void)showOnController:(UIViewController *)viewController
         withCompletion:(void(^)(BOOL success))completion
{
    if(!viewController) return;
    [viewController.view addSubview:self];
    NSLayoutConstraint * topConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:viewController.topLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [self associateValue:topConstraint withKey:kProgressViewTopConstraintKey];
    [viewController.view addConstraint:topConstraint];
    UIView * selfAlias = self;
    [viewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[selfAlias]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(selfAlias)]];
    [self layoutSubviews];
    CGSize estimatedSize = [self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    topConstraint.constant = -(estimatedSize.height);
    [viewController.view layoutSubviews];
    topConstraint.constant = 0;
    self.alpha = 0.0;
    [UIView animateWithDuration:kProgressViewAnimationDuration animations:^{
        [viewController.view layoutSubviews];
        self.alpha = 1.0;
    }completion:^(BOOL success){
        completion?completion(success):0;
    }];
    
}

-(void)showOnView:(UIView *)view
       withOffset:(CGFloat)topOffset
   withCompletion:(void(^)(BOOL success))completion
{
    if(!view) return;
    [view addSubview:self];
    NSLayoutConstraint * topConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTop multiplier:1 constant:topOffset];
    [self associateValue:topConstraint withKey:kProgressViewTopConstraintKey];
    [view addConstraint:topConstraint];
    UIView * selfAlias = self;
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[selfAlias]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(selfAlias)]];
    [self layoutSubviews];
    CGSize estimatedSize = [self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    topConstraint.constant = topOffset - estimatedSize.height;
    [view layoutSubviews];
    topConstraint.constant = topOffset;
    self.alpha = 0.0;
    [UIView animateWithDuration:kProgressViewAnimationDuration animations:^{
        [view layoutSubviews];
        self.alpha = 1.0;
    }completion:^(BOOL success){
        completion?completion(success):0;
    }];
    
}

-(void)hideWithCompletion:(void(^)(BOOL success))completion
{
    if(!self.superview) return;
    NSLayoutConstraint * topConstraint = [self associatedValueForKey:kProgressViewAssociationKey];
    topConstraint.constant = topConstraint.constant -CGRectGetHeight(self.frame);
    self.alpha = 1.0;
    [UIView animateWithDuration:kProgressViewAnimationDuration animations:^{
        self.alpha = 0.0;
        [self.superview layoutSubviews];
    } completion:^(BOOL success){
        [self removeFromSuperview];
        completion?completion(success):0;
    }];
}

-(void)updateWithProgress:(float)progress
                withTitle:(NSString *)progressDescription;
{
    if(!progressDescription && !progressDescription.length) return;
    
    progress = (progress>1)?1:(progress<0?0:progress);
    [_progressView setProgress:progress animated:YES];
    [_progressDescriptionLabel setText:progressDescription];
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
    [UIView animateWithDuration:0.5 animations:^{[self layoutIfNeeded];}];
}


@end

//-----------------------------------------------------------------//
#pragma mark - Alert View
//-----------------------------------------------------------------//

#define kAnimationDuration 0.3

#define kAlertViewAssociationKey              @"AlertViewAssociation"
#define kAlertViewTopConstraintAssociationKey @"AlertViewTopConstraintAssociation"

@interface NNAlertView : UIView

@property (nonatomic,assign) BOOL dismissOnTouch;
@property (nonatomic,assign) BOOL autoDismiss;
@property (nonatomic,assign) NSTimeInterval visibilityDuration;
@property (nonatomic,assign) CGFloat contentOffset;
@property (nonatomic,assign) CGFloat alertImageDimension;

@property (nonatomic,strong) UIImage * alertImage;
@property (nonatomic,strong) NSString * alertDescriptionText;

-(void)showOnView:(UIView *)view
       withOffset:(CGFloat)topOffset
   withCompletion:(void(^)(BOOL success))completion;

-(void)showOnController:(UIViewController *)viewController
         withCompletion:(void(^)(BOOL success))completion;

-(void)hideWithCompletion:(void(^)(BOOL success))completion;

@end

@interface NNAlertView ()

@property (nonatomic,strong) UIImageView * alertImageView;
@property (nonatomic,strong) UILabel * alertDescriptionLabel;

@property (nonatomic,strong) NSLayoutConstraint * labelLeadingConstraint;
@property (nonatomic,strong) NSLayoutConstraint * labelTrailingConstraint;
@property (nonatomic,strong) NSLayoutConstraint * labelTopConstraint;
@property (nonatomic,strong) NSLayoutConstraint * labelBottomConstraint;

@property (nonatomic,strong) NSLayoutConstraint * imageViewLeadingConstraint;
@property (nonatomic,strong) NSLayoutConstraint * imageViewTopConstraint;
@property (nonatomic,strong) NSLayoutConstraint * imageViewWidthConstraint;
@property (nonatomic,strong) NSLayoutConstraint * imageViewHeightConstraint;
@property (nonatomic,strong) NSLayoutConstraint * imageViewBottomConstraint;

@end

@implementation NNAlertView

@dynamic alertImage;
@dynamic alertDescriptionText;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = [UIColor colorWithWhite:0.263 alpha:1.000];
        _dismissOnTouch = YES;
        _autoDismiss = YES;
        _visibilityDuration = 2.2;
        _contentOffset = 12;
        _alertImageDimension = 30;
    } 
    return self;
}

-(void)setAlertImage:(UIImage *)alertImage
{
    if(alertImage && self.alertImageView) {
        self.alertImageView.image = alertImage;
    }
    if(alertImage && !self.alertImageView) {
        self.alertImageView = [UIImageView new];
        self.alertImageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.alertImageView.image = alertImage;
        
        [self addSubview:self.alertImageView];
        
        self.imageViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.alertImageView
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1
                                                                    constant:self.contentOffset];
        self.imageViewLeadingConstraint = [NSLayoutConstraint constraintWithItem:self.alertImageView
                                                                       attribute:NSLayoutAttributeLeading
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self
                                                                       attribute:NSLayoutAttributeLeading
                                                                      multiplier:1
                                                                        constant:self.contentOffset];
        self.imageViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.alertImageView
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nil
                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                    multiplier:1
                                                                      constant:self.alertImageDimension];
        self.imageViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.alertImageView
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1
                                                                       constant:self.alertImageDimension];
        self.imageViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                         toItem:self.alertImageView
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1
                                                                       constant:self.contentOffset];
        if(self.labelLeadingConstraint)
            self.labelLeadingConstraint.constant = (self.contentOffset*2)+self.alertImageDimension;
        [self addConstraints:@[_imageViewTopConstraint,_imageViewLeadingConstraint,_imageViewBottomConstraint]];
        [self.alertImageView addConstraints:@[_imageViewWidthConstraint,_imageViewHeightConstraint]];
        
        
    }
    if(!alertImage && self.alertImageView) {
        self.alertImageView = nil;
        [self.alertImageView removeFromSuperview];
        self.labelLeadingConstraint.constant = self.contentOffset;
    }
    
}

-(void)setAlertDescriptionText:(NSString *)alertDescriptionText
{
    if(alertDescriptionText && self.alertDescriptionLabel) {
        self.alertDescriptionLabel.text = alertDescriptionText;
        self.alertDescriptionLabel.accessibilityValue = alertDescriptionText;
    }
    if(alertDescriptionText && !self.alertDescriptionLabel) {
        self.alertDescriptionLabel = [UILabel new];
        
        //Accessibility
        self.alertDescriptionLabel.isAccessibilityElement = YES;
        self.alertDescriptionLabel.accessibilityLabel = [NSString stringWithFormat:@"%@_Toast",NSStringFromClass([self class])];
        self.alertDescriptionLabel.accessibilityValue = alertDescriptionText;
        self.alertDescriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.alertDescriptionLabel.textColor = [UIColor whiteColor];
        self.alertDescriptionLabel.numberOfLines = 0;
        self.alertDescriptionLabel.font = [UIFont systemFontOfSize:15];
        
        self.alertDescriptionLabel.text = alertDescriptionText;
        
        [self addSubview:self.alertDescriptionLabel];
        
        self.labelLeadingConstraint = [NSLayoutConstraint constraintWithItem:self.alertDescriptionLabel
                                                                   attribute:NSLayoutAttributeLeading
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeLeading
                                                                  multiplier:1
                                                                    constant:self.contentOffset];
        
        self.labelTopConstraint = [NSLayoutConstraint constraintWithItem:self.alertDescriptionLabel
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1
                                                                constant:self.contentOffset];
        
        self.labelTrailingConstraint = [NSLayoutConstraint constraintWithItem:self.alertDescriptionLabel
                                                                    attribute:NSLayoutAttributeTrailing
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self
                                                                    attribute:NSLayoutAttributeTrailing
                                                                   multiplier:1
                                                                     constant:-self.contentOffset];
        
        self.labelBottomConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.alertDescriptionLabel
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1
                                                                   constant:self.contentOffset];
        if(self.alertImageView)
            self.labelLeadingConstraint.constant = (self.contentOffset*2)+self.alertImageDimension;
        
        [self addConstraints:@[_labelTopConstraint,
                               _labelBottomConstraint,
                               _labelLeadingConstraint,
                               _labelTrailingConstraint]];
        
    }
    if(!alertDescriptionText && self.alertDescriptionLabel) {
        self.alertDescriptionLabel = nil;
        [self.alertDescriptionLabel removeFromSuperview];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    if(self.dismissOnTouch)
        [self hideRemovingAssociation];
}

-(void)showOnController:(UIViewController *)viewController
         withCompletion:(void(^)(BOOL success))completion
{
    if(!viewController) return;
    [viewController.view addSubview:self];
    NSLayoutConstraint * topConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:viewController.topLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [self associateValue:topConstraint withKey:kAlertViewTopConstraintAssociationKey];
    [viewController.view addConstraint:topConstraint];
    UIView * selfAlias = self;
    [viewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[selfAlias]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(selfAlias)]];
    [self layoutSubviews];
    CGSize estimatedSize = [self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    topConstraint.constant = -(estimatedSize.height);
    [viewController.view layoutSubviews];
    topConstraint.constant = 0;
    self.alpha = 0.0;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        [viewController.view layoutSubviews];
        self.alpha = 1.0;
    }completion:^(BOOL success){
        [self performSelector:@selector(hideRemovingAssociation) withObject:nil afterDelay:self.visibilityDuration];
        completion?completion(success):0;
    }];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideRemovingAssociation) name:NNApplicationTouchBeginNotification object:nil];
}

-(void)showOnView:(UIView *)view
       withOffset:(CGFloat)topOffset
   withCompletion:(void(^)(BOOL success))completion
{
    if(!view) return;
    [view addSubview:self];
    NSLayoutConstraint * topConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTop multiplier:1 constant:topOffset];
    [self associateValue:topConstraint withKey:kAlertViewTopConstraintAssociationKey];
    [view addConstraint:topConstraint];
    UIView * selfAlias = self;
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[selfAlias]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(selfAlias)]];
    [self layoutSubviews];
    CGSize estimatedSize = [self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    topConstraint.constant = topOffset - estimatedSize.height;
    [view layoutSubviews];
    topConstraint.constant = topOffset;
    self.alpha = 0.0;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        [view layoutSubviews];
        self.alpha = 1.0;
    }completion:^(BOOL success){
        [self performSelector:@selector(hideRemovingAssociation) withObject:nil afterDelay:self.visibilityDuration];
        completion?completion(success):0;
    }];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideRemovingAssociation) name:NNApplicationTouchBeginNotification object:nil];
}

-(void)hideWithCompletion:(void(^)(BOOL success))completion
{
    if(!self.superview) return;
    NSLayoutConstraint * topConstraint = [self associatedValueForKey:kAlertViewTopConstraintAssociationKey];
    topConstraint.constant = topConstraint.constant -CGRectGetHeight(self.frame);
    self.alpha = 1.0;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.alpha = 0.0;
        [self.superview layoutSubviews];
    } completion:^(BOOL success){
        [self removeFromSuperview];
        completion?completion(success):0;
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }];
}

-(void)hideRemovingAssociation
{
    [self hideWithCompletion:^(BOOL success){
        [[UIApplication sharedApplication] associateValue:nil withKey:kAlertViewAssociationKey];
    }];
}

@end

@implementation NSObject (NNShowAlertView)

//-----------------------------------------------------------------//
#pragma mark - Alert View Show Hide
//-----------------------------------------------------------------//

-(void)showAlertWithTitle:(NSString *)alertDescriptionText withImage:(UIImage *)alertImage
{
    // Sanity Check
    if(!alertDescriptionText.length) return;
    
    // If self is kind of view, try to fetch its controller,
    else if([self isKindOfClass:[UIView class]] && [((UIView *)self) parentViewController]) {
        [[((UIView *)self) parentViewController] showAlertWithTitle:alertDescriptionText withImage:alertImage];
    }
    // If Self is kind of controller
    else if([self isKindOfClass:[UIViewController class]]) {
        [self showAlertOnControllerWithTitle:alertDescriptionText withImage:alertImage];
    }
    else {
        [self showAlertOnWindowWithTitle:alertDescriptionText withImage:alertImage];
    }
}

-(void)showAlertOnControllerWithTitle:(NSString *)alertDescriptionText withImage:(UIImage *)alertImage
{
    // Sanity Check
    if(!alertDescriptionText.length) return;
    
    // If any existing alert is shown, then return
    NNAlertView * existingAlert = [[UIApplication sharedApplication] associatedValueForKey:kAlertViewAssociationKey];
    if(existingAlert) return;
    
    // Else create a new Alert View, set it up, associate it, show it on key window
    else {
        NNAlertView * alertView = [NNAlertView new];
        alertView.alertDescriptionText = [alertDescriptionText copy];
        alertView.alertImage = [alertImage copy];
        [[UIApplication sharedApplication] associateValue:alertView withKey:kAlertViewAssociationKey];
        [alertView showOnController:((UIViewController *)self) withCompletion:NULL];
    }
}

-(void)showAlertOnWindowWithTitle:(NSString *)alertDescriptionText withImage:(UIImage *)alertImage
{
    // Sanity Check
    if(!alertDescriptionText.length) return;
    
    // If any existing alert is shown, then return
    NNAlertView * existingAlert = [[UIApplication sharedApplication] associatedValueForKey:kAlertViewAssociationKey];
    if(existingAlert) return;
    
    // Else create a new Alert View, set it up, associate it, show it on key window
    else {
        UIWindow * window = [UIApplication sharedApplication].keyWindow;
        NNAlertView * alertView = [NNAlertView new];
        alertView.alertDescriptionText = [alertDescriptionText copy];
        alertView.alertImage = [alertImage copy];
        [[UIApplication sharedApplication] associateValue:alertView withKey:kAlertViewAssociationKey];
        [alertView showOnView:window withOffset:64.0 withCompletion:NULL];
    }
}

-(void)hideAlert
{
    // If an associated alert exists, call its hide method
    NNAlertView * existingAlert = [[UIApplication sharedApplication] associatedValueForKey:kAlertViewAssociationKey];
    [existingAlert hideWithCompletion:^(BOOL success){
        [[UIApplication sharedApplication] associateValue:nil withKey:kAlertViewAssociationKey];
    }];
}

#//-----------------------------------------------------------------//
#pragma mark - Activity Indicator Show Hide
//-----------------------------------------------------------------//

-(void)showActivityIndicatorView
{
    NSString *sourceString = [[NSThread callStackSymbols] objectAtIndex:1];
    NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[sourceString  componentsSeparatedByCharactersInSet:separatorSet]];
    [array removeObject:@""];
    
    NSLog(@"Show Class caller = %@", [array objectAtIndex:3]);
    NSLog(@"Show Function caller = %@", [array objectAtIndex:4]);
    
    if([UIApplication sharedApplication].keyWindow)
        [[NNActivityIndicatorView sharedInstance] show];
}

-(void)hideActivityIndicatorView
{
    NSString *sourceString = [[NSThread callStackSymbols] objectAtIndex:1];
    NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[sourceString  componentsSeparatedByCharactersInSet:separatorSet]];
    [array removeObject:@""];
    
    NSLog(@"Hide Class caller = %@", [array objectAtIndex:3]);
    NSLog(@"Hide Function caller = %@", [array objectAtIndex:4]);
    if([UIApplication sharedApplication].keyWindow)
        [[NNActivityIndicatorView sharedInstance] hide];
}

//-----------------------------------------------------------------//
#pragma mark - Progress View Show Hide
//-----------------------------------------------------------------//

-(void)progressAlertShowWithTitle:(NSString *)title
{
    // Sanity Check
    if(!title.length) return;
    
    // If self is kind of view, try to fetch its controller,
    else if([self isKindOfClass:[UIView class]] && [((UIView *)self) parentViewController]) {
        [[((UIView *)self) parentViewController] progressAlertShowWithTitle:title];
    }
    // If Self is kind of controller
    else if([self isKindOfClass:[UIViewController class]]) {
        [self progressAlertShowOnControllerWithTitle:title];
    }
    else {
        [self progressAlertShowOnWindowWithTitle:title];
    }
}

-(void)progressAlertShowOnControllerWithTitle:(NSString *)title
{
    // Sanity Check
    if(!title.length) return;
    
    // If any existing alert is shown, then return
    NNProgressView * existingProgressView = [[UIApplication sharedApplication] associatedValueForKey:kProgressViewAssociationKey];
    if(existingProgressView) return;
    
    // Else create a new Alert View, set it up, associate it, show it on key window
    else {
        NNProgressView * progressView = [NNProgressView new];
        progressView.progressDescriptionText = [title copy];
        [[UIApplication sharedApplication] associateValue:progressView withKey:kAlertViewAssociationKey];
        [progressView showOnController:((UIViewController *)self) withCompletion:NULL];
    }
}

-(void)progressAlertShowOnWindowWithTitle:(NSString *)title
{
    // Sanity Check
    if(!title.length) return;
    
    // If any existing alert is shown, then return
    NNProgressView * existingProgressView = [[UIApplication sharedApplication] associatedValueForKey:kProgressViewAssociationKey];
    if(existingProgressView) return;
    
    // Else create a new Alert View, set it up, associate it, show it on key window
    else {
        UIWindow * window = [UIApplication sharedApplication].keyWindow;
        NNProgressView * progressView = [NNProgressView new];
        progressView.progressDescriptionText = [title copy];
        [[UIApplication sharedApplication] associateValue:progressView withKey:kProgressViewAssociationKey];
        [progressView showOnView:window withOffset:64.0 withCompletion:NULL];
    }
}

-(void)progressAlertUpdateWithProgress:(float)progress
                             withTitle:(NSString *)title
{
    // Sanity Check
    if(!title.length) return;
    
    // If any existing alert is shown, then return
    NNProgressView * existingProgressView = [[UIApplication sharedApplication] associatedValueForKey:kProgressViewAssociationKey];
    if(existingProgressView) {
        [existingProgressView updateWithProgress:progress withTitle:title];
    };
}

-(void)progressAlertHide
{
    // If an associated alert exists, call its hide method
    NNProgressView * existingProgressView = [[UIApplication sharedApplication] associatedValueForKey:kProgressViewAssociationKey];
    [existingProgressView hideWithCompletion:^(BOOL success){
        [[UIApplication sharedApplication] associateValue:nil withKey:kProgressViewAssociationKey];
    }];
}


@end

