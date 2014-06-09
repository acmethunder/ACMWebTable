//
//  ACMDemoVC.m
//  ACMWebView
//
//  Created by Michael on 2014-06-09.
//  Copyright (c) 2014 acmethunder. All rights reserved.
//

#import "ACMDemoVC.h"

@interface ACMDemoVC ()

@end

@implementation ACMDemoVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    if ( self.navigationController ) {
        self.navigationItem.title = @"ACM Demo VC";
    }
}

@end
