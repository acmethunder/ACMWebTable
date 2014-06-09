//
//  ACMWebTable.h
//  ACMWebView
//
//  Created by Michael De Wolfe on 2014-06-07.
//  Copyright (c) 2014 acmethunder. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark FORWARDS

@class ACMWebView;
@protocol ACMWebTableDataSource;
@protocol ACMWebTableDelegate;

#pragma mark -
#pragma mark ACMWebTable
#pragma mark -

@interface ACMWebTable : UIView

@property (nonatomic,strong) ACMWebView *currentView;
@property (nonatomic,strong) ACMWebView *previousView;
@property (nonatomic,strong) ACMWebView *nextView;

@property (nonatomic,weak) id<ACMWebTableDataSource> dataSource;
@property (nonatomic,weak) id<ACMWebTableDelegate> delegate;

@end

#pragma mark PROTOCOLS

@protocol ACMWebTableDataSource <NSObject>

@required
- (ACMWebView*) viewForIndex:(NSUInteger)index;


@end

@protocol ACMWebTableDelegate <NSObject>

- (BOOL) webTableShouldLoadRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType;

@end
