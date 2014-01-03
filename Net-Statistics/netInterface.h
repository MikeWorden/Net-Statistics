//
//  netInterface.h
//  iNetstat
//
//  Created by Michael Worden on 12/7/13.
//  Copyright (c) 2013 Michael Worden. All rights reserved.
//

#import <Foundation/Foundation.h>





@interface netInterface : NSObject {
    
    NSString *interfaceType;
    NSString *interfaceDetail;
    NSString *deviceName;
    NSString *netAddress;
    NSMutableArray *netConnections;
    
}


@property (nonatomic, retain) NSString *deviceName;
@property (nonatomic, retain) NSString *netAddress;
@property (nonatomic, retain) NSMutableArray *netConnections;
@property (nonatomic, retain) NSString *interfaceType;
@property (nonatomic, retain) NSString *interfaceDetail;


-(id) initWithIFAddr: (NSString *) ifName : (NSString *) ifAddr : (NSArray *) connectionList;



@end
