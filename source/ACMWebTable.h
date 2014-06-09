//
//  ACMWebTable.h
//  ACMWebView
//
//  Created by Michael De Wolfe on 2014-06-07.
//  Copyright (c) 2014 acmethunder. All rights reserved.
//

@import UIKit;

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

#pragma mark -
#pragma mark ACMWebTable
#pragma mark -

@interface ACMWebTable : UIView <UIWebViewDelegate,UIScrollViewDelegate>

#pragma mark PUBLIC INSTANCE METHODS
#pragma mark Table Management

- (void) reloadWebTable;

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
- (NSUInteger) tableCount;
- (ACMWebView*) viewForIndex:(NSUInteger)index;

@end

#pragma mark ACMWebTableDelegate

@protocol ACMWebTableDelegate <NSObject>

@optional
- (void) acmTable:(ACMWebTable*)acmView didStartDragging:(ACMWebTableScrollDirection)direction;
- (void) acmTable:(ACMWebTable*)acmView didDisplayCurrentView:(ACMWebView*)webView;


@required
- (BOOL) acmtable:(ACMWebTable*)acmView shouldLoadRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navType;

@end
