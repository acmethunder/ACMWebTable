//
//  ACMWebViewTests.m
//  ACMWebViewTests
//
//  Created by Michael De Wolfe on 2014-06-07.
//  Copyright (c) 2014 acmethunder. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ACMWebView.h"

static const CGFloat kACMScreenWidth = 320.0f;
static const CGFloat kACMScreenHeight = 504.0f;

@interface ACMWebViewTests : XCTestCase

@property NSBundle *bundle;
@property NSURL *sample_one_url;

@end

@implementation ACMWebViewTests

- (void)setUp {
    [super setUp];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    self.bundle = bundle;
    
    NSURL *sample_one_url = [bundle URLForResource:@"sample_1" withExtension:@"txt"];
    XCTAssertTrue( [sample_one_url isKindOfClass:[NSURL class]], @"" );
    self.sample_one_url = sample_one_url;
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark -
#pragma mark ACMWebView

- (void) testBuildACMWebViewNilHeader {
    NSError *string_error = nil;
    NSString *webContent = [[NSString alloc] initWithContentsOfURL:self.sample_one_url
                                                          encoding:NSUTF8StringEncoding
                                                             error:&string_error];
    XCTAssertNil( string_error, @"Samnple 1 Error: %@", string_error.debugDescription );
    
    ACMWebView *webView = nil;
    CGRect webFrame = CGRectMake( 0.0f, 0.0f, kACMScreenWidth, kACMScreenHeight );
    NSString *docsDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSURL *baseURL = [[NSURL alloc] initWithString:docsDir];
    XCTAssertNoThrow( webView = [[ACMWebView alloc] initWithFrame:webFrame
                                                       webContent:webContent
                                                           header:nil
                                                          baseURL:baseURL], @"" );
    XCTAssertNoThrow( [webView loadContent], @"" );
    
    webView.webContent = nil;
    XCTAssertNoThrow( [webView loadContent], @"" );
    
    webView.webContent = [NSNull null];
    XCTAssertThrows( [webView loadContent], @"" );
}

@end
