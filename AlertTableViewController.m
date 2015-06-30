//
//  AlertTableViewController.m
//  AlertViewSample
//
//  Created by Dinesh Kumar on 30/06/15.
//  Copyright (c) 2015 TheBanyanTree. All rights reserved.
//

#import "AlertTableViewController.h"
#import "NNAlertView.h"


@interface AlertTableViewController() <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *dropDownTitleTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *dropDownImageSegmentedControl;
@property (weak, nonatomic) IBOutlet UISwitch *dropDownAutoDismissSwitch;

@end

@implementation AlertTableViewController

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (IBAction)showDropDownAlert:(id)sender {
    UIImage * dropDownAlertImage = _dropDownImageSegmentedControl.selectedSegmentIndex?[UIImage imageNamed:@"Cancel-32"]:[UIImage imageNamed:@"Checkmark-32"];
    [self showAlertOnWindowWithTitle:_dropDownTitleTextField.text withImage:dropDownAlertImage];
}

@end
