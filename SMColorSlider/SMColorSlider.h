//
//  SMColorSlider.h
//  CustomSliderDemo
//
//  Created by Sheng on 2017/9/25.
//  Copyright © 2017年 Sheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMThumbView : UIView

- (void)setTintColor:(UIColor*)color animate:(BOOL)isAnimted;

@end

#pragma mark - slilder

//response UIControlEventTouchUpInside and UIControlEventValueChanged event

@interface SMColorSlider : UIControl

@property (nonatomic,strong) UIColor* selectColor; //current color

- (instancetype)initWithFrame:(CGRect)frame
                       colors:(NSArray<UIColor*>*)colors; //if colors is nil,will set deault value


- (void)setLandscape:(BOOL)isLand;//设置横竖屏 旋转



@end
