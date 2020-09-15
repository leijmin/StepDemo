//
//  StepManager.m
//  StepDemo
//
//  Created by 雷建民 on 16/7/22.
//  Copyright © 2016年 雷建民. All rights reserved.
//

#import "StepManager.h"
#import "StepModel.h"
#import <CoreMotion/CoreMotion.h>

// 计步器开始计步时间（秒）
#define ACCELERO_START_TIME 2

// 计步器开始计步步数（步）
#define ACCELERO_START_STEP 1

// 数据库存储步数采集间隔（步）
#define DB_STEP_INTERVAL 1


@interface StepManager ()

{

    
    NSMutableArray *arrAll;                 // 加速度传感器采集的原始数组
    int record_no_save;
    int record_no;
    NSDate *lastDate;
    
}
@property (nonatomic) NSInteger startStep;                          // 计步器开始步数

@property (nonatomic, retain) NSMutableArray *arrSteps;         // 步数数组
@property (nonatomic, retain) NSMutableArray *arrStepsSave;     // 数据库纪录步数数组

@property (nonatomic) CGFloat gpsDistance;                  // GPS轨迹的移动距离（总计）
@property (nonatomic) CGFloat agoGpsDistance;               // GPS轨迹的移动距离（之前）
@property (nonatomic) CGFloat agoActionDistance;            // 实际运动的移动距离（之前）

@property (nonatomic, retain) NSString *actionId;           // 运动识别ID
@property (nonatomic) CGFloat distance;                     // 运动里程（总计）
@property (nonatomic) NSInteger calorie;                    // 消耗卡路里（总计）
@property (nonatomic) NSInteger second;                     // 运动用时（总计）

@end

@implementation StepManager

static StepManager *sharedManager;
static CMMotionManager *motionManager;

+ (StepManager *)sharedManager
{
    @synchronized (self) {
        if (!sharedManager) {
            sharedManager = [[StepManager alloc]init];
            motionManager = [[CMMotionManager alloc]init];
        }
    }
    return sharedManager;
}

//开始计步
- (void)startWithStep
{
    
    /*
     环境光传感器   感应周围光线强弱   （自动调节屏幕亮度）
     距离传感器     感应是否有物体靠近手机 （抬起手机 亮起屏幕，打电话等）
     磁力传感器     感应设备周围磁场，类似翻盖手机，合盖锁屏  [motionManager startMagnetometerUpdates]
     内部温度传感器  感应设备内部温度
     湿度传感器     感应设备是否进水
     陀螺仪传感器   感应设备握持的方向  类似赛车游戏
     加速计        感应设备运动情况  常用计步
     
     无论哪种方式拉取数据必须设置采样率：
     accelerometerUpdateInterval 加速计采样率
     gyroUpdateInterval  陀螺仪采样率
     deviceMotionUpdateInterval 磁力计采样率
     
     传感器分为2种方式拉取数据：
     pull 方式： 在需要数据时去更新获取数据
     push 方式： 实时更新数据
     */
    if (!motionManager.isAccelerometerAvailable) {
        NSLog(@"加速度传感器不可用");
        return;
    }else {
        //设置加速传感器的 采样率  1秒采样30次
        motionManager.accelerometerUpdateInterval = 1.0/1;
    }
    [self startAccelerometer];
  
}

- (void)startAccelerometer
{
    
    //pull 方式拉取
//    [motionManager startAccelerometerUpdates];
//    CMAccelerometerData *data =  motionManager.accelerometerData;
//    NSLog(@"x : %f, y : %f, z : %f", data.acceleration.x, data.acceleration.y, data.acceleration.z);
//    [motionManager stopAccelerometerUpdates];
    
    //push 方式拉取
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    //加速计开始采样
    [motionManager startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
            
                // 正值负值: 轴的方向, 哪个指向地面, 就会打印出打个方向的值
                // 只要在某个轴上, 进行快速移动, 那么值就会发生变化
//        NSLog(@"x : %f, y : %f, z : %f", accelerometerData.acceleration.x, accelerometerData.acceleration.y, accelerometerData.acceleration.z);
        
        NSLog(@"x : %f", accelerometerData.acceleration.x);
        //根据 x y z 三个方向的 数据来 进行 步数建模
        //建模大体思路逻辑  https://cdc.tencent.com/2013/07/26/%E5%88%A9%E7%94%A8%E4%B8%89%E8%BD%B4%E5%8A%A0%E9%80%9F%E5%99%A8%E7%9A%84%E8%AE%A1%E6%AD%A5%E6%B5%8B%E7%AE%97%E6%96%B9%E6%B3%95/
        
    }];
}













//    @try
//    {
//        //如果不支持陀螺仪,需要用加速传感器来采集数据
//        if (!motionManager.isAccelerometerActive) {//  isAccelerometerAvailable方法用来查看加速度器的状态：是否Active（启动）。
//
//            // 加速度传感器采集的原始数组
//            if (arrAll == nil) {
//                arrAll = [[NSMutableArray alloc] init];
//            }
//            else {
//                [arrAll removeAllObjects];
//            }
//
//            /*
//             1.push方式
//             这种方式，是实时获取到Accelerometer的数据，并且用相应的队列来显示。即主动获取加速计的数据。
//             */
//            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//
//            [motionManager startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error){
//
//                if (!motionManager.isAccelerometerActive) {
//                    return;
//                }
//
//                //三个方向加速度值
//                double x = accelerometerData.acceleration.x;
//                double y = accelerometerData.acceleration.y;
//                double z = accelerometerData.acceleration.z;
//                //g是一个double值 ,根据它的大小来判断是否计为1步.
//                double g = sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2)) - 1;
//
//                //将信息保存在步数模型中
//                StepModel *stepsAll = [[StepModel alloc] init];
//
//                stepsAll.date = [NSDate date];
//
//                //日期
//                NSDateFormatter *df = [[NSDateFormatter alloc] init] ;
//                df.dateFormat  = @"yyyy-MM-dd HH:mm:ss";
//                NSString *strYmd = [df stringFromDate:stepsAll.date];
//                df = nil;
//                stepsAll.record_time =strYmd;
//
//                stepsAll.g = g;
//                // 加速度传感器采集的原始数组
//                [arrAll addObject:stepsAll];
//
//                // 每采集10条，大约1.2秒的数据时，进行分析
//                if (arrAll.count == 10) {
//
//                    // 步数缓存数组
//                    NSMutableArray *arrBuffer = [[NSMutableArray alloc] init];
//
//                    arrBuffer = [arrAll copy];
//                    [arrAll removeAllObjects];
//
//                    // 踩点数组
//                    NSMutableArray *arrCaiDian = [[NSMutableArray alloc] init];
//
//                    //遍历步数缓存数组
//                    for (int i = 1; i < arrBuffer.count - 2; i++) {
//                        //如果数组个数大于3,继续,否则跳出循环,用连续的三个点,要判断其振幅是否一样,如果一样,然并卵
//                        if (![arrBuffer objectAtIndex:i-1] || ![arrBuffer objectAtIndex:i] || ![arrBuffer objectAtIndex:i+1])
//                        {
//                            continue;
//                        }
//                        StepModel *bufferPrevious = (StepModel *)[arrBuffer objectAtIndex:i-1];
//                        StepModel *bufferCurrent = (StepModel *)[arrBuffer objectAtIndex:i];
//                        StepModel *bufferNext = (StepModel *)[arrBuffer objectAtIndex:i+1];
//                        //控制震动幅度,,,,,,根据震动幅度让其加入踩点数组,
//                        if (bufferCurrent.g < -0.12 && bufferCurrent.g < bufferPrevious.g && bufferCurrent.g < bufferNext.g) {
//                            [arrCaiDian addObject:bufferCurrent];
//                        }
//                    }
//
//                    //如果没有步数数组,初始化
//                    if (nil == self.arrSteps) {
//                        self.arrSteps = [[NSMutableArray alloc] init];
//                        self.arrStepsSave = [[NSMutableArray alloc] init];
//                    }
//
//                    // 踩点过滤
//                    for (int j = 0; j < arrCaiDian.count; j++) {
//                        StepModel *caidianCurrent = (StepModel *)[arrCaiDian objectAtIndex:j];
//
//                        //如果之前的步数为0,则重新开始记录
//                        if (self.arrSteps.count == 0) {
//                            //上次记录的时间
//                            lastDate = caidianCurrent.date;
//
//                            // 重新开始时，纪录No初始化
//                            record_no = 1;
//                            record_no_save = 1;
//
//                            // 运动识别号
//                            NSTimeInterval interval = [caidianCurrent.date timeIntervalSince1970];
//                            NSNumber *numInter = [[NSNumber alloc] initWithDouble:interval*1000];
//                            long long llInter = numInter.longLongValue;
//                            //运动识别id
//                            self.actionId = [NSString stringWithFormat:@"%lld",llInter];
//
//                            self.distance = 0.00f;
//                            self.second = 0;
//                            self.calorie = 0;
//                            self.step = 0;
//
//                            self.gpsDistance = 0.00f;
//                            self.agoGpsDistance = 0.00f;
//                            self.agoActionDistance = 0.00f;
//
//                            caidianCurrent.record_no = record_no;
//                            caidianCurrent.step = (int)self.step;
//
//                            [self.arrSteps addObject:caidianCurrent];
//                            [self.arrStepsSave addObject:caidianCurrent];
//
//                        }
//                        else {
//
//                            int intervalCaidian = [caidianCurrent.date timeIntervalSinceDate:lastDate] * 1000;
//
//                            // 步行最大每秒2.5步，跑步最大每秒3.5步，超过此范围，数据有可能丢失
//                            int min = 259;
//                            if (intervalCaidian >= min) {
//
//                                if (motionManager.isAccelerometerActive) {
//
//                                    //存一下时间
//                                    lastDate = caidianCurrent.date;
//
//                                    if (intervalCaidian >= ACCELERO_START_TIME * 1000) {// 计步器开始计步时间（秒)
//                                        self.startStep = 0;
//                                    }
//
//                                    if (self.startStep < ACCELERO_START_STEP) {//计步器开始计步步数 (步)
//
//                                        self.startStep ++;
//                                        break;
//                                    }
//                                    else if (self.startStep == ACCELERO_START_STEP) {
//                                        self.startStep ++;
//                                        // 计步器开始步数
//                                        // 运动步数（总计）
//                                        self.step = self.step + self.startStep;
//                                    }
//                                    else {
//                                        self.step ++;
//                                    }
//
//
//
//                                    //步数在这里
//                                    NSLog(@"步数%ld",self.step);
//
//                                    int intervalMillSecond = [caidianCurrent.date timeIntervalSinceDate:[[self.arrSteps lastObject] date]] * 1000;
//                                    if (intervalMillSecond >= 1000) {
//
//                                        record_no++;
//
//                                        caidianCurrent.record_no = record_no;
//
//                                        caidianCurrent.step = (int)self.step;
//                                        [self.arrSteps addObject:caidianCurrent];
//                                    }
//
//                                    // 每隔100步保存一条数据（将来插入DB用）
//                                    StepModel *arrStepsSaveVHSSteps = (StepModel *)[self.arrStepsSave lastObject];
//                                    int intervalStep = caidianCurrent.step - arrStepsSaveVHSSteps.step;
//
//                                    // DB_STEP_INTERVAL 数据库存储步数采集间隔（步） 100步
//                                    if (self.arrStepsSave.count == 1 || intervalStep >= DB_STEP_INTERVAL) {
//                                        //保存次数
//                                        record_no_save++;
//                                        caidianCurrent.record_no = record_no_save;
//                                        [self.arrStepsSave addObject:caidianCurrent];
//
//                                                    NSLog(@"---***%ld",self.step);
//                                // 备份当前运动数据至文件中，以备APP异常退出时数据也不会丢失
//                                        // [self bkRunningData];
//
//                                    }
//                                }
//                            }
//
//                            // 运动提醒检查
//                            // [self checkActionAlarm];
//                        }
//                    }
//                }
//            }];
//
//        }
//    }@catch (NSException * e) {
//        NSLog(@"Exception: %@", e);
//        return;
//    }

////得到计步所消耗的卡路里
//+ (NSInteger)getStepCalorie
//{
//    
//}
//
////得到所走的路程(单位:米)
//+ (CGFloat)getStepDistance
//{
//    
//}
//
////得到运动所用的时间
//+ (NSInteger)getStepTime
//{
//    
//}

@end
