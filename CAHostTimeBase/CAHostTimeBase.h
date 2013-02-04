//
//  CAHostTimeBase.h
//  CAHostTimeBase
//
//  Created by Павел Литвиненко on 26.01.13.
//  Copyright (c) 2013 Casual Underground. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mach/mach_time.h>

@interface CAHostTimeBase : NSObject

+ (UInt64)convertToNanos:(UInt64)hostTime;
+ (UInt64)convertFromNanos:(UInt64)nanos;
+ (UInt64)getTheCurrentTime;
#if TARGET_OS_MAC
+ (UInt64)getCurrentTime;
#endif
+ (UInt64)getCurrentTimeInNanos;
+ (Float64)getFrequency;
+ (Float64)getInverseFrequency;
+ (UInt32)getMinimumDelta;
+ (UInt64)absoluteHostDeltaToNanosInStartTime:(UInt64)startTime inEndTime:(UInt64)endTime;
+ (SInt64)hostDeltaToNanosInStartTime:(UInt64)startTime inEndTime:(UInt64)endTime;

@end
