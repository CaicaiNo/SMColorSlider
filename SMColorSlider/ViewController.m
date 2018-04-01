//
//  ViewController.m
//  SMColorSlider
//
//  Created by Sheng on 2017/9/26.
//  Copyright © 2017年 sheng. All rights reserved.
//

#import "ViewController.h"
#import "SMColorSlider.h"


@interface ViewController ()
{
    SMColorSlider *smColor;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    smColor = [[SMColorSlider alloc]initWithFrame:CGRectMake(50, 250, CGRectGetWidth(self.view.frame)-100, 30) colors:nil];
    
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
