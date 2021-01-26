//
//  main.m
//  lumina-control
//
//  Created by Alivan Akbar on 25/01/21.
//  Copyright © 2021 John Boiles . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../LuminaAssistance/assistance.h"

static NSString *serviceName = @"com.luminacam.LuminaAssistance";

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSXPCConnection *conn = [[NSXPCConnection alloc] initWithMachServiceName:serviceName options:0];
        conn.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(assistanceProtocol)];
        conn.invalidationHandler = ^{
            NSLog(@"invalidate");
        };
        conn.interruptionHandler = ^{
            NSLog(@"interrupted");
        };
        NSLog(@"resuming %@", conn.serviceName);
        [conn resume];
        [conn.remoteObjectProxy upperCaseString:@"hello" withReply:^(NSString *result){
            NSLog(@"result %@", result);
        }];
        [NSThread sleepForTimeInterval:0.5f];
    }
    return 0;
}
