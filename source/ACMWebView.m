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

#pragma mark Exception Names

NSString * const kACMWebViewExceptionBadContentName   = @"com.acmwebview.exception.badcontent";
NSString * const kACMWebViewExceptionBadContentReason = @"\'webContent\' must be either an instance of \'NSString,\' \'NSURL,\' or \'nil.\'";
NSString * const kACMWebViewExceptionContentClassKey  = @"com.acmwebview.exception.contentclass.key";

#pragma mark -
#pragma mark ACMWebView + Private

@interface ACMWebView ()

#pragma mark Content

- (void) loadStringContent;
- (void) loadURLContent;

@end

#pragma mark -
#pragma mark ACMWebView
#pragma mark -

@implementation ACMWebView

#pragma mark PUBLIC INSTANCE METHODS
#pragma mark Object Lifecycle

- (instancetype) initWithFrame:(CGRect)frame webContent:(id)content header:(UIView*)header {
    NSParameterAssert( [content isKindOfClass:[NSString class]] || [content isKindOfClass:[NSURL class]] );
    
    if ( (self = [self initWithFrame:frame]) ) {
        self->_webContent = content;
        self.titleView       = header;
    }
    
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame webContent:(id)content header:(UIView *)header baseURL:(NSURL*)baseURL {
    if ( (self = [self initWithFrame:frame webContent:content header:header]) ) {
        self->_baseURL = baseURL;
    }
    
    return self;
}

#pragma mark Layout

- (void) layoutSubviews {
    // layout header
    UIView *header = self.titleView;
    if ( header ) {
        CGRect headerFrame = header.frame;
        header.frame = CGRectMake( 0.0f, 0.0f, CGRectGetWidth(headerFrame), -CGRectGetHeight(headerFrame) );
    }
    
    self.scrollView.contentOffset = CGPointMake( 0.0f, CGRectGetHeight(self.titleView.frame) );
    self.scrollView.contentInset = UIEdgeInsetsMake(CGRectGetHeight(header.frame), 0.0f, 0.0f, 0.0f);
}

- (void) willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
}

#pragma mark Content Management

- (void) loadContent {
    id content = self.webContent;
    if ( [content isKindOfClass:[NSString class]] ) {
        [self loadStringContent];
    }
    else if ( [content isKindOfClass:[NSURL class]] ) {
        [self loadURLContent];
    }
    else if ( content != nil ) {
        NSDictionary *userInfo = @{
                                   kACMWebViewExceptionContentClassKey : NSStringFromClass([content class] )
                                   };
        NSException *exception = [NSException exceptionWithName:kACMWebViewExceptionBadContentName
                                                         reason:kACMWebViewExceptionBadContentReason
                                                       userInfo:userInfo];
        [exception raise];
    }
}

#pragma mark PUBLIC PROPERTIES

- (void) setTitleView:(UIView *)header {
    [self willChangeValueForKey:kACMWebViewHeaderKey];
    
    if ( self->_header ) {
        [self->_header removeFromSuperview];
    }

    if ( header ) {
        [self.scrollView addSubview:header];
    }
    
    self->_header = header;
    
    [self didChangeValueForKey:kACMWebViewHeaderKey];
}

- (void) setWebContent:(id)webContent {
    if ( (! webContent) || [webContent isKindOfClass:[NSString class]] || [webContent isKindOfClass:[NSURL class]] ) {
        self->_webContent = webContent;
    }
}

#pragma mark PRIVATE INSTANCE METHODS

#pragma mark Content

- (void) loadStringContent {
    NSString *content = self.webContent;
    NSParameterAssert( [content isKindOfClass:[NSString class]] );
    [self loadHTMLString:content baseURL:self.baseURL];
}

- (void) loadURLContent {
    NSURL *content = self.webContent;
    NSParameterAssert( [content isKindOfClass:[NSURL class]] );
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:content];
    [self loadRequest:request];
}


@end
