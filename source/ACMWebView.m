//
//  ACMWebView.m
//  ACMWebView
//
//  Created by Michael De Wolfe on 2014-06-07.
//  Copyright (c) 2014 acmethunder. All rights reserved.
//

#import "ACMWebView.h"

#pragma mark -
#pragma mark CONSTANTS
#pragma mark Property Keys

NSString * const kACMWebViewHeaderKey       = @"header";
NSString * const kACMWebViewPreviousViewKey = @"previousView";
NSString * const kACMWebViewNextViewKey     = @"nextView";

@implementation ACMWebView

#pragma mark PUBLIC INSTANCE METHODS
#pragma mark Object Lifecycle

- (instancetype) initWithFrame:(CGRect)frame webContent:(id)content header:(UIView*)header {
    NSParameterAssert( [content isKindOfClass:[NSString class]] || [content isKindOfClass:[NSURL class]] );
    
    if ( (self = [self initWithFrame:frame]) ) {
        self->_webContent = content;
        self.header       = header;
    }
    
    return self;
}

#pragma mark Layout

- (void) layoutSubviews {
    // layout header
    UIView *header = self.header;
    if ( header ) {
        CGRect headerFrame = header.frame;
        header.frame = CGRectMake( 0.0f, 0.0f, CGRectGetWidth(headerFrame), CGRectGetHeight(headerFrame) );
    }
}

#pragma mark ADOPTED PROTOCOLS
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}

#pragma mark PUBLIC PROPERTIES

- (void) setHeader:(UIView *)header {
    [self willChangeValueForKey:kACMWebViewHeaderKey];
    
    if ( self->_header ) {
        [self->_header removeFromSuperview];
    }

    self->_header = header;
    
    [self didChangeValueForKey:kACMWebViewHeaderKey];
    
    [self addSubview:self->_header];
}

@end
