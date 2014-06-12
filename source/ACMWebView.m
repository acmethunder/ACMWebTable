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

NSString * const kACMWebTitleViewKey      = @"header";
NSString * const kACMWebViewHeaderViewKey = @"previousView";
NSString * const kACMWebViewFooterViewKey = @"nextView";

#pragma mark Exception Names

NSString * const kACMWebViewExceptionBadContentName   = @"com.acmwebview.exception.badcontent";
NSString * const kACMWebViewExceptionBadContentReason = @"\'webContent\' must be either an instance of \'NSString,\' \'NSURL,\' or \'nil.\'";
NSString * const kACMWebViewExceptionContentClassKey  = @"com.acmwebview.exception.contentclass.key";

#pragma mark Notifications

NSString * const kACMWebViewTouchDownNotificationName = @"com.acmwebview.touchdown.notification.name";

#pragma mark -
#pragma mark ACMWebView + Private

@interface ACMWebView ()

#pragma mark Content

- (void) loadStringContent;
- (void) loadURLContent;

#pragma mark Touch Events
- (void) tapEvent:(UITapGestureRecognizer*)tap;

@end

#pragma mark -
#pragma mark ACMWebView
#pragma mark -

@implementation ACMWebView

#pragma mark PUBLIC INSTANCE METHODS
#pragma mark Object Lifecycle

- (instancetype) initWithFrame:(CGRect)frame {
    if ( (self = [super initWithFrame:frame]) ) {
        self->_menuOptions = ACMWebViewMenuOptionsAll;
    }
    
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame webContent:(id)content titleView:(UIView*)titleView {
    NSParameterAssert( [content isKindOfClass:[NSString class]] || [content isKindOfClass:[NSURL class]] );
    
    if ( (self = [self initWithFrame:frame]) ) {
        self->_webContent = content;
        self.titleView    = titleView;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(tapEvent:)];
        tap.numberOfTapsRequired = 1;
        tap.delegate = self;
        [self addGestureRecognizer:tap];
    }
    
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame webContent:(id)content titleView:(UIView *)titleView baseURL:(NSURL*)baseURL {
    if ( (self = [self initWithFrame:frame webContent:content titleView:titleView]) ) {
        self->_baseURL = baseURL;
    }
    
    return self;
}

#pragma mark Layout

- (void) layoutSubviews {
//    // layout header
//    UIView *header = self.headerView;
//    if ( header ) {
//        CGRect headerFrame = header.frame;
//        CGFloat headerHeight = CGRectGetHeight(headerFrame);
//        header.frame = CGRectMake(
//                                  CGRectGetMinX(headerFrame),
//                                  -headerHeight,
//                                  CGRectGetWidth(headerFrame),
//                                  -headerHeight );
//        
//    }
    
    // layout title
    UIView *titleView = self.titleView;
    if ( titleView ) {
        CGRect titleFrame = titleView.frame;
        titleView.frame = CGRectMake(
                                     CGRectGetMinX(titleFrame),
                                     0.0f,
                                     CGRectGetWidth(titleFrame),
                                     -CGRectGetHeight(titleFrame) );
    }
    
    // layout header
    UIView *header = self.headerView;
    if ( header ) {
        CGRect headerFrame = header.frame;
        CGFloat headerHeight = CGRectGetHeight(headerFrame);
        header.frame = CGRectMake(
                                  CGRectGetMinX(headerFrame),
                                  CGRectGetMinY(titleView.frame),
                                  CGRectGetWidth(headerFrame),
                                  -headerHeight );
        
    }
    
    // layout footer
    UIView *footer = self.footerView;
    if ( footer ) {
        CGRect footerFrame = footer.frame;
        footer.frame = CGRectMake(
                                  CGRectGetMinX(footerFrame),
                                  self.scrollView.contentSize.height,
                                  CGRectGetWidth(footerFrame),
                                  CGRectGetHeight(footerFrame) );
    }
    
    CGFloat titleHeight = CGRectGetHeight(titleView.frame);
    self.scrollView.contentInset = UIEdgeInsetsMake(
                                                    titleHeight,
                                                    0.0f,
                                                    0.0f,
                                                    0.0f);
}

#pragma mark Validating Commends

- (BOOL) canPerformAction:(SEL)action withSender:(id)sender {
//    BOOL canGo = NO;
//    ACMWebViewMenuOptions menuOp = self.menuOptions;
//    
//    if ( (menuOp & ACMWebViewMenuOptionsCopy) && (action == @selector(copy:)) ) {
//        canGo = YES;
//    }
//    else if ( (menuOp & ACMWebViewMenuOptionsCut) && (action == @selector(cut:)) ) {
//        canGo = YES;
//    }
//    else if ( (menuOp & ACMWebViewMenuOptionsPaste) && (action == @selector(paste:)) ) {
//        canGo = YES;
//    }
//    else if ( (menuOp & ACMWebViewMenuOptionsDefine) && (action == @selector(definition)) ) {
//        canGo = YES;
//    }
//    else {
//        canGo = [super canPerformAction:action withSender:sender];
//    }
//    
//    return canGo;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if (action == @selector(copy:) ||
        action == @selector(paste:)||
        action == @selector(cut:) ||
        action == @selector(_define:))
    {
        return NO;
    }
#pragma clang diagnostic pop
    return [super canPerformAction:action withSender:sender];
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

//#pragma mark Touch Events
//
//- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    [[NSNotificationCenter defaultCenter] postNotificationName:kACMWebViewTouchDownNotificationName
//                                                        object:nil];
//    [super touchesBegan:touches withEvent:event];
//}

#pragma mark PUBLIC PROPERTIES

- (CGFloat) headerContentHeight {
    CGFloat height = CGRectGetHeight(self.headerView.frame) + CGRectGetHeight(self.titleView.frame);
    
    return height;
}

- (void) setTitleView:(UIView *)titleView {
    [self willChangeValueForKey:kACMWebTitleViewKey];
    
    if ( self->_titleView ) {
        [self->_titleView removeFromSuperview];
    }

    if ( titleView ) {
        titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.scrollView addSubview:titleView];
    }
    
    self->_titleView = titleView;
    
    [self didChangeValueForKey:kACMWebTitleViewKey];
}

- (void) setHeaderView:(UIView *)headerView {
    [self willChangeValueForKey:kACMWebViewHeaderViewKey];
    
    if ( self->_headerView ) {
        [self->_headerView removeFromSuperview];
    }
    
    if ( headerView ) {
        headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.scrollView addSubview:headerView];
    }
    
    self->_headerView = headerView;
    
    [self didChangeValueForKey:kACMWebViewHeaderViewKey];
}

- (void) setFooterView:(UIView *)footerView {
    [self willChangeValueForKey:kACMWebViewFooterViewKey];
    
    if ( self->_footerView ) {
        [self->_footerView removeFromSuperview];
    }
    
    if ( footerView ) {
        footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.scrollView addSubview:footerView];
    }
    
    self->_footerView = footerView;

    [self didChangeValueForKey:kACMWebViewFooterViewKey];
//    [self setNeedsLayout];
}

- (void) setWebContent:(id)webContent {
    if ( (! webContent) || [webContent isKindOfClass:[NSString class]] || [webContent isKindOfClass:[NSURL class]] ) {
        self->_webContent = webContent;
    }
}

#pragma mark ADOPTED PROTOCOLS

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return  YES;
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

#pragma mark Touch Events
- (void) tapEvent:(UITapGestureRecognizer*)tap {
    [[NSNotificationCenter defaultCenter] postNotificationName:kACMWebViewTouchDownNotificationName
                                                        object:self];
}


@end
