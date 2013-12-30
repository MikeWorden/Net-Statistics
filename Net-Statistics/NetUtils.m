//
//  NetUtils.m
//  iNetstat
//
//  Created by Michael Worden on 12/5/13.
//  Copyright (c) 2013 Michael Worden. All rights reserved.
//

#import "NetUtils.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "netInterface.h"
#import "NetMonitor2.h"




@implementation iDevice
@synthesize netInterfaces;


-(id)init {
    if ( self = [super init] ) {
        self.netInterfaces = nil;
        self.netInterfaces = [self getInterfaces];
    }
    for (netInterface *i in self.netInterfaces) {
        NSLog(@" Interface Name: %@, address: %@, Type:  %@ number of connections: %d", i.deviceName, i.netAddress, i.interfaceType, i.netConnections.count);
        
    }
    return self;
}



-(NSArray *)getInterfaces {
    
    
    NSArray *interfaceList = [[NSArray alloc] init];
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    NSString *interfaceName =@"error";
    NSString *interfaceAddress =@"error";
    netInterface *newInterface = NULL;

    int gotInterfaces = 0;
    
    netMonitor2 *netMon = [[netMonitor2 alloc] init];
    
    NSArray *connectionList = [netMon getTCPConnections];
    
    
    gotInterfaces = getifaddrs(&interfaces);
    
    if (gotInterfaces == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                interfaceName = [NSString stringWithUTF8String:temp_addr->ifa_name];
                interfaceAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                newInterface = [[netInterface alloc] initWithIFAddr:interfaceName :interfaceAddress : connectionList];
                interfaceList = [interfaceList arrayByAddingObject:newInterface];
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    interfaceList  = [[interfaceList reverseObjectEnumerator] allObjects];
    return interfaceList;
}


-(void) updateConnections {
    self.netInterfaces = [self getInterfaces];
}



@end

