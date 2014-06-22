//
//  ACMDemoVC.m
//  ACMWebView
//
//  Created by Michael on 2014-06-09.
//  Copyright (c) 2014 acmethunder. All rights reserved.
//

#import "ACMDemoVC.h"
#import "ACMWebView.h"

static CGFloat nav_bar_height;

@interface ACMDemoVC ()

- (void) hideNavbar;
- (void) showNavBar;

@property NSArray *items;
@property (nonatomic,weak) ACMWebTable *tableView;

@end

@implementation ACMDemoVC

#pragma mark Object Lifecycle

- (void) loadView {
    self.navigationController.navigationBar.translucent = NO;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGFloat screenWidth;
    CGFloat screenHeight;
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    if( (orientation == UIInterfaceOrientationPortrait) || (orientation == UIInterfaceOrientationPortraitUpsideDown) ) {
        screenWidth = CGRectGetWidth(screenBounds);
        screenHeight = CGRectGetHeight(screenBounds);
    }
    else {
        screenWidth = CGRectGetHeight(screenBounds);
        screenHeight = CGRectGetWidth(screenBounds);
    }
    
    screenHeight -= 64.0f;
    
    CGRect webFrame = CGRectMake(0.0f, 0.0f, screenWidth, screenHeight);
    ACMWebTable *webTable = [[ACMWebTable alloc] initWithFrame:webFrame];
    webTable.delegate = self;
    webTable.dataSource = self;
    webTable.backgroundColor = [UIColor redColor];
    self.view = webTable;
    self.tableView = webTable;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    nav_bar_height = CGRectGetHeight(self.navigationController.navigationBar.frame);
    
    
    if ( self.navigationController ) {
        self.navigationItem.title = @"ACM Web Table Demo VC";
    }
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *sample_one_url = [bundle URLForResource:@"sample_1" withExtension:@"txt"];
    NSString *sample_one_html = [[NSString alloc] initWithContentsOfURL:sample_one_url
                                                               encoding:NSUTF8StringEncoding
                                                                  error:NULL];
    
    NSURL *sample_two_url = [bundle URLForResource:@"sample_2" withExtension:@"txt"];
    NSString *sample_two_html = [[NSString alloc] initWithContentsOfURL:sample_two_url
                                                               encoding:NSUTF8StringEncoding
                                                                  error:NULL];
    
    NSURL *sample_three_url = [bundle URLForResource:@"sample_3" withExtension:@"txt"];
    NSString *sample_three_html = [[NSString alloc] initWithContentsOfURL:sample_three_url
                                                                 encoding:NSUTF8StringEncoding
                                                                    error:NULL];
    
    NSURL *sample_four_url = [bundle URLForResource:@"sample_4" withExtension:@"txt"];
    NSString *sample_four_html = [[NSString alloc] initWithContentsOfURL:sample_four_url
                                                                encoding:NSUTF8StringEncoding
                                                                   error:NULL];
    
    NSURL *sample_five_url = [bundle URLForResource:@"sample_5" withExtension:@"txt"];
    NSString *sample_five_html = [[NSString alloc] initWithContentsOfURL:sample_five_url
                                                                encoding:NSUTF8StringEncoding error:NULL];
    
    NSArray *items = @[
                       sample_one_html,
                       sample_two_html,
                       sample_three_html,
                       sample_four_html,
                       sample_five_html
                       ];
    
    self.items = items;
    [self.tableView reloadWebTable];
}

#pragma mark Layout

- (BOOL) shouldAutorotate {
    return YES;
}

- (NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

#pragma mark ADOPTED PROTOCOLS
#pragma mark ACMDataSource

- (NSInteger) tableCount {
    return self.items.count;
}

- (ACMWebView*) viewForIndex:(NSInteger)index {
    // usng a long, sonce this is just a demo and I want the CI builds to pass
    NSString *headerText = [[NSString alloc] initWithFormat:@"Item \'%ld\'", (long)index];
    
    CGFloat titleHeight = ( index % 2 == 0 ? 60.0f : 100.0f );
    CGRect labelFrame = CGRectMake(0.0f, 0.0, CGRectGetWidth(self.view.frame), titleHeight);
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    label.text = headerText;
    label.backgroundColor = [UIColor greenColor];
    
    NSString *content = self.items[index];
    NSString *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSURL *baseURL = [[NSURL alloc] initWithString:docs];
    ACMWebView *webView = [[ACMWebView alloc] initWithFrame:self.view.frame
                                                 webContent:content
                                                  titleView:label
                                                    baseURL:baseURL];
    

    if ( index < (self.items.count - 1) ) {
        CGFloat footerHeight = 60.0f;
        CGRect footerFrame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.frame), footerHeight);
        UILabel *footer = [[UILabel alloc] initWithFrame:footerFrame];
        // usng a long, sonce this is just a demo and I want the CI builds to pass
        footer.text = [[NSString alloc] initWithFormat:@"Footer \'%ld\'", (long)index];
        footer.textColor = [UIColor whiteColor];
        footer.backgroundColor = [UIColor orangeColor];
        webView.footerView = footer;
    }
    
    if ( index > 0 ) {
        CGFloat headerHeight = titleHeight;
        CGRect headerFrame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.frame), headerHeight);
        UILabel *header = [[UILabel alloc] initWithFrame:headerFrame];
        header.backgroundColor = [UIColor blueColor];
        header.textColor = [UIColor whiteColor];
        // usng a long, sonce this is just a demo and I want the CI builds to pass
        header.text = [[NSString alloc] initWithFormat:@"Header \'%ld\'", (long)index];
        webView.headerView = header;
    }
    
    return webView;
}

#pragma mark ACMWebTableDelegate

- (void) acmTable:(ACMWebTable *)acmView didStartDragging:(ACMWebTableScrollDirection)direction {
    if ( direction == ACMWebTableScrollDirectionUp ) {
//        [self hideNavbar];
    }
    else if ( direction == ACMWebTableScrollDirectionDown ) {
//        [self showNavBar];
    }
}

- (void) acmTable:(ACMWebTable *)acmView willDisplayView:(ACMWebView *)view {
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (BOOL) acmtable:(ACMWebTable *)acmView shouldLoadRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navType {
    return YES;
}

#pragma mark ACMDemoVC + PRIVATE

- (void) hideNavbar {
    if ( ! self.navigationController.navigationBar.hidden ) {
        [UIView animateWithDuration:0.5
                         animations:^{
                             CGRect screenFrame = [UIScreen mainScreen].bounds;
                             
                             UIDeviceOrientation orient = [UIDevice currentDevice].orientation;
                             if ( (orient == UIDeviceOrientationPortrait) || (orient == UIDeviceOrientationPortraitUpsideDown) ) {
                                 self.view.frame = screenFrame;
                             }
                             else {
                                 CGRect frame = CGRectMake(
                                                           0.0f,
                                                           0.0,
                                                           CGRectGetHeight(screenFrame),
                                                           CGRectGetWidth(screenFrame) );
                                 self.view.frame = frame;
                             }
                         } completion:^(BOOL finished) {
                             if ( finished ) {
                                 [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                                         withAnimation:UIStatusBarAnimationSlide];
                                 [self.navigationController setNavigationBarHidden:YES animated:YES];
                             }
                         }];
    }
}

- (void) showNavBar {
    if ( self.navigationController.navigationBar.hidden ) {
        [UIView animateWithDuration:0.5
                         animations:^{
                             CGRect screenFrame = [UIScreen mainScreen].bounds;
                             self.view.frame = CGRectMake(
                                                          CGRectGetMinX(self.view.frame),
                                                          CGRectGetMinY(self.view.frame),
                                                          CGRectGetWidth(screenFrame),
                                                          CGRectGetHeight(screenFrame) - nav_bar_height );
                         } completion:^(BOOL finished) {
                             if ( finished ) {
                                 [[UIApplication sharedApplication] setStatusBarHidden:FALSE
                                                                         withAnimation:UIStatusBarAnimationSlide];
                                 [self.navigationController setNavigationBarHidden:FALSE animated:TRUE];
                             }
                         }];
    }
}

@end
