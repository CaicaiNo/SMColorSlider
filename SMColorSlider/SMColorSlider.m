//
//  SMColorSlider.m
//  CustomSliderDemo
//
//  Created by Sheng on 2017/9/25.
//  Copyright © 2017年 Sheng. All rights reserved.
//

#import "SMColorSlider.h"
#import "UIColor+HexString.h"

#define BlackPen   [UIColor colorFromHexString:@"#000000"]  //笔-黑色
#define RedPen   [UIColor colorFromHexString:@"#ff0000"]    //笔-红色
#define GreenPen   [UIColor colorFromHexString:@"#00ff00"]   //笔-绿色
#define RoseRedPen   [UIColor colorFromHexString:@"#ff00ff"]  //笔-玫红
#define BluePen   [UIColor colorFromHexString:@"#0000ff"]     //笔-蓝色
#define YellowPen   [UIColor colorFromHexString:@"#ffff00"]    //笔-黄色
#define OrangePen   [UIColor colorFromHexString:@"#ff7f00"]    //笔-橙色
#define CoffeePen   [UIColor colorFromHexString:@"#996600"]    //笔-咖啡

#define M_ThumbX (15)
#define M_ThumbY (10)

#define COLOR_SCAN 0 //是否自动扫描当前thumb位置的颜色

#define COLOR_BALL_H 24 //彩色球 距离thumb上方的高度距离

#define AUTO_SET_MIDDLE 1 //自动居中模式  选中该颜色 会自动居中

@implementation SMThumbView
{
    UIView *_bigView; //比thumb大的视图  响应事件
    CAShapeLayer *_thumbLayer; //图标视图
    UIBezierPath *_thumbPath;
    
    CGFloat radius;
    UIColor *_thumbColor;
    
    //上方圆球
    CAShapeLayer *_ballLayer; //颜色球
    UIBezierPath *_ballPath; //颜色球 路径
    CGFloat ballRadius;
}


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        radius = 5.;
        ballRadius = 10.;
        _thumbColor = [UIColor blackColor];
        
        _bigView = [[UIView alloc]initWithFrame:CGRectMake(-M_ThumbX, -M_ThumbY, frame.size.width + 2*(M_ThumbX), frame.size.height + 2*(M_ThumbY))];
        
        
        _thumbPath = [[UIBezierPath alloc]init];
        
        [_thumbPath addArcWithCenter:CGPointMake(_bigView.frame.size.width/2, radius + M_ThumbY) radius:radius startAngle:M_PI endAngle:M_PI*2 clockwise:YES];
        [_thumbPath moveToPoint:CGPointMake(_bigView.frame.size.width/2 + radius, radius + M_ThumbY)];
        [_thumbPath addLineToPoint:CGPointMake(_bigView.frame.size.width/2 + radius, M_ThumbY + frame.size.height - radius)];
        [_thumbPath addArcWithCenter:CGPointMake(_bigView.frame.size.width/2, M_ThumbY + frame.size.height - radius) radius:radius startAngle:0 endAngle:M_PI clockwise:YES];
        [_thumbPath addLineToPoint:CGPointMake(_bigView.frame.size.width/2 - radius, M_ThumbY + radius)];
        
        
        _thumbLayer = [CAShapeLayer layer];
        _thumbLayer.path = _thumbPath.CGPath;
        _thumbLayer.lineWidth = 1.5f;
        _thumbLayer.strokeColor = [UIColor whiteColor].CGColor;
        _thumbLayer.fillColor = _thumbColor.CGColor;
        
        [_bigView.layer addSublayer:_thumbLayer];
        
        //颜色球
        _ballPath = [[UIBezierPath alloc]init];
        
        [_ballPath addArcWithCenter:CGPointMake(_bigView.frame.size.width/2, M_ThumbY - COLOR_BALL_H) radius:ballRadius startAngle:0 endAngle:M_PI*2 clockwise:YES];
        
        _ballLayer = [CAShapeLayer layer];
        _ballLayer.path = _ballPath.CGPath;
        _ballLayer.lineWidth = 0.2f;
        //        _ballLayer.strokeColor = [UIColor whiteColor].CGColor;
        _ballLayer.fillColor = _thumbColor.CGColor;
        
        _ballLayer.opacity = 0.f;
        
        [_bigView.layer addSublayer:_ballLayer];
        
        [self addSubview:_bigView];
        
        
    }
    return self;
}

- (CGRect)bigRect{
    return CGRectMake(-M_ThumbX, -M_ThumbY, self.frame.size.width + 2*(M_ThumbX), self.frame.size.height + 2*(M_ThumbY));
}

- (void)setBallHidden:(BOOL)hidden delay:(double)time{
    if (time > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self _ballHidden:hidden];
        });
    }else{
        [self _ballHidden:hidden];
    }
    
    
}

- (void)_ballHidden:(BOOL)hidden{
    [CATransaction begin];
    [CATransaction setDisableActions:NO];
    [CATransaction setAnimationDuration:0.3f];
    _ballLayer.opacity = 0.f;
    [CATransaction commit];
}

- (void)setTintColor:(UIColor*)color animate:(BOOL)isAnimted{
    
    
    if (!CGColorEqualToColor(_thumbColor.CGColor, color.CGColor)) {
        _thumbColor = color;
        
        NSLog(@"select color :%@",_thumbColor.RGBAString);
        
        if (isAnimted) {
            [CATransaction begin];
            [CATransaction setDisableActions:NO];
            [CATransaction setAnimationDuration:0.3f];
            
            [self setThumbColor:color];
            _ballLayer.opacity = 1.f;
            [CATransaction commit];
            
        }else{
            [self setThumbColor:color];
            _ballLayer.opacity = 1.f;
        }
    }
    
}

- (void)setThumbColor:(UIColor *)color{
    [_thumbLayer setFillColor:color.CGColor];
    [_ballLayer setFillColor:color.CGColor];
}

@end

#pragma mark - slider

@implementation SMColorSlider
{
    CAGradientLayer *_colorLayer;
    CAShapeLayer *_maskLayer;
    UIBezierPath *_maskPath;
    
    double _radius;
    CGFloat minL; //最短 - frame.with or height
    CGFloat maxL; //最长 - frame.with or height
    
    SMThumbView *_thumbView;
    
    CGFloat _originX;
    
    //colors颜色数组处理
    NSMutableArray *_locations;
    NSArray *_colors;
    
    BOOL isRotateLandscape;//是否已经旋转
    CGRect _recordFrame;
}
- (instancetype)initWithFrame:(CGRect)frame
                       colors:(NSArray<UIColor*>*)colors
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _recordFrame = frame;
        _radius = 6;
        //colors
        minL = MIN(frame.size.width, frame.size.height);
        maxL = MAX(frame.size.width, frame.size.height);
        _colorLayer = [CAGradientLayer layer];
        _colorLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
        if (colors) {
            _colors = colors;
        }else{
            _colors = [NSArray arrayWithObjects:BlackPen,RedPen,GreenPen,RoseRedPen,BluePen,YellowPen,OrangePen,CoffeePen, nil];
        }
        
        _locations = [NSMutableArray array];
        
        CGFloat b = 1.00/(_colors.count);
        
        NSMutableArray *mLocations = [NSMutableArray array];
        
        for (int i = 1; i <= _colors.count - 1; i++) {
            
            [mLocations addObject:[NSNumber numberWithFloat:b*(i)]];
            [mLocations addObject:[NSNumber numberWithFloat:b*(i)]];
            
            [_locations addObject:[NSNumber numberWithFloat:b*(i)]];
        }
        
        
        
        NSMutableArray *mColors = [NSMutableArray array];
        for (int i = 0; i < _colors.count; i ++) {
            if (i == 0 || i == _colors.count - 1) {
                UIColor *tmp = _colors[i];
                [mColors addObject:(__bridge id)tmp.CGColor];
            }else{
                UIColor *tmp = _colors[i];
                [mColors addObject:(__bridge id)tmp.CGColor];
                [mColors addObject:(__bridge id)tmp.CGColor];
                
            }
        }
        
        //        _colorLayer.colors = @[(__bridge id)BlackPen.CGColor,
        //                               (__bridge id)RedPen.CGColor,
        //                                 (__bridge id)RedPen.CGColor,
        //                               (__bridge id)GreenPen.CGColor,
        //                               (__bridge id)GreenPen.CGColor,
        //                               (__bridge id)RoseRedPen.CGColor,
        //                               (__bridge id)RoseRedPen.CGColor,
        //                               (__bridge id)BluePen.CGColor];
        //        _colorLayer.locations  = @[@(0.2),@(0.2),@(0.4), @(0.4), @(0.6),@(0.6),@(0.8),@(0.8)];
        
        _colorLayer.colors = mColors;
        _colorLayer.locations  = mLocations;
        
        
        
        _colorLayer.startPoint = CGPointMake(0, 0);
        _colorLayer.endPoint   = CGPointMake(1, 0);
        
        
        [self.layer addSublayer:_colorLayer];
        
        _maskPath = [[UIBezierPath alloc]init];
        
        [_maskPath addArcWithCenter:CGPointMake(_radius, minL/2) radius:_radius startAngle:M_PI_2 endAngle:M_PI_2*3 clockwise:YES];
        [_maskPath moveToPoint:CGPointMake(_radius, minL/2 - _radius)];
        
        [_maskPath addLineToPoint:CGPointMake(minL - _radius, minL/2 - _radius)];
        
        [_maskPath addArcWithCenter:CGPointMake(maxL - _radius, minL/2) radius:_radius startAngle:M_PI_2*3 endAngle:M_PI_2 clockwise:YES];
        [_maskPath addLineToPoint:CGPointMake(_radius, minL/2 + _radius)];
        
        
        _maskLayer = [CAShapeLayer layer];
        _maskLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        _maskLayer.path = _maskPath.CGPath;
        _maskLayer.lineWidth = 0.5;
        _maskLayer.strokeColor = [UIColor whiteColor].CGColor;
        
        [_colorLayer setMask:_maskLayer];
        
        //Thumb
        
        _thumbView = [[SMThumbView alloc]initWithFrame:CGRectMake(0, 0, 20, frame.size.height)];
        
        [self addSubview:_thumbView];
        
        _originX = _thumbView.frame.origin.x;
        
        [_thumbView setThumbColor:_colors[0]];
        
    }
    return self;
}


- (void)setThumbX:(CGFloat)x isTap:(BOOL)tap{
    
    CGFloat offsetX = (x - _originX);
    
    CGRect frame = _thumbView.frame;
    CGFloat tmp = frame.origin.x + offsetX;
    
    if (tmp < 0) {
        tmp = 0;
    }
    
    if (tmp > (self.bounds.size.width - _thumbView.bounds.size.width)) {
        tmp = (self.bounds.size.width - _thumbView.bounds.size.width);
    }
    
    frame.origin.x = tmp;
    
    if (tap) {
#if AUTO_SET_MIDDLE
        CGFloat M = (self.bounds.size.width / _colors.count); //每小格子 距离
        CGFloat M_2 = M/2; //每小格子 一半的距离
        
        CGFloat W_2 = _thumbView.bounds.size.width/2;
        
        NSInteger C = (frame.origin.x + W_2) / M; //格子数 int
        
        if (C >= _colors.count) {
            C = _colors.count - 1;//防止越界
        }
        
        CGFloat R = C*M + M_2 - W_2; //结果位置
        
        frame.origin.x = R;
        
        [_thumbView setFrame:frame];
        
        [_thumbView setBallHidden:YES delay:0.8];
#else
        [_thumbView setFrame:frame];
#endif
    }else{
        [_thumbView setFrame:frame];
    }
    
    
    if (_originX != frame.origin.x) {
        _originX = frame.origin.x;
    }
    
    CGFloat centerX = _originX + _thumbView.bounds.size.width/2;
    
    CGFloat percent = centerX/self.bounds.size.width;
    
    if (_colors.count > _locations.count) {
        for (int i = 0; i < _locations.count; i ++) {
            
            if (i < _locations.count - 1) {
                
                if (percent > [_locations[i] floatValue]) {
                    if (percent < [_locations[i + 1] floatValue]) {
                        _selectColor = _colors[i+1];
                        [_thumbView setTintColor:_colors[i+1] animate:YES];
                        break;
                    }
                }else if(percent < [_locations[0] floatValue]){
                    _selectColor = _colors[0];
                    [_thumbView setTintColor:_colors[0] animate:YES];
                    break;
                    
                }
            }else{
                if (percent > [_locations[i] floatValue]) {
                    _selectColor = _colors[i+1];
                    [_thumbView setTintColor:_colors[i+1] animate:YES];
                    break;
                }
            }
        }
    }
    
    
    
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    _recordFrame = frame;
    
    _colorLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

- (void)setLandscape:(BOOL)isLand{
    
    if (isRotateLandscape == isLand) {
        return;
    }
    
    if (isLand) {
        self.layer.anchorPoint = CGPointMake(0, 0);
        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformTranslate(transform, _recordFrame.size.height, 0);
        transform = CGAffineTransformRotate(transform,M_PI_2);
        
        
        self.layer.affineTransform = transform;
        self.layer.position = _recordFrame.origin;
    }else{
        self.layer.anchorPoint = CGPointMake(0, 0);
        self.layer.affineTransform = CGAffineTransformIdentity;
        self.layer.position = _recordFrame.origin;
    }
    
    isRotateLandscape = isLand;
}


#pragma mark - delegate

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint point = [touch locationInView:self];
    
    CGRect responceR = [_thumbView convertRect:[_thumbView bigRect] toView:self];
    
    //可滑动范围
    if (!CGRectContainsPoint(responceR, point)) {
        
        NSLog(@"直接点击");
        
        [self setThumbX:point.x isTap:YES];
        
        [self sendActionsForControlEvents:UIControlEventTouchUpInside];
        
        
        
        return NO;
    }
    
    _originX = point.x;
    
    return YES;
}

//持续拖动
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(nullable UIEvent *)event {
    
    CGPoint point = [touch locationInView:self];
    
    [self setThumbX:point.x isTap:NO];
    
    return YES;
    
}

- (void)endTrackingWithTouch:(nullable UITouch *)touch withEvent:(nullable UIEvent *)event {
    //    CGPoint point = [touch locationInView:self];
    
    [_thumbView setBallHidden:YES delay:0];
    
#if AUTO_SET_MIDDLE
    if (_colors.count > 0) {
        
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = _thumbView.frame;
            
            CGFloat M = (self.bounds.size.width / _colors.count); //每小格子 距离
            CGFloat M_2 = M/2; //每小格子 一半的距离
            
            CGFloat W_2 = _thumbView.bounds.size.width/2;
            
            NSInteger C = (frame.origin.x + W_2) / M; //格子数 int
            
            if (C >= _colors.count) {
                C = _colors.count - 1;//防止越界
            }
            
            CGFloat R = C*M + M_2 - W_2; //结果位置
            
            frame.origin.x = R;
            
            [_thumbView setFrame:frame];
        }];
        
        
    }
#else
#endif
    
    //增加控制事件
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    
    CGRect responceR = [_thumbView convertRect:[_thumbView bigRect] toView:self];
    
    //可滑动范围
    if (CGRectContainsPoint(responceR, point)) {
        return self;
    }else{
        return [super hitTest:point withEvent:event];
    }
    
}

@end
