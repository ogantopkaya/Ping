//
//  PingHelper.h
//  ping
//
//  Created by Ogan on 13/01/15.
//  Copyright (c) 2015 Ogan Topkaya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PingHelper : NSObject

/**
 *  Measures and means the ping RTT to specified host
 *
 *  @param host          host
 *  @param numberOfPings numberOfPings to send to host
 *  @param completion    completion gives the meanRTT. Invokes after specified number of pings are finished or timeout after 10 seconds. Result is given in miliseconds.
 */
+ (void)measureRTTWithHost:(NSString *)host numberOfPings:(NSInteger)numberOfPings completion:(void(^)(NSTimeInterval meanRTT))completion;

@end
