//
//  StepManager.h
//  StepDemo
//
//  Created by 雷建民 on 16/7/22.
//  Copyright © 2016年 雷建民. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface StepManager : NSObject


@property (nonatomic) NSInteger step;                       // 运动步数（总计）

+ (StepManager *)sharedManager;

//开始计步
- (void)startWithStep;

////得到计步所消耗的卡路里
//+ (NSInteger)getStepCalorie;
//
////得到所走的路程(单位:米)
//+ (CGFloat)getStepDistance;
//
////得到运动所用的时间
//+ (NSInteger)getStepTime;

@end
