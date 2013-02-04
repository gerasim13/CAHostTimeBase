//
//  CAHostTimeBase.m
//  CAHostTimeBase
//
//  Created by Павел Литвиненко on 26.01.13.
//  Copyright (c) 2013 Casual Underground. All rights reserved.
//

#import "CAHostTimeBase.h"

static Float64 sFrequency = 0;
static Float64 sInverseFrequency = 0;
static UInt32  sMinDelta = 0;
static UInt32  sToNanosNumerator = 0;
static UInt32  sToNanosDenominator = 0;
static UInt32  sFromNanosNumerator = 0;
static UInt32  sFromNanosDenominator = 0;
//static bool    sUseMicroseconds = false;
static bool    sIsInited = false;
#if Track_Host_TimeBase
static UInt64  sLastTime = 0;
#endif

@implementation CAHostTimeBase

+ (void)initialize
{
	//	get the info about Absolute time
#if TARGET_OS_MAC
    struct mach_timebase_info	theTimeBaseInfo;
    mach_timebase_info(&theTimeBaseInfo);
    sMinDelta = 1;
    sToNanosNumerator = theTimeBaseInfo.numer;
    sToNanosDenominator = theTimeBaseInfo.denom;
    sFromNanosNumerator = sToNanosDenominator;
    sFromNanosDenominator = sToNanosNumerator;
    
    //	the frequency of that clock is: (sToNanosDenominator / sToNanosNumerator) * 10^9
    sFrequency = sToNanosDenominator / sToNanosNumerator;
    sFrequency *= 1000000000.0;
#elif TARGET_OS_WIN32
    LARGE_INTEGER theFrequency;
    QueryPerformanceFrequency(&theFrequency);
    sMinDelta = 1;
    sToNanosNumerator = 1000000000ULL;
    sToNanosDenominator = *((UInt64*)&theFrequency);
    sFromNanosNumerator = sToNanosDenominator;
    sFromNanosDenominator = sToNanosNumerator;
    sFrequency = (*((UInt64*)&theFrequency));
#endif
	sInverseFrequency = 1.0 / sFrequency;
	
#if	Log_Host_Time_Base_Parameters
    DebugMessage(  "Host Time Base Parameters");
    DebugMessageN1(" Minimum Delta:          %lu", sMinDelta);
    DebugMessageN1(" Frequency:              %f", sFrequency);
    DebugMessageN1(" To Nanos Numerator:     %lu", sToNanosNumerator);
    DebugMessageN1(" To Nanos Denominator:   %lu", sToNanosDenominator);
    DebugMessageN1(" From Nanos Numerator:   %lu", sFromNanosNumerator);
    DebugMessageN1(" From Nanos Denominator: %lu", sFromNanosDenominator);
#endif
    
	sIsInited = true;
}

+ (UInt64)convertToNanos:(UInt64)hostTime
{
    if(!sIsInited)
	{
        [CAHostTimeBase initialize];
	}
	
	Float64 theNumerator = sToNanosNumerator;
	Float64 theDenominator = sToNanosDenominator;
	Float64 theHostTime = hostTime;
    
	Float64 thePartialAnswer = theHostTime / theDenominator;
	Float64 theFloatAnswer = thePartialAnswer * theNumerator;
	UInt64 theAnswer = theFloatAnswer;
    
	//Assert(!((theNumerator > theDenominator) && (theAnswer < inHostTime)), "CAHostTimeBase::ConvertToNanos: The conversion wrapped");
	//Assert(!((theDenominator > theNumerator) && (theAnswer > inHostTime)), "CAHostTimeBase::ConvertToNanos: The conversion wrapped");
    
	return theAnswer;
}

+ (UInt64)convertFromNanos:(UInt64)nanos
{
    if(!sIsInited)
	{
        [CAHostTimeBase initialize];
	}
    
	Float64 theNumerator = sToNanosNumerator;
	Float64 theDenominator = sToNanosDenominator;
	Float64 theNanos = nanos;
    
	Float64 thePartialAnswer = theNanos / theNumerator;
	Float64 theFloatAnswer = thePartialAnswer * theDenominator;
	UInt64 theAnswer = theFloatAnswer;
    
	//Assert(!((theDenominator > theNumerator) && (theAnswer < inNanos)), "CAHostTimeBase::ConvertToNanos: The conversion wrapped");
	//Assert(!((theNumerator > theDenominator) && (theAnswer > inNanos)), "CAHostTimeBase::ConvertToNanos: The conversion wrapped");
    
	return theAnswer;
}

+ (UInt64)getTheCurrentTime
{
    UInt64 theTime = 0;
    
#if TARGET_OS_MAC
    theTime = mach_absolute_time();
#elif TARGET_OS_WIN32
    LARGE_INTEGER theValue;
    QueryPerformanceCounter(&theValue);
    theTime = *((UInt64*)&theValue);
#endif
	
#if	Track_Host_TimeBase
    if(sLastTime != 0)
    {
        if(theTime <= sLastTime)
        {
            DebugMessageN2("CAHostTimeBase::GetTheCurrentTime: the current time is earlier than the last time, now: %qd, then: %qd", theTime, sLastTime);
        }
        sLastTime = theTime;
    }
    else
    {
        sLastTime = theTime;
    }
#endif
    
	return theTime;
}

+ (UInt64)getCurrentTime
{
    return [CAHostTimeBase getTheCurrentTime];
}

+ (UInt64)getCurrentTimeInNanos
{
    return [CAHostTimeBase convertToNanos:[CAHostTimeBase getTheCurrentTime]];
}

+ (Float64)getFrequency
{
    if(!sIsInited)
	{
        [CAHostTimeBase initialize];
	}
    
    return sFrequency;
}

+ (Float64)getInverseFrequency
{
    if(!sIsInited)
	{
        [CAHostTimeBase initialize];
	}
    
    return sInverseFrequency;
}

+ (UInt32)getMinimumDelta
{
    if(!sIsInited)
	{
        [CAHostTimeBase initialize];
	}
    
    return sMinDelta;
}

+ (UInt64)absoluteHostDeltaToNanosInStartTime:(UInt64)startTime inEndTime:(UInt64)endTime
{
    UInt64 theAnswer;
	
	if(startTime <= endTime)
	{
		theAnswer = endTime - startTime;
	}
	else
	{
		theAnswer = startTime - endTime;
	}
	
	return [CAHostTimeBase convertToNanos:theAnswer];
}

+ (SInt64)hostDeltaToNanosInStartTime:(UInt64)startTime inEndTime:(UInt64)endTime
{
    SInt64 theAnswer;
	SInt64 theSign = 1;
	
	if(startTime <= endTime)
	{
		theAnswer = endTime - startTime;
	}
	else
	{
		theAnswer = startTime - endTime;
		theSign = -1;
	}
	
	return theSign * [CAHostTimeBase convertToNanos:theAnswer];
}

@end
