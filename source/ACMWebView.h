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

FOUNDATION_EXTERN NSString * const kACMWebTitleViewKey;
FOUNDATION_EXTERN NSString * const kACMWebViewHeaderViewKey;
FOUNDATION_EXTERN NSString * const kACMWebViewFooterViewKey;

#pragma mark Exceptions

FOUNDATION_EXTERN NSString * const kACMWebViewExceptionBadContentName;
FOUNDATION_EXTERN NSString * const kACMWebViewExceptionBadContentReason;
FOUNDATION_EXTERN NSString * const kACMWebViewExceptionContentClassKey;

#pragma mark Notifications

FOUNDATION_EXTERN NSString * const kACMWebViewTouchDownNotificationName;

#pragma mark -
#pragma mark ACMWebView
#pragma mark -

@interface ACMWebView : UIWebView <UIGestureRecognizerDelegate>

#pragma mark PUBLIC INSTANCE METHODS
#pragma mark Object Lifecycle

- (instancetype) initWithFrame:(CGRect)frame webContent:(id)content titleView:(UIView*)titleView;
- (instancetype) initWithFrame:(CGRect)frame webContent:(id)content titleView:(UIView *)titleView baseURL:(NSURL*)baseURL;

#pragma mark Content Management

/**
 *  @method
 *      loadContent
 *  @brief
 *      Loads the receiver's HTML content.
 *  @discussion
 *      See 'webContent' for for supported types.
 *  @throw
 *      'kACMWebViewExceptionsBadContentReason' if 'webContent' is not one of the supported types.
 */
- (void) loadContent;

#pragma mark PUBLIC PROPERTIES

/**
 *  @property
 *      headerContentHeight
 *  @brief
 *      Returns the height of 'titleView' plus 'headerView.'
 */
@property (nonatomic,readonly) CGFloat headerContentHeight;

@property (nonatomic,strong) UIView *titleView;
@property (nonatomic,strong) UIView *headerView;
@property (nonatomic,strong) UIView *footerView;

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
