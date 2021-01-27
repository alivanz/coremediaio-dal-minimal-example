#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>
#include <Metal/Metal.h>
#import "assistance.h"

@implementation assistance

-(instancetype)init {
    self = [super init];
    image = [self loadImageFile:@"/Library/CoreMediaIO/Plug-Ins/DAL/CMIOMinimalSample.plugin/Contents/Resources/bg.jpg"];
    pixelBuffer = [self getPxBuffer];
    return self;
}
-(void)dealloc {
    CFRelease(pixelBuffer);
}
-(CVPixelBufferRef)getPxBuffer {
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);

    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey, nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options, &pxbuffer);

    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);

    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);

    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, width, height, 8, CVPixelBufferGetBytesPerRow(pxbuffer), rgbColorSpace, kCGImageAlphaPremultipliedFirst | kCGImageByteOrder32Big);
    NSParameterAssert(context);

    [[CIContext contextWithMTLDevice:MTLCreateSystemDefaultDevice()]
         render:[[CIImage alloc] initWithCGImage:image]
         toCVPixelBuffer:pxbuffer
    ];

    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);

    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);

    return pxbuffer;
}

- (CGImageRef) loadImageFile:(NSString*)filename {
  CGDataProviderRef imgDataProvider = CGDataProviderCreateWithCFData((CFDataRef)[NSData dataWithContentsOfFile:filename]);
  CGImageRef image = CGImageCreateWithJPEGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
  CGDataProviderRelease(imgDataProvider);
  return image;
}

// This implements the example protocol. Replace the body of this class with the implementation of this service's protocol.
- (void)upperCaseString:(NSString *)aString withReply:(void (^)(NSString *))reply {
    NSString *response = [aString uppercaseString];
    reply(response);
}
-(void)getPixelBuffer:(void(^)(NSData*))cb {
    char data[4];
    data[0] = 1;
    data[1] = 4;
    data[2] = 1;
    data[3] = 2;
    cb([NSData dataWithBytes:data length:4]);
}

@end
