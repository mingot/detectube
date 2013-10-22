//
//  InputDetailsViewController.m
//  DetectTube
//
//  Created by Josep Marc Mingot Hidalgo on 20/09/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "InputDetailsViewController.h"
#import "TrainingViewController.h"


#define kClass @"Object"
#define kName @"Detector name"
#define kIsPublic 0


@implementation InputDetailsViewController


- (void) viewDidAppear:(BOOL)animated
{
    // default initial value
    self.detectorTrainer.isPublic = YES;
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Disable keyboard when the background is touched
    NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}


#pragma mark -
#pragma mark IBActions

- (IBAction)isPublicAction:(UISegmentedControl *)sender
{
    self.detectorTrainer.isPublic = sender.selectedSegmentIndex == kIsPublic ? YES : NO;
}

#pragma mark -
#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showTraining"]) {
        TrainingViewController *destinationVC = (TrainingViewController *)segue.destinationViewController;
        destinationVC.detectorTrainer = self.detectorTrainer;
    }
}

#pragma mark -
#pragma mark UITextFieldDelegate


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // Add suggestion of a detector name to go faster training
    
    if ([textField.placeholder isEqualToString:kName])
        self.detectorTrainer.name = textField.text;
    else if([textField.placeholder isEqualToString:kClass]){
        self.detectorTrainer.targetClass = textField.text;
        if([textField.text length]!=0 && [self.nameTextField.text length]==0){
            self.nameTextField.text = [NSString stringWithFormat:@"%@-Detector", textField.text];
            self.detectorTrainer.name = self.nameTextField.text;
        }
    }

}

@end
