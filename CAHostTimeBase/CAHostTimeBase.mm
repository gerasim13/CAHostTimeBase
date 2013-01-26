//
//  CAHostTimeBase.m
//  CAHostTimeBase
//
//  Created by Павел Литвиненко on 26.01.13.
//  Copyright (c) 2013 Casual Underground. All rights reserved.
//

#import "CAHostTimeBase.h"
#import "_CAHostTimeBase.h"

@implementation CAHostTimeBase

+ (UInt64)convertToNanos:(UInt64)hostTime
{
    return _CAHostTimeBase::ConvertToNanos(hostTime);
}

+ (UInt64)convertFromNanos:(UInt64)nanos
{
    return _CAHostTimeBase::ConvertFromNanos(nanos);
}

+ (UInt64)getTheCurrentTime
{
    return _CAHostTimeBase::GetTheCurrentTime();
}

+ (UInt64)getCurrentTime
{
    return _CAHostTimeBase::GetCurrentTime();
}

+ (UInt64)getCurrentTimeInNanos
{
    return _CAHostTimeBase::GetCurrentTimeInNanos();
}

+ (Float64)getFrequency
{
    return _CAHostTimeBase::GetFrequency();
}

+ (Float64)getInverseFrequency
{
    return _CAHostTimeBase::GetInverseFrequency();
}

+ (UInt32)getMinimumDelta
{
    return _CAHostTimeBase::GetMinimumDelta();
}

+ (UInt64)absoluteHostDeltaToNanosInStartTime:(UInt64)startTime inEndTime:(UInt64)endTime
{
    return _CAHostTimeBase::AbsoluteHostDeltaToNanos(startTime, endTime);
}

+ (SInt64)hostDeltaToNanosInStartTime:(UInt64)startTime inEndTime:(UInt64)endTime
{
    return _CAHostTimeBase::HostDeltaToNanos(startTime, endTime);
}

#pragma mark Helper methods

inline mach_timebase_info_data_t timebaseInfo() {
    static mach_timebase_info_data_t timeInfo;
    if (timeInfo.denom == 0) {
        (void)mach_timebase_info(&timeInfo);
    }
    return timeInfo;
}

+ (SInt64)msecsToNanos:(Float32)msecs
{
    mach_timebase_info_data_t timebase = timebaseInfo();
    return (msecs * 1000 * 1000 * timebase.denom / timebase.numer);
}

+ (SInt64)secondsToNanos:(Float32)seconds
{
    return [CAHostTimeBase msecsToNanos:(seconds * 1000.0)];
}

+ (SInt32)nanosToMsecs:(SInt64)nanos
{
    const SInt32 kOneMillion = 1000 * 1000;
    mach_timebase_info_data_t timebase = timebaseInfo();
    SInt32 msecs = (SInt32)((nanos * timebase.numer) / (kOneMillion * timebase.denom));
    return msecs;
}
+ (Float32)nanosToSeconds:(SInt64)nanos
{
    SInt32 msecs = [CAHostTimeBase nanosToMsecs:nanos];
    Float32 secs = msecs / 1000.0;
    return secs;
}
+ (UInt64)tickTimeFromBpm:(Float32)bpm
{
    Float32 tick = 1.0 / ((bpm * 24) / 60.0);
    UInt64  time = [CAHostTimeBase secondsToNanos:tick];
    return time;
}
+ (Float32)bpmFromTickTime:(UInt64)tick
{
    return 60.0 / tick / 24;
}

@end
