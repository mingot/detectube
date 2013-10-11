//
//  DetailViewController.m
//  DetectTube
//
//  Created by Josep Marc Mingot Hidalgo on 25/09/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "DetailViewController.h"
#import "ExecuteDetectorViewController.h"
#import "TrainingImagesCollectionViewController.h"
#import "ConstantsServer.h"
#import "AnnotatedImage.h"
#import "Box.h"
#import "User.h"
#import "ShareDetector.h"

@interface DetailViewController ()
{
    BOOL _isOwner;
    BOOL _detectorHasChanged;
    ShareDetector *_shareDetector;
}

@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.detector.name;
    self.imageView.image =[UIImage imageWithData:self.detector.image];
    self.authorLabel.text = [NSString stringWithFormat:@"Author: %@", self.detector.user.username];
    self.publicLabel.text = self.detector.isPublic.boolValue ? @"Public" : @"Private";
    
    _isOwner = [self.detector.user.username isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:USER_DEFAULTS_USERNAME]];
    if(!_isOwner){
        self.deleteButton.hidden = YES;
        self.shareButton.hidden = YES;
    }
    
    _shareDetector = [[ShareDetector alloc] init];
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if(_detectorHasChanged){
        NSLog(@"Updating detector to the server...");
        [_shareDetector shareDetector:self.detector toUpdate:YES];
    }
    
}

#pragma mark -
#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ExecuteDetector"]) {
        [(ExecuteDetectorViewController *)segue.destinationViewController setDetector:self.detector];
        
    }else if([[segue identifier] isEqualToString:@"Retrain"]){
        TrainingImagesCollectionViewController *vc = (TrainingImagesCollectionViewController *)segue.destinationViewController;
        vc.detector = self.detector;
    }
}

#pragma mark -
#pragma mark IBActions

- (IBAction)deleteAction:(id)sender
{
    [_shareDetector deleteDetector:self.detector];
    [self.delegate deleteDetector:self.detector];
    [self.navigationController popViewControllerAnimated:YES];
}


@end