//
//  JHFlipsideViewController.h
//  StreetWise
//
//  Created by James Hulley on 6/29/14.
//  Copyright (c) 2014 James Hulley. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JHFlipsideViewController;

@protocol JHFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(JHFlipsideViewController *)controller;
@end

@interface JHFlipsideViewController : UIViewController

@property (weak, nonatomic) id <JHFlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
