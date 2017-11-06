//
//  UIUtil.m
//  AMiTime
//
//  Created by liu on 15/4/20.
//  Copyright (c) 2015年 usr.cn. All rights reserved.
//

#import "UIUtil.h"

@implementation UIUtil
+ (void) shakeAction:(UIView *) shakeView{
    //晃动次数
    int numberOfShakes = 4;
    //晃动的幅度（相对于总宽带）
    float vigourOfShake = 0.04f;
    //动画持续时间
    float duration = 0.5f;
    
    
    CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    //绘制路径
    CGRect frame = shakeView.frame;
    //创建路径
    CGMutablePathRef shakePath = CGPathCreateMutable();
    //起始点
    CGPathMoveToPoint(shakePath, NULL, CGRectGetMidX(frame), CGRectGetMidY(frame));
    
    
    for (int i=0; i<numberOfShakes; i++) {
        //添加晃动路径，幅度由大变小
        CGPathAddLineToPoint(shakePath, NULL, CGRectGetMidX(frame) - frame.size.width * vigourOfShake*(1-(float)i/numberOfShakes),CGRectGetMidY(frame));
        CGPathAddLineToPoint(shakePath, NULL,CGRectGetMidX(frame) + frame.size.width * vigourOfShake*(1-(float)i/numberOfShakes),CGRectGetMidY(frame));
    }
    
    
    //闭合路径
    
    CGPathCloseSubpath(shakePath);
    shakeAnimation.path = shakePath;
    shakeAnimation.duration = duration;
    CFRelease(shakePath);
    [shakeView.layer addAnimation:shakeAnimation forKey:kCATransition];
}
@end
