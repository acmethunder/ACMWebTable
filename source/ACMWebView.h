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
FOUNDATION_EXTERN NSString * const kACMWebViewFooterKey;
//FOUNDATION_EXTERN NSString * const kACMWebViewKey;

@interface ACMWebView : UIWebView

- (instancetype) initWithFrame:(CGRect)frame webContent:(id)content header:(UIView*)header footer:(UIView*)footer;

@property (nonatomic,strong) UIView *header;
@property (nonatomic,strong) UIView *footer;

@property (nonatomic,strong) id webContent;


@end
