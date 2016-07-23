//
//  ViewController.m
//  StepDemo
//
//  Created by 雷建民 on 16/7/22.
//  Copyright © 2016年 雷建民. All rights reserved.
//

#import "ViewController.h"
#import "StepManager.h"
@interface ViewController ()
{
    NSTimer *_timer;
    UILabel *lable;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
      [[StepManager sharedManager] startWithStep];
      lable =[[ UILabel alloc]initWithFrame:CGRectMake(100, 300, 300, 40)];
    
  
    [self.view addSubview:lable];
    _timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(getStepNumber) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
}


- (void)getStepNumber
{

    lable.text = [NSString stringWithFormat:@"我走了  %ld步",[StepManager sharedManager].step];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
