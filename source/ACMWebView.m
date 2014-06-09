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

NSString * const kACMWebViewHeaderKey = @"header";
NSString * const kACMWebViewFooterKey = @"footer";
//NSString * const kACMWebViewKey       = @"webView";

@implementation ACMWebView

#pragma mark PUBLIC INSTANCE METHODS
#pragma mark Object Lifecycle

- (instancetype) initWithFrame:(CGRect)frame {
    if ( (self = [super initWithFrame:frame]) ) {
        // Initialization code
    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame webContent:(id)content header:(UIView*)header footer:(UIView*)footer {
    NSParameterAssert( [content isKindOfClass:[NSString class]] || [content isKindOfClass:[NSURL class]] );
    
    if ( (self = [self initWithFrame:frame]) ) {
        self->_webContent = content;
        self.header       = header;
        self.footer       = footer;
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
    
    // layout footer
    UIView *footer = self.footer;
    if ( footer ) {
        
    }
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
