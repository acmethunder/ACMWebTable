//
//  ACMWebView.h
//  ACMWebView
//
//  Created by Michael De Wolfe on 2014-06-07.
//  Copyright (c) 2014 acmethunder. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark -
#pragma mark CONSTANTS
#pragma mark Property Keys

FOUNDATION_EXTERN NSString * const kACMWebViewHeaderKey;
FOUNDATION_EXTERN NSString * const kACMWebViewPreviousViewKey;
FOUNDATION_EXTERN NSString * const kACMWebViewNextViewKey;

#pragma mark Exceptions

FOUNDATION_EXTERN NSString * const kACMWebViewExceptionBadContentName;
FOUNDATION_EXTERN NSString * const kACMWebViewExceptionBadContentReason;
FOUNDATION_EXTERN NSString * const kACMWebViewExceptionContentClassKey;

#pragma mark -
#pragma mark ACMWebView
#pragma mark -

@interface ACMWebView : UIWebView <UIWebViewDelegate>

#pragma mark PUBLIC INSTANCE METHODS
#pragma mark Object Lifecycle

- (instancetype) initWithFrame:(CGRect)frame webContent:(id)content header:(UIView*)header;
- (instancetype) initWithFrame:(CGRect)frame webContent:(id)content header:(UIView *)header baseURL:(NSURL*)baseURL;

#pragma mark Content Management

- (void) loadContent;

#pragma mark PUBLIC PROPERTIES

@property (nonatomic,strong) UIView *header;
@property (nonatomic,strong) UIView *previousView;
@property (nonatomic,strong) UIView *nextView;

/**
 *  @property
 *      webContent
 *  @discussion
 *      'webContent' must either be an instance of 'NSString', which is the html content to display.
 *      This is used in conjunction with 'baseURL,' or an instance of 'NSURL.'
 *
 *      In the case of 'webContent' being an instance of NSURL, an NSURLRequest is created, and the web
 *      content loaded from the rrequest. 'baseURL' is ignored.
 */
@property (nonatomic,strong) id webContent;
@property (nonatomic,strong) NSURL *baseURL;


@end
