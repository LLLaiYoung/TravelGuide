//
//  DownLoadManager.h
//  CQTravelGuide
//
//  Created by chairman on 15/11/16.
//  Copyright © 2015年 LaiYong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownLoadManager : NSObject

- (void)downloadXML:(NSString *)link withData:(void (^)(NSData *data))dataHandler;
@end
