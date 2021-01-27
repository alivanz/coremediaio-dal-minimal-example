//
//  Assistance.h
//  CMIOMinimalSample
//
//  Created by Alivan Akbar on 27/01/21.
//  Copyright © 2021 John Boiles . All rights reserved.
//

#ifndef Assistance_h
#define Assistance_h

#include <CoreImage/CoreImage.h>

@interface Assistance : NSObject {
    NSXPCConnection *conn;
}
-(void)test;
-(void)getPixelBuffer:(void(^)(CVPixelBufferRef))cb;
@end

#endif /* Assistance_h */
