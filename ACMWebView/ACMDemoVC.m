//
//  ACMDemoVC.m
//  ACMWebView
//
//  Created by Michael on 2014-06-09.
//  Copyright (c) 2014 acmethunder. All rights reserved.
//

#import "ACMDemoVC.h"
#import "ACMWebView.h"

@interface ACMDemoVC ()

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    if ( self.navigationController ) {
        self.navigationItem.title = @"ACM Demo VC";
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

- (ACMWebView*) viewForIndex:(NSUInteger)index {
    NSString *headerText = [[NSString alloc] initWithFormat:@"Item \'%d\'", index];
    
    CGRect labelFrame = CGRectMake(0.0f, 0.0, CGRectGetWidth(self.view.frame), 60.0f);
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
    

//    UIView *footer = [[UILabel alloc] initWithFrame:<#(CGRect)#>]
    
    
    return webView;
}

#pragma mark ACMWebTableDelegate

- (BOOL) acmtable:(ACMWebTable *)acmView shouldLoadRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navType {
    return YES;
}

@end
