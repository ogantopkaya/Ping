//
//  PingHelper.m
//  ping
//
//  Created by Ogan on 13/01/15.
//  Copyright (c) 2015 Ogan Topkaya. All rights reserved.
//

#import "PingHelper.h"
#import "SimplePing.h"


const NSTimeInterval kTimeoutDuration = 10;

@interface PingHelper () <SimplePingDelegate>

@property (nonatomic,strong)SimplePing *simplePing;
@property (nonatomic,strong)NSMutableDictionary *pingRTTs;

@property (nonatomic) NSInteger numberOfPings;
@property (nonatomic) BOOL pingingFinished;
@property (nonatomic) NSTimeInterval meanRTT;

@end


@implementation PingHelper

+ (void)measureRTTWithHost:(NSString *)host numberOfPings:(NSInteger)numberOfPings completion:(void(^)(NSTimeInterval meanRTT))completion{
    
    PingHelper * pingHelper = [[[self class] alloc] initWithHost:host];
    pingHelper.numberOfPings = numberOfPings;
    [pingHelper startPinging];
    
    if (completion != NULL) {
        completion(pingHelper.meanRTT * 1000);
    }
}


- (instancetype)initWithHost:(NSString *)host{
    self = [super init];
    if (self) {
        self.pingingFinished = NO;
        self.simplePing = [SimplePing simplePingWithHostName:host];
        self.simplePing.delegate = self;
    }
    return self;
}

- (void)startPinging{
    NSDate *limitDate = [[NSDate date] dateByAddingTimeInterval:kTimeoutDuration];
    
    [self.simplePing start];
    
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:limitDate];
        if ([limitDate compare:[NSDate date]] == NSOrderedAscending) break;
    } while (!self.pingingFinished);

}

- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address{
    for (int i = 0; i<self.numberOfPings; i++) {
        [pinger sendPingWithData:nil];
    }
}

- (void)simplePing:(SimplePing *)pinger didSendPacket:(NSData *)packet{
    unsigned int pingSequenceNumber = (unsigned int) OSSwapBigToHostInt16(((const ICMPHeader *) [packet bytes])->sequenceNumber);
    self.pingRTTs[@(pingSequenceNumber)] = [NSDate date];
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet{
    unsigned int pingSequenceNumber = (unsigned int) OSSwapBigToHostInt16([SimplePing icmpInPacket:packet]->sequenceNumber);
    id pingSendDate = self.pingRTTs[@(pingSequenceNumber)];
    if ([pingSendDate isKindOfClass:[NSDate class]]) {
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:pingSendDate];
        self.pingRTTs[@(pingSequenceNumber)] = @(timeInterval);
    }
    
    __block NSInteger pingCount = 0;
    [self.pingRTTs enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSNumber class]]) {
            pingCount++;
        }
    }];
    
    if (pingCount >= self.numberOfPings) {
        [self finishPinging];
    }
}

- (void)finishPinging{
    self.pingingFinished = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(finishPinging) object:nil];
}

- (NSTimeInterval)meanRTT{
    __block NSTimeInterval totalRTT = 0;
    
    [self.pingRTTs enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSNumber class]]) {
            totalRTT += [obj doubleValue];
        }
        else{
            totalRTT += kTimeoutDuration;
        }
    }];
    
    return totalRTT / self.pingRTTs.count;
}

- (NSMutableDictionary *)pingRTTs{
    if (!_pingRTTs) {
        _pingRTTs = [NSMutableDictionary new];
    }
    return _pingRTTs;
}

@end
