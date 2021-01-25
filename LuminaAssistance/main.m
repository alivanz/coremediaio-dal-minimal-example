//
//  main.m
//  LuminaAssistance
//
//  Created by Alivan Akbar on 25/01/21.
//  Copyright © 2021 John Boiles . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "assistance.h"
#import "protocol.h"

static NSString *serviceName = @"com.luminacam.LuminaAssistance";

@interface ServiceDelegate : NSObject <NSXPCListenerDelegate>
@end

@implementation ServiceDelegate

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
    // This method is where the NSXPCListener configures, accepts, and resumes a new incoming NSXPCConnection.
    
    // Configure the connection.
    // First, set the interface that the exported object implements.
    newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(assistanceProtocol)];
    
    // Next, set the object that the connection exports. All messages sent on the connection to this service will be sent to the exported object to handle. The connection retains the exported object.
    assistance *exportedObject = [assistance new];
    newConnection.exportedObject = exportedObject;
    
    // Resuming the connection allows the system to deliver more incoming messages.
    [newConnection resume];
    
    // Returning YES from this method tells the system that you have accepted this connection. If you want to reject the connection for some reason, call -invalidate on the connection and return NO.
    return YES;
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSLog(@"Creating service %@", serviceName);
        NSXPCListener *listener = [[NSXPCListener alloc] initWithMachServiceName:serviceName];
        ServiceDelegate *delegate = [ServiceDelegate new];
        listener.delegate = delegate;
        NSLog(@"resuming connection");
        [listener resume];
        NSLog(@"running loop");
        CFRunLoopRun();
        return 0;
    }
    return 0;
}
