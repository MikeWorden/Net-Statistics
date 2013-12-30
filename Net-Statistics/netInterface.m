//
//  netInterface.m
//  iNetstat
//
//  Created by Michael Worden on 12/7/13.
//  Copyright (c) 2013 Michael Worden. All rights reserved.
//

#import "netInterface.h"
#import <SystemConfiguration/CaptiveNetwork.h>

#import "netConnection.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
//#import "DHInet.h"
#import "NetMonitor2.h"




// Private Declarations
@interface netInterface()

-(NSString *) parseAddress: (NSString *)rawAddress;
-(NSString *)fetchSSIDInfo: (NSString *)netDevice;
-(NSString *)fetchCarrierInfo;
-(NSString *)fetchinterfaceInfo: (NSString *)netDevice;
-(NSString *)fetchinterfaceType: (NSString *)netDevice;
-(NSMutableArray *)getConnectionsForInterface: (NSString *) enAddress : (NSArray *) connectionList ;



@end

@implementation netInterface



@synthesize netConnections;
@synthesize deviceName;
@synthesize netAddress;
@synthesize interfaceDetail;
@synthesize interfaceType;


-(id)init {
    if ( self = [super init] ) {
        self.netConnections = nil;
        self.deviceName = @"error";
        self.netAddress = @"error";
        self.interfaceType = @"error";
        self.interfaceDetail = @"error";
    }
    return self;
}

-(id) initWithIFAddr: (NSString *) ifName : (NSString *) ifAddr : (NSArray *) connectionList {
    
    self = [self init];

    self.deviceName = ifName;
    self.netAddress = ifAddr;
    self.interfaceDetail = [self fetchinterfaceInfo:ifName];
    self.interfaceType = [self fetchinterfaceType:ifName];
    self.netConnections = [self getConnectionsForInterface:ifAddr : connectionList];



    return self;
}

-(NSMutableArray *)getConnectionsForInterface: (NSString *) enAddress : (NSArray *) connectionList{
    

    NSArray *allConnections = connectionList;
    
    NSMutableArray *interfaceConnections = [[NSMutableArray alloc] init];
    
    netConnection *newConnection;
    NSString *connectionLocalAddress = NULL;
    NSString *localAddress = NULL;
    NSLog(@"Checking for connections for interface %@", enAddress);
    
    for (NSDictionary * connection in allConnections) {
        
        connectionLocalAddress = [connection objectForKey:@"Local Address"];
        localAddress = [self parseAddress:connectionLocalAddress];
        
        if ([localAddress isEqualToString:enAddress]) {

            newConnection = [[netConnection alloc] initWithConnection:connection];
            [interfaceConnections addObject:newConnection];
        }
        
        
    }
    
    
    
    return interfaceConnections;
    
    
    
}


-(NSString *) parseAddress: (NSString *)rawAddress {
    NSArray *addressArray = [rawAddress componentsSeparatedByString:@"."];
    NSString *host = @"";
    if (rawAddress != nil) {
        for(int i = 0; i <=(addressArray.count - 2) ; i++) {
            host = [host stringByAppendingString:addressArray[i]];
            host = [host stringByAppendingString:@"."];
        }
        host = [host substringToIndex:[host length] - 1];
        if ([rawAddress isEqualToString:@"*.* "] ) {
            host = rawAddress;
        }
        if ([host isEqualToString:@"localhost"] ) {
            host = @"127.0.0.1";
        }
        
    }
    return host;
    
}

-(NSString *)fetchinterfaceType: (NSString *)netDevice{
    
    NSString *Type = @"error";
   
    
    if ([netDevice isEqualToString:@"en0"]) {
        Type = @"Wifi";

    }
    if ([netDevice isEqualToString:@"pdp_ip0"]) {
        Type = @"Cellular";
    }
    if ([netDevice isEqualToString:@"lo0"]) {
        Type = @"Loopback";
    }
    if (!([netDevice rangeOfString:@"vmnet"].location == NSNotFound)) {
        Type = @"Virtual";
    }
    
    return Type;
    
    
}


-(NSString *)fetchinterfaceInfo: (NSString *)netDevice{
    
    NSString *interfaceInfo = @"error";

    
    if ([netDevice isEqualToString:@"en0"]) {
        interfaceInfo = [self fetchSSIDInfo:deviceName];
    }
    if ([netDevice isEqualToString:@"pdp_ip0"]) {
        interfaceInfo = [self fetchCarrierInfo];
    }
    if ([netDevice isEqualToString:@"lo0"]) {

        interfaceInfo = @"Localhost";
    }
    if (!([netDevice rangeOfString:@"vmnet"].location == NSNotFound)) {
        interfaceInfo = @"VMWare";
    }

    
    
    return interfaceInfo;
    
    
}

- (NSString *)fetchSSIDInfo: (NSString *)netDevice
{

    id info = nil;
    NSString *SSID = @"error";
    
    info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)netDevice);
    if (info != nil) {
        SSID = [info objectForKey:@"SSID"];
    }
    return  SSID;
    
}

- (NSString *) fetchCarrierInfo {
    NSString *carrierName = @"error";
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    if (carrier != nil) {
        carrierName = [carrier carrierName];
    }
    return carrierName;
    
}

@end
