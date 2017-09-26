//
//  ViewController.m
//  SMColorSlider
//
//  Created by Sheng on 2017/9/26.
//  Copyright © 2017年 sheng. All rights reserved.
//

#import "ViewController.h"
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
@interface ViewController ()
{
    SMColorSlider *smColor;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *colors = [NSArray arrayWithObjects:BlackPen,RedPen,GreenPen,RoseRedPen,BluePen,YellowPen,OrangePen,CoffeePen, nil];
    
    smColor = [[SMColorSlider alloc]initWithFrame:CGRectMake(50, 250, CGRectGetWidth(self.view.frame)-100, 40) colors:colors];
    [self.view addSubview:smColor];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)switch:(id)sender {
    
    UISwitch *tmp = sender;

    [smColor setLandscape:tmp.on];
}

@end
