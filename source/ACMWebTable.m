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

- (ACMWebView*) buildNext;
- (ACMWebView*) buildPrevious;

@property (nonatomic) NSInteger currentIndex;
@property BOOL animating;

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
    [self.previousView removeFromSuperview];
    [self.currentView removeFromSuperview];
    [self.nextView removeFromSuperview];
    
    
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
        ACMWebView *previous = [self buildPrevious];
        self.previousView = previous;
    }
    
    NSInteger count = [self.dataSource tableCount];
    if ( (currentIndex > -1) && (currentIndex < (count - 1)) ) {
        ACMWebView *nextView = [self buildNext];
        nextView.delegate = self;
        nextView.scrollView.delegate = self;
        self.nextView = nextView;
    }
    
    [self coldSetUp];
}

- (void) reloadWebTableAtIndex:(NSInteger)index {
    NSInteger count = [self.dataSource tableCount];
    if ( (index >= count) && (index < count) ) {
        self.currentIndex = index;
        [self reloadWebTable];
    }
}

#pragma mark ADOPTED PROTOCOLS
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return [self.delegate acmtable:self shouldLoadRequest:request navigationType:navigationType];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
//    webView.userInteractionEnabled = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if ( [webView isKindOfClass:[ACMWebView class]] ) {
//        ACMWebView *tempWeb =  (ACMWebView*)webView;
//        CGFloat height = CGRectGetHeight(tempWeb.header.frame) + tempWeb.scrollView.contentSize.height;
//        tempWeb.scrollView.contentSize = CGSizeMake(CGRectGetWidth(tempWeb.frame), height);
//        tempWeb.scrollView.contentInset = UIEdgeInsetsMake(CGRectGetHeight(tempWeb.header.frame), 0.0f, 0.0f, 0.0f);
    }
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
    CGFloat scrollOffset = scrollView.contentOffset.y - scrollView.contentSize.height + CGRectGetHeight(scrollView.frame);
    if ( scrollOffset > 60.0f ) {
        [self moveToNext];
    }
    else if ( self.previousView && (scrollView.contentOffset.y < (60.0f * (-1))) ) {
//        [self moveToprevious];
    }
}

#pragma mark ACMWebTable + PRIVATE

- (void) coldSetUp {
    ACMWebView *current = self.currentView;
    
    CGFloat width = CGRectGetWidth(current.frame);
    CGFloat height = CGRectGetHeight(current.frame);
    
    CGRect frame = CGRectMake(0.0f, 0.0f, width, height );
    current.frame = frame;
    
    if ( ! current.superview ) {
        [self addSubview:current];
    }
    
    ACMWebView *previous = self.previousView;
    
    CGRect previousFrame = previous.frame;
    CGRect frameNew = CGRectMake(
                                 0.0f,
                                 CGRectGetHeight(previousFrame) * (-1),
                                 CGRectGetWidth(previous.frame),
                                 CGRectGetHeight(previous.frame) );
    previous.frame = frameNew;
    
    if ( ! previous.superview ) {
        [self addSubview:previous];
    }
    
    ACMWebView *next = self.nextView;
    CGRect nextFrame = next.frame;
    CGRect nextFrameNew = CGRectMake(
                                     0.0f,
                                     CGRectGetHeight(current.frame),
                                     CGRectGetWidth(nextFrame),
                                     CGRectGetHeight(nextFrame) );
    next.frame = nextFrameNew;
    
    if (! next.superview ) {
        [self addSubview:next];
    }
    
    [self scrollCurrentToTop];
}

- (void) moveToNext {
    if ( (! self.animating) && self.nextView ) {
        self.animating = YES;
        __weak typeof(self.nextView) weakNext       = self.nextView;
        __weak typeof(self.currentView) weakCurrent = self.currentView;
        __weak typeof(self) weakSelf                = self;
        
        [UIView animateWithDuration:0.5
                         animations:^{
                             CGRect currentFrame = weakCurrent.frame;
                             CGFloat currentHeight = CGRectGetHeight(currentFrame);
                             weakCurrent.frame = CGRectMake(
                                                            CGRectGetMinX(currentFrame),
                                                            currentHeight * (-1),
                                                            CGRectGetWidth(currentFrame),
                                                            currentHeight );
                             
                             CGRect nextFrame = weakNext.frame;
                             CGRect selfFrame = weakSelf.frame;
                             weakNext.frame = CGRectMake(
                                                         CGRectGetMinX(nextFrame),
                                                         0.0f,
                                                         CGRectGetWidth(selfFrame),
                                                         CGRectGetHeight(selfFrame) );
                         } completion:^(BOOL finished) {
                             if ( finished ) {
                                 [weakSelf.previousView removeFromSuperview];
                                 weakSelf.previousView = weakCurrent;
                                 weakSelf.currentView = weakNext;
                                 weakSelf.currentIndex++;
                                 ACMWebView *nextNew = [weakSelf buildNext];
                                 
                                 if ( nextNew ) {
                                     CGRect nextFrame = nextNew.frame;
                                     nextNew.frame = CGRectMake(
                                                                CGRectGetMinX(nextFrame),
                                                                CGRectGetHeight(weakSelf.frame),
                                                                CGRectGetWidth(nextFrame),
                                                                CGRectGetHeight(nextFrame) );
                                     [weakSelf addSubview:nextNew];
                                 }
                                 
                                 weakSelf.nextView = nextNew;
                                 weakSelf.animating = NO;
                             }
                         }];
    }
}

- (void) moveToprevious {
//    if ( (! self.animating) && self.nextView ) {
//        self.animating = YES;
//        __weak typeof(self.previousView) weakPrevious = self.previousView;
//        __weak typeof(self.currentView) weakCurrent   = self.currentView;
//        __weak typeof(self) weakSelf                  = self;
//        
//        [UIView animateWithDuration:0.25
//                         animations:^{
//                             CGRect currentFrame = weakCurrent.frame;
//                             weakCurrent.frame = CGRectMake(
//                                                            CGRectGetMinX(currentFrame),
//                                                            CGRectGetHeight(currentFrame),
//                                                            CGRectGetWidth(currentFrame),
//                                                            CGRectGetHeight(currentFrame) );
//                             weakPrevious.frame = CGRectMake(
//                                                             CGRectGetMinX(weakSelf.frame),
//                                                             CGRectGetMinY(weakSelf.frame),
//                                                             CGRectGetWidth(weakSelf.frame),
//                                                             CGRectGetHeight(weakSelf.frame) );
//                         } completion:^(BOOL finished) {
//                             if ( finished ) {
//                                 [weakSelf.nextView removeFromSuperview];
//                                 weakSelf.nextView = weakCurrent;
//                                 weakSelf.currentView = weakPrevious;
//                                 weakSelf.currentIndex--;
//                                 ACMWebView *previousNew = [weakSelf buildPrevious];
//                                 
//                                 if ( previousNew ) {
//                                     previousNew.delegate = weakSelf;
//                                     previousNew.scrollView.delegate = weakSelf;
//                                     previousNew.frame = CGRectMake(
//                                                                    CGRectGetMinX(weakSelf.frame),
//                                                                    CGRectGetHeight(previousNew.frame),
//                                                                    CGRectGetWidth(previousNew.frame),
//                                                                    CGRectGetHeight(previousNew.frame) );
//                                     [weakSelf addSubview:previousNew];
//                                 }
//                                 
//                                 weakSelf.previousView = previousNew;
//                                 weakSelf.animating = NO;
//                                 
//                                 [weakSelf scrollCurrentToTop];
//                             }
//                         }];
//    }
}

- (void) scrollCurrentToTop {
    self.currentView.scrollView.contentOffset = CGPointMake(0.0f, 0.0f);
    
    if ( [self.delegate respondsToSelector:@selector(acmTable:didDisplayCurrentView:)] ) {
        [self.delegate acmTable:self didDisplayCurrentView:self.currentView];
    }
}

- (ACMWebView*) buildNext {
    NSInteger index = self.currentIndex;
    NSInteger count = [self.dataSource tableCount];
    
    ACMWebView *webView = nil;
    if ( (index > -1) && (index - (count - 1)) ) {
        webView = [self.dataSource viewForIndex:(index + 1)];
        
        if ( webView ) {
            webView.delegate = self;
            webView.scrollView.delegate = self;
            [webView loadContent];
        }
    }
    
    return webView;
}

- (ACMWebView*) buildPrevious {
    NSInteger index = self.currentIndex;
    
    ACMWebView *webView = nil;
    if ( index > 0 ) {
        webView = [self.dataSource viewForIndex:(index - 1)];
        
        if ( webView ) {
            [webView loadContent];
        }
    }
    
    return webView;
}

@end
