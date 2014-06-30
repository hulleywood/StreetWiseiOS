//
//  JHMainViewController.h
//  StreetWise
//
//  Created by James Hulley on 6/29/14.
//  Copyright (c) 2014 James Hulley. All rights reserved.
//

#import "JHFlipsideViewController.h"

@interface JHMainViewController : UIViewController <JHFlipsideViewControllerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;

@end
