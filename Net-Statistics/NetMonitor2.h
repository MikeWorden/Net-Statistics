//
//  NetMonitor2.h
//  netMon
//
//  Created by Michael Worden on 12/26/13.
//  Copyright (c) 2013 Michael Worden. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface netMonitor2 : NSObject

- (NSArray *) getTCPConnections;
- (NSArray *) getUDPConnections;

@end
