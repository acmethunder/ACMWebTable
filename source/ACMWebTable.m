//
//  ACMWebTable.m
//  ACMWebView
//
//  Created by Michael De Wolfe on 2014-06-07.
//  Copyright (c) 2014 acmethunder. All rights reserved.
//

#import "ACMWebTable.h"
#import "ACMWebView.h"

#pragma mark PUBLIC CONSTANTS
#pragma mark Floating Point

const CGFloat kACMWebTableNoFooterOffset                     = 60.0f;
const CGFloat kACMWebTableOffScreenOffset                    = 0.0f;

const NSTimeInterval kACMWebTableDefaultAnimationTime        = 0.5;
const NSTimeInterval kACMWebTableDelayPreviousAndNextLoading = 0.2;

#pragma mark ACMWebTable + private

@interface ACMWebTable ()

- (void) handleOrientationChange:(NSNotification*)notice;
- (void) coldSetUpScroll:(BOOL)shouldScroll;
- (void) moveToNext;
- (void) moveToPrevious;

- (void) scrollCurrentToTopAnimated:(BOOL)animated;
- (void) scrollWebViewToTop:(ACMWebView*)webView animated:(BOOL)animated;

- (ACMWebView*) buildNext;
- (ACMWebView*) buildPrevious;

@property BOOL animating;

@end

#pragma mark -
#pragma mark ACMWebTable
#pragma mark -

@implementation ACMWebTable

#pragma mark PUBLIC INSTANCE METHODS
#pragma mark Object Lifecycle

- (instancetype) initWithFrame:(CGRect)frame {
    if ( (self = [super initWithFrame:frame]) ) {
        self->_currentIndex = 0;
        self->_animationTime = kACMWebTableDefaultAnimationTime;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleOrientationChange:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    }
    
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame dataSource:(id<ACMWebTableDataSource>)dataSource delegate:(id<ACMWebTableDelegate>)delegate {
    if ( (self = [self initWithFrame:frame]) ) {
        self->_dataSource = dataSource;
        self->_delegate   = delegate;
    }
    
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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
    
    // Load next and previous with some delay
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kACMWebTableDelayPreviousAndNextLoading * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (currentIndex > 0 ) {
            ACMWebView *previous = [self buildPrevious];
            self.previousView = previous;
        }
        
        NSInteger count = [self.dataSource tableCount];
        if ( (currentIndex > -1) && (currentIndex < (count - 1)) ) {
            ACMWebView *nextView = [self buildNext];
            self.nextView = nextView;
        }
        
        [self coldSetUpScroll:NO];
    });
    
    [self coldSetUpScroll:YES];
}

- (void) reloadWebTableAtIndex:(NSInteger)index {
    NSInteger count = [self.dataSource tableCount];
    if ( (index >= 0) && (index < count) ) {
        self.currentIndex = index;
        [self reloadWebTable];
    }
}

#pragma mark Properties

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self coldSetUpScroll:NO];
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
//        [tempWeb setNeedsLayout];
//    }
    [webView setNeedsLayout];
    
    if ( webView == self.currentView ) {
        [self scrollCurrentToTopAnimated:NO];
    }
    
    if ( [self.delegate respondsToSelector:@selector(acmTable:webViewDidFinishLoad:)] ) {
        [self.delegate acmTable:self webViewDidFinishLoad:self.currentView];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    id<ACMWebTableDelegate> delegate = self.delegate;
    if ( [delegate respondsToSelector:@selector(acmTable:failedToLoadRequest:)] ) {
        [delegate acmTable:self failedToLoadRequest:error];
    }
}

#pragma mark UIScrollViewDelegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    ACMLog( @"Offset => %f, Content Size => %f", self.currentView.scrollView.contentOffset.y, self.currentView.scrollView.contentSize.height );
    ACMWebTableScrollDirection direction = ACMWebTableScrollDirectionUnknown;
    if( [scrollView.panGestureRecognizer translationInView:self.currentView].y  < 0.0f ) {
        direction = ACMWebTableScrollDirectionUp;
    } else if ([scrollView.panGestureRecognizer translationInView:self.currentView].y  > 0.0f  ) {
        direction = ACMWebTableScrollDirectionDown;
    }
    if ( [self.delegate respondsToSelector:@selector(acmTable:didScroll:)] ) {
        [self.delegate acmTable:self didScroll:direction];
    }
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ( decelerate && scrollView == self.currentView.scrollView ) {
        CGFloat scrollOffset = scrollView.contentOffset.y - scrollView.contentSize.height + CGRectGetHeight(scrollView.frame);
        if ( scrollOffset > MAX(CGRectGetHeight(self.currentView.footerView.frame), kACMWebTableNoFooterOffset) ) {
            [self moveToNext];
        }
        else if ( scrollView.contentOffset.y < (-self.currentView.headerContentHeight) ) {
            [self moveToPrevious];
        }

    }
}

#pragma mark ACMWebTable + PRIVATE

- (void) handleOrientationChange:(NSNotification*)notice {
    [self coldSetUpScroll:NO];
}

- (void) coldSetUpScroll:(BOOL)shouldScroll {
    ACMWebView *current = self.currentView;
    
    CGFloat width = CGRectGetWidth(current.frame);
    CGFloat height = CGRectGetHeight(current.frame);
    
    CGRect frame = CGRectMake(0.0f, 0.0f, width, height );
    current.frame = frame;
    
    if ( ! current.superview ) {
        [self addSubview:current];
    }
    
    ACMWebView *previous = self.previousView;
    
    if ( previous ) {
        CGRect previousFrame = previous.frame;
        CGRect frameNew = CGRectMake(
                                     0.0f,
                                     CGRectGetHeight(previousFrame) * (-1) - kACMWebTableOffScreenOffset,
                                     CGRectGetWidth(previous.frame),
                                     CGRectGetHeight(previous.frame) );
        previous.frame = frameNew;
        
        if ( ! previous.superview ) {
            [self addSubview:previous];
        }
    }
    
    ACMWebView *next = self.nextView;
    if ( next ) {
        CGRect nextFrame = next.frame;
        CGRect nextFrameNew = CGRectMake(
                                         0.0f,
                                         CGRectGetHeight(current.frame) + kACMWebTableOffScreenOffset,
                                         CGRectGetWidth(nextFrame),
                                         CGRectGetHeight(nextFrame) );
        next.frame = nextFrameNew;
        
        if (! next.superview ) {
            [self addSubview:next];
        }
    }
    
    if ( shouldScroll ) {
        [self scrollCurrentToTopAnimated:NO];
    }
}

- (UIImage *)screenshotBeforeUpdate:(BOOL)beforeUpdate {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0f);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:!beforeUpdate];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
    image = [UIImage imageWithData:imageData scale:[[UIScreen mainScreen] scale]];
    return image;
}


- (void) moveToNext {
    if ( (! self.animating) && self.nextView ) {
        self.animating = YES;
        
        if ( [self.delegate respondsToSelector:@selector(acmTable:willDisplayView:)] ) {
            [self.delegate acmTable:self willDisplayView:self.nextView];
        }
        
        ACMWebView *nextView = self.nextView;
        [self scrollWebViewToTop:nextView animated:FALSE];
        
        __weak typeof(nextView) weakNext            = nextView;
        __weak typeof(self.currentView) weakCurrent = self.currentView;
        __weak typeof(self) weakSelf                = self;
        
        [self sendSubviewToBack:_currentView];

        UIImageView *currentSnapshot = [[UIImageView alloc] initWithImage:[self screenshotBeforeUpdate:YES]];
        [self addSubview:currentSnapshot];
        
        [UIView animateWithDuration:self.animationTime
                         animations:^{
                             CGRect currentFrame = currentSnapshot.frame;
                             CGFloat currentHeight = CGRectGetHeight(currentFrame);
                             currentSnapshot.frame = CGRectMake(
                                                                CGRectGetMinX(currentFrame),
                                                                -currentHeight - kACMWebTableOffScreenOffset,
                                                                CGRectGetWidth(currentFrame),
                                                                currentHeight );
                             weakCurrent.frame = currentSnapshot.frame;

                             CGRect nextFrame = weakNext.frame;
                             CGRect selfFrame = weakSelf.frame;
                             weakNext.frame = CGRectMake(
                                                         CGRectGetMinX(nextFrame),
                                                         0.0f,
                                                         CGRectGetWidth(selfFrame),
                                                         CGRectGetHeight(selfFrame) );
                         } completion:^(BOOL finished) {
                             if ( finished ) {
                                 weakCurrent.frame = currentSnapshot.frame;
                                 [currentSnapshot removeFromSuperview];
                                 [weakSelf.previousView removeFromSuperview];
                                 weakSelf.previousView = weakCurrent;
                                 weakSelf.currentView = weakNext;
                                 weakSelf.currentIndex++;
                                 ACMWebView *nextNew = [weakSelf buildNext];
                                 
                                 if ( nextNew ) {
                                     CGRect nextFrame = nextNew.frame;
                                     nextNew.frame = CGRectMake(
                                                                CGRectGetMinX(nextFrame),
                                                                CGRectGetHeight(weakSelf.frame) + kACMWebTableOffScreenOffset,
                                                                CGRectGetWidth(nextFrame),
                                                                CGRectGetHeight(nextFrame) );
                                     [weakSelf addSubview:nextNew];
                                 }
                                 
                                 weakSelf.nextView = nextNew;
                                 weakSelf.animating = NO;
                                 
                                 [weakSelf scrollCurrentToTopAnimated:YES];
                             }
                         }];
    }
}

- (void) moveToPrevious {
    if ( (! self.animating) && self.previousView ) {
        self.animating = YES;
        
        if ( [self.delegate respondsToSelector:@selector(acmTable:willDisplayView:)] ) {
            [self.delegate acmTable:self willDisplayView:self.previousView];
        }
        
        ACMWebView *previous = self.previousView;
        [self scrollWebViewToTop:previous animated:FALSE];
        
        __weak typeof(previous) weakPrevious          = previous;
        __weak typeof(self.currentView) weakCurrent   = self.currentView;
        __weak typeof(self) weakSelf                  = self;
        
        [self sendSubviewToBack:_currentView];
        
        UIImageView *currentSnapshot = [[UIImageView alloc] initWithImage:[self screenshotBeforeUpdate:YES]];
        [self addSubview:currentSnapshot];
        
        [UIView animateWithDuration:self.animationTime
                         animations:^{
                             CGRect currentFrame = currentSnapshot.frame;
                             CGFloat currentHeight = CGRectGetHeight(weakSelf.frame);
                             currentSnapshot.frame = CGRectMake(
                                                            CGRectGetMinX(currentFrame),
                                                            currentHeight + kACMWebTableOffScreenOffset,
                                                            CGRectGetWidth(currentFrame),
                                                            CGRectGetHeight(currentFrame) );
                             weakCurrent.frame = currentSnapshot.frame;

                             CGRect previousFrame = weakPrevious.frame;
                             weakPrevious.frame = CGRectMake(
                                                             CGRectGetMinX(previousFrame),
                                                             0.0f,
                                                             CGRectGetWidth(previousFrame),
                                                             CGRectGetHeight(previousFrame) );
                         } completion:^(BOOL finished) {
                             if ( finished ) {
                                 weakCurrent.frame = currentSnapshot.frame;
                                 [currentSnapshot removeFromSuperview];
                                 [weakSelf.nextView removeFromSuperview];
                                 weakSelf.nextView = weakCurrent;
                                 weakSelf.currentView = weakPrevious;
                                 weakSelf.currentIndex--;
                                 ACMWebView *previousNew = [weakSelf buildPrevious];
                                 
                                 if ( previousNew ) {
                                     CGRect previousFrame = previousNew.frame;
                                     CGFloat previousY = -CGRectGetHeight(weakSelf.frame) - kACMWebTableOffScreenOffset;
                                     previousNew.frame = CGRectMake(
                                                                    CGRectGetMinX(previousFrame),
                                                                    previousY,
                                                                    CGRectGetWidth(previousFrame),
                                                                    CGRectGetHeight(previousFrame) );
                                     [weakSelf addSubview:previousNew];
                                 }
                                 
                                 weakSelf.previousView = previousNew;
                                 weakSelf.animating = NO;
                                 
                                 [weakSelf scrollCurrentToTopAnimated:YES];
                             }
                         }];
    }
}

- (void) scrollCurrentToTopAnimated:(BOOL)animated {
    [self scrollWebViewToTop:self.currentView animated:animated];
    if ( [self.delegate respondsToSelector:@selector(acmTable:didDisplayCurrentView:)] ) {
        [self.delegate acmTable:self didDisplayCurrentView:self.currentView];
    }
}

- (void) scrollWebViewToTop:(ACMWebView *)webView animated:(BOOL)animated {
    CGFloat offsetY = CGRectGetMinY(webView.titleView.frame);
    CGPoint offsetPoint = CGPointMake( webView.scrollView.contentOffset.x, offsetY );
    [webView.scrollView setContentOffset:offsetPoint animated:animated];
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
            webView.delegate = self;
            webView.scrollView.delegate = self;
            [webView loadContent];
        }
    }
    
    return webView;
}

@end
