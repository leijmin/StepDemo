//
//  StepModel.h
//  StepDemo
//
//  Created by 雷建民 on 16/7/22.
//  Copyright © 2016年 雷建民. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StepModel : NSObject

@property(nonatomic,strong) NSDate *date;

@property(nonatomic,assign) int record_no;

@property(nonatomic, strong) NSString *record_time;

@property(nonatomic,assign) int step;

//g是一个震动幅度的系数,通过一定的判断条件来判断是否计做一步
@property(nonatomic,assign) double g;


@end
