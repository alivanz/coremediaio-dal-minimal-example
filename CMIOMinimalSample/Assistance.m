//
//  Assistance.m
//  CMIOMinimalSample
//
//  Created by Alivan Akbar on 27/01/21.
//  Copyright © 2021 John Boiles . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Assistance.h"
#import "../LuminaAssistance/assistance.h"
#import "Logging.h"

static NSString *serviceName = @"com.luminacam.LuminaAssistance";

@implementation Assistance
-(instancetype)init {
    self = [super init];
    conn = [[NSXPCConnection alloc] initWithMachServiceName:serviceName options:0];
    conn.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(assistanceProtocol)];
    // setup XPC disconnect
    conn.interruptionHandler = ^{
        DLogFunc(@"XPC interrupted");
    };
    conn.invalidationHandler = ^{
        DLogFunc(@"XPC invalidated");
    };
    // start XPC
    [conn resume];
    // test connection
    DLogFunc(@"XPC begin test");
    [conn.remoteObjectProxy upperCaseString:@"hello" withReply:^(NSString *result){
        DLogFunc(@"TEST OK: result %@", result);
    }];
    return self;
}
-(void)dealloc {
    [conn invalidate];
    DLogFunc(@"XPC dealloc");
}
-(void)test {
    [conn.remoteObjectProxy upperCaseString:@"hello" withReply:^(NSString *result){
        DLogFunc(@"TEST OK: result %@", result);
    }];
}
-(void)getPixelBuffer:(void(^)(CVPixelBufferRef))cb {
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    __weak dispatch_semaphore_t wsem = sem;
    DLogFunc(@"XPC begin call");
    [conn.remoteObjectProxy getPixelBuffer:^(NSData *buffer, OSType type, size_t w, size_t h, size_t stride){
        DLogFunc(@"XPC Success!!");
        CVPixelBufferRef out = NULL;
        CVPixelBufferCreate(kCFAllocatorDefault, w, h, type, NULL, &out);
        CVPixelBufferLockBaseAddress(out, 0);
        memcpy(CVPixelBufferGetBaseAddress(out), buffer.bytes, buffer.length);
        CVPixelBufferUnlockBaseAddress(out, 0);
        cb(out);
        dispatch_semaphore_signal(wsem);
    }];
    DLogFunc(@"XPC wait");
    dispatch_semaphore_wait(sem, 0);
}

@end
