//
//  ACMWebTable.h
//  ACMWebView
//
//  Created by Michael De Wolfe on 2014-06-07.
//  Copyright (c) 2014 acmethunder. All rights reserved.
//

@import UIKit;

#pragma mark -
#pragma mark MACROS

#ifndef ACMLog
#if DEBUG
#define ACMLog(fmt, ...) NSLog((@"%s [Line %d] -> " fmt),__PRETTY_FUNCTION__,__LINE__,##__VA_ARGS__)
#else
#define ACMLog(fmt, ...) {}
#endif
#endif

#pragma mark FORWARDS

@class ACMWebView;

@protocol ACMWebTableDataSource;
@protocol ACMWebTableDelegate;

#pragma mark -
#pragma mark PUBLIC CONSTANTS
#pragma mark Integral Constants

typedef NS_ENUM(NSUInteger, ACMWebTableScrollDirection){
    ACMWebTableScrollDirectionUnknown,
    ACMWebTableScrollDirectionUp,
    ACMWebTableScrollDirectionDown
};

#pragma mark Floating Point

FOUNDATION_EXTERN const CGFloat kACMWebTableNoFooterOffset;
FOUNDATION_EXTERN const CGFloat kACMWebTableOffSCreenOffset;

FOUNDATION_EXTERN const NSTimeInterval kACMWebTableDefaultAnimationTime;

#pragma mark -
#pragma mark ACMWebTable
#pragma mark -

@interface ACMWebTable : UIView <UIWebViewDelegate,UIScrollViewDelegate>

#pragma mark PUBLIC INSTANCE METHODS
#pragma mark Table Management

- (void) reloadWebTable;
- (void) reloadWebTableAtIndex:(NSInteger)index;

#pragma mark PROPERTIES

@property (nonatomic) NSInteger currentIndex;

/**
 *  @brief
 *      Animation duration (in seconds) when transitioning between web views. Defaults to 0.5.
 */
@property (nonatomic) NSTimeInterval animationTime;

@property (nonatomic,strong) ACMWebView *currentView;
@property (nonatomic,strong) ACMWebView *previousView;
@property (nonatomic,strong) ACMWebView *nextView;

@property (nonatomic,weak) id<ACMWebTableDataSource> dataSource;
@property (nonatomic,weak) id<ACMWebTableDelegate> delegate;

@end

#pragma mark PROTOCOLS
#pragma mark ACMWebTableDataSource

@protocol ACMWebTableDataSource <NSObject>

@required
- (NSInteger) tableCount;
- (ACMWebView*) viewForIndex:(NSInteger)index;

@end

#pragma mark ACMWebTableDelegate

typedef NS_ENUM(NSInteger, ACMWebTableViewPosition){
    ACMWebTableViewPositionNext,
    ACMWebTableViewPositionPrevious
};

@protocol ACMWebTableDelegate <NSObject>

@optional
- (void) acmTable:(ACMWebTable*)acmView didScroll:(ACMWebTableScrollDirection)direction;
- (void) acmTable:(ACMWebTable*)acmView didDisplayCurrentView:(ACMWebView*)webView;
- (void) acmTable:(ACMWebTable*)acmView willDisplayView:(ACMWebView*)view;
- (void) acmTable:(ACMWebTable*)acmView failedToLoadRequest:(NSError*)error;
- (void) acmTable:(ACMWebTable*)acmView webViewDidFinishLoad:(ACMWebView*)view;


@required
- (BOOL) acmtable:(ACMWebTable*)acmView shouldLoadRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navType;

@end
