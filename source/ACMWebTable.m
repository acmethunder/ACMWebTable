//
//  ACMWebTable.m
//  ACMWebView
//
//  Created by Michael De Wolfe on 2014-06-07.
//  Copyright (c) 2014 acmethunder. All rights reserved.
//

#import "ACMWebTable.h"
#import "ACMWebView.h"

#pragma mark ACMWebTable + private

@interface ACMWebTable ()

- (void) coldSetUp;
- (void) moveToNext;
- (void) moveToprevious;

- (void) scrollCurrentToTop;

@property (nonatomic) NSInteger currentIndex;

@end

#pragma mark -
#pragma mark ACMWebTable
#pragma mark -

@implementation ACMWebTable

- (instancetype) initWithFrame:(CGRect)frame dataSource:(id<ACMWebTableDataSource>)dataSource delegate:(id<ACMWebTableDelegate>)delegate {
    if ( (self = [self initWithFrame:frame]) ) {
        self->_dataSource = dataSource;
        self->_delegate   = delegate;
        
        self->_currentIndex = 0;
    }
    
    return self;
}

#pragma mark PUBLIC INSTANCE METHODS
#pragma mark Table Management

- (void) reloadWebTable {
    NSInteger currentIndex = self.currentIndex;
    ACMWebView *current = [self.dataSource viewForIndex:self.currentIndex];
    current.delegate = self;
    current.scrollView.delegate = self;
    [current loadContent];
    self.currentView = current;
    
    if ( currentIndex < 1 ) {
        [self.previousView removeFromSuperview];
        self.previousView = nil;
    }
    else if (currentIndex > 0 ) {
        ACMWebView *previous = [self.dataSource viewForIndex:(currentIndex - 1)];
        [previous loadContent];
        self.previousView = previous;
    }
    
    [self coldSetUp];
}

#pragma mark ADOPTED PROTOCOLS
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return [self.delegate acmtable:self shouldLoadRequest:request navigationType:navigationType];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    if ( [webView isKindOfClass:[ACMWebView class]] ) {
//        ACMWebView *tempWeb =  (ACMWebView*)webView;
//        CGFloat height = CGRectGetHeight(tempWeb.header.frame) + tempWeb.scrollView.contentSize.height;
//        tempWeb.scrollView.contentSize = CGSizeMake(CGRectGetWidth(tempWeb.frame), height);
//        tempWeb.scrollView.contentInset = UIEdgeInsetsMake(CGRectGetHeight(tempWeb.header.frame), 0.0f, 0.0f, 0.0f);
//    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
}

#pragma mark UIScrollViewDelegate

- (void )scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    CGPoint point = [scrollView.panGestureRecognizer translationInView:scrollView.superview];

    ACMWebTableScrollDirection direction = ACMWebTableScrollDirectionUnknown;
    if ( point.y <= 0.0f ) {
        direction = ACMWebTableScrollDirectionUp;
    }
    else if ( point.y > 0.0f ) {
        direction = ACMWebTableScrollDirectionDown;
    }
    
    if ( [self.delegate respondsToSelector:@selector(acmTable:didStartDragging:)] ) {
        [self.delegate acmTable:self didStartDragging:direction];
    }
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

#pragma mark ACMWebTable + PRIVATE

- (void) coldSetUp {
    ACMWebView *current = self.currentView;
    
    CGFloat width = CGRectGetWidth(current.frame);
    CGFloat height = CGRectGetHeight(current.frame);
    
    if ( ! current.superview ) {
        CGRect frame = CGRectMake(0.0f, 0.0f, width, height );
        current.frame = frame;
        [self addSubview:current];
    }
    
    [self scrollCurrentToTop];
}

- (void) moveToNext {
    
}

- (void) moveToprevious {
    
}

- (void) scrollCurrentToTop {
    self.currentView.scrollView.contentOffset = CGPointMake(0.0f, 0.0f);
    
    if ( [self.delegate respondsToSelector:@selector(acmTable:didDisplayCurrentView:)] ) {
        [self.delegate acmTable:self didDisplayCurrentView:self.currentView];
    }
}

@end
