//
//  NNAlertView.h
//  NNAlertView
//
//  Created by Dinesh on 10/04/15.


#import <UIKit/UIKit.h>

#define kAlertViewGeneralErrorImage  [UIImage imageNamed:@"zero-result-small"]
#define kAlertViewDoneImage          [UIImage imageNamed:@"message-sent-small"]
#define kAlertViewWifiNotFoundImage  [UIImage imageNamed:@"internet-error"]


@interface NSObject (NNShowAlertView)

//-----------------------------------------------------------------//
#pragma mark - Drop down Alerts
//-----------------------------------------------------------------//

/**
 @author Dinesh Kumar, 16 April 2015
 
 Shows an animated alert view on window, autodismissable after given time.
 Only one alert view can be shown at a time.
 
 @param alertDescriptionText Title of the alert. Should not be nil
 @param alertImage           Image to be displayed on alert
 */
-(void)showAlertOnWindowWithTitle:(NSString *)alertDescriptionText
                            withImage:(UIImage *)alertImage;

/**
 @author Dinesh Kumar, 16 April 2015
 
 Shows an animated alert autodismissable after given time.
 Only one alert view can be shown at a time.
 This method adds the alert view on controller's view if self is of type 
 UIViewcontroller or self is of type of UIView that has been added to view of a
 controller. In other cases it behaves similar to 'showAlertOnWindowWithTitle:withImage:'
 
 @param alertDescriptionText Title of the alert. Should not be nil
 @param alertImage           Image to be displayed on alert
 */
-(void)showAlertWithTitle:(NSString *)alertDescriptionText
                withImage:(UIImage *)alertImage;

/**
 @author Dinesh Kumar, 16 April 2015
 
 Method to hide any of the alert that is being shown.
 */
-(void)hideAlert;

//-----------------------------------------------------------------//
#pragma mark - Window Activity
//-----------------------------------------------------------------//

/**
 @author Dinesh Kumar, 16 April 2015
 
 Shows a spinner on window. Blocks user interactions.
 */
-(void)showActivityIndicatorView;

/**
 @author Dinesh Kumar, 16 April 2015
 
 Hides the spinner presented by 'showActivityIndicatorView'
 */
-(void)hideActivityIndicatorView;

//-----------------------------------------------------------------//
#pragma mark - Drop Down Progress Bar With title
//-----------------------------------------------------------------//

-(void)progressAlertShowWithTitle:(NSString *)title;

-(void)progressAlertShowOnWindowWithTitle:(NSString *)title;

-(void)progressAlertUpdateWithProgress:(float)progress
                             withTitle:(NSString *)title;

-(void)progressAlertHide;

@end


