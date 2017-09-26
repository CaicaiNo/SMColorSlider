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

@interface SMColorSlider : UIControl

@property (nonatomic,strong) UIColor* selectColor;

- (instancetype)initWithFrame:(CGRect)frame
                       colors:(NSArray<UIColor*>*)colors; //暂时写的固定值



- (void)setLandscape:(BOOL)isLand;//设置横竖屏 旋转



@end
