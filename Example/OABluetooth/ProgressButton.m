//
//  ProgressButton.m
//  Drinker
//
//  Created by 罗亮富 on 15/9/22.
//  Copyright © 2015年 luoliangfu. All rights reserved.
//

#import "ProgressButton.h"
#import <objc/runtime.h>
char progressKey;
@implementation ProgressButton

-(void)setInProgress:(BOOL)inProgress
{
    objc_setAssociatedObject(self, &progressKey, [NSNumber numberWithBool:inProgress], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setUpView:inProgress];
}

-(BOOL)inProgress
{
    NSNumber *b = objc_getAssociatedObject(self, &progressKey);
    return b.boolValue;
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    UIActivityIndicatorView *acIdView = [self progressIndicator];
    if(acIdView)
       [self layoutIndicatorView];
}

-(void)layoutIndicatorView
{
    UILabel *progressLabel = [self progressLabel];
    UIActivityIndicatorView *acIdView = [self progressIndicator];
    
    CGSize size = [progressLabel.text sizeWithAttributes:@{NSFontAttributeName:progressLabel.font}];
    CGRect frame = self.frame;
    CGFloat width = size.height;
    CGFloat x = MAX((self.frame.size.width-size.width)/2-width-3,0.0);
    CGFloat y = (frame.size.height-size.height)/2;
    acIdView.frame = CGRectMake(x, y, width, width);
    
}

-(void)setActivityIndicatorViewStyle:(UIActivityIndicatorViewStyle)activityIndicatorViewStyle
{
    [self progressIndicator].activityIndicatorViewStyle = activityIndicatorViewStyle;
}

-(UILabel *)progressLabel
{
    UILabel *progressLabel = (UILabel *)[self viewWithTag:1];
    return progressLabel;
}

-(UIActivityIndicatorView *)progressIndicator
{
    UIActivityIndicatorView *acIdView = (UIActivityIndicatorView *)[self viewWithTag:2];
    return acIdView;
}

-(void)setUpView:(BOOL)inProgress
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.imageView.alpha = inProgress ? 0 : 1;
        self.titleLabel.alpha = inProgress ? 0 : 1;
    });
    
    UILabel *progressLabel = [self progressLabel];
    UIActivityIndicatorView *acIdView = [self progressIndicator];
    if(self.inProgress)
    {
        UIControlState state = UIControlStateInProgress;
        NSString *title = [self titleForState:state];
        UIColor *color = [self titleColorForState:state];
        
        if(!progressLabel)
        {
            progressLabel = [[UILabel alloc]initWithFrame:self.bounds];
            progressLabel.tag = 1;
            progressLabel.textAlignment = NSTextAlignmentCenter;
            progressLabel.font = self.titleLabel.font;
            progressLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            [self addSubview:progressLabel];
        }
        progressLabel.text = title;
        progressLabel.textColor = color;
        progressLabel.backgroundColor = self.superview.backgroundColor ? : self.backgroundColor;
        
        if(!acIdView)
        {
            acIdView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            acIdView.tag = 2;
            acIdView.hidesWhenStopped = YES;
            [self addSubview:acIdView];
        }
        [self layoutIndicatorView];
        
        [acIdView startAnimating];
    }
    else
    {
        [acIdView removeFromSuperview];
        [progressLabel removeFromSuperview];
    }

}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *v = [super hitTest:point withEvent:event];
    if(v)
    {
        if(v == [self progressIndicator] || v == [self progressLabel])
            return self;
    }
    
    return v;
}


@end
