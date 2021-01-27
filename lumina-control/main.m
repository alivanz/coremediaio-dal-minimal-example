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
        [conn.remoteObjectProxy getPixelBuffer:^(NSData *buffer){
            for (NSUInteger i=0; i<buffer.length; i++) {
                const char *data = buffer.bytes;
                NSLog(@"data %i", data[i]);
            }
        }];
        [NSThread sleepForTimeInterval:0.5f];
    }
    return 0;
}
