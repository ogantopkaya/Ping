//
//  ViewController.m
//  ping
//
//  Created by Ogan on 13/01/15.
//  Copyright (c) 2015 Ogan Topkaya. All rights reserved.
//

#import "ViewController.h"
#import "PingHelper.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [PingHelper measureRTTWithHost:@"google.com" numberOfPings:10 completion:^(NSTimeInterval meanRTT) {
        NSLog(@"mean RTT: %f ms",meanRTT);
    }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
