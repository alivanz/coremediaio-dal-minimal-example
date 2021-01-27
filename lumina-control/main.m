//
//  main.m
//  lumina-control
//
//  Created by Alivan Akbar on 25/01/21.
//  Copyright © 2021 John Boiles . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../LuminaAssistance/protocol.h"

static NSString *serviceName = @"com.luminacam.LuminaAssistance";

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSXPCConnection *conn = [[NSXPCConnection alloc] initWithMachServiceName:serviceName options:0];
        conn.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(assistanceProtocol)];
        dispatch_semaphore_t sem0 = dispatch_semaphore_create(0);
        dispatch_semaphore_t sem1 = dispatch_semaphore_create(0);
        conn.invalidationHandler = ^{
            NSLog(@"invalidate");
            dispatch_semaphore_signal(sem0);
            dispatch_semaphore_signal(sem1);
        };
        conn.interruptionHandler = ^{
            NSLog(@"interrupted");
            dispatch_semaphore_signal(sem0);
            dispatch_semaphore_signal(sem1);
        };
        NSLog(@"resuming %@", conn.serviceName);
        [conn resume];
        [conn.remoteObjectProxy upperCaseString:@"hello" withReply:^(NSString *result){
            NSLog(@"result %@", result);
            dispatch_semaphore_signal(sem0);
        }];
        [conn.remoteObjectProxy getPixelBuffer:^(NSData *buffer, OSType type, size_t w, size_t h, size_t stride){
            NSLog(@"buffer length %lu", buffer.length);
            NSLog(@"%lux%lu", w, h);
            dispatch_semaphore_signal(sem1);
        }];
        dispatch_semaphore_wait(sem0, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_wait(sem1, DISPATCH_TIME_FOREVER);
    }
    return 0;
}
