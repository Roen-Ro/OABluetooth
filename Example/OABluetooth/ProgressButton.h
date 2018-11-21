//
//  ProgressButton.h
//  Drinker
//
//  Created by 罗亮富 on 15/9/22.
//  Copyright © 2015年 luoliangfu. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UIControlStateInProgress (UIControlStateSelected<<1)

@interface ProgressButton : UIButton

@property (nonatomic) BOOL inProgress;

@property(nonatomic) UIActivityIndicatorViewStyle activityIndicatorViewStyle;

@end
