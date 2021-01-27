#ifndef assistance_h
#define assistance_h

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>
#import "protocol.h"

// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
@interface assistance : NSObject <assistanceProtocol> {
    CGImageRef image;
    CVPixelBufferRef pixelBuffer;
    NSData *data;
}
@end

#endif /* assistance_h */
