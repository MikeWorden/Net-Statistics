//
//  netConnection.m
//  iNetstat
//
//  Created by Michael Worden on 12/8/13.
//  Copyright (c) 2013 Michael Worden. All rights reserved.
//

#import "netConnection.h"

@interface netConnection ()

-(NSString *) parseAddress: (NSString *)rawAddress;
-(NSString *) parsePort: (NSString *)rawAddress;

@end


@implementation netConnection
@synthesize localAddress, localPort, foreignAddress, foreignPort, state, txBytes, rxBytes, rxQueue, txQueue, protocol;

-(id)init {
    if ( self = [super init] ) {
        self.localAddress = @"error";
        self.localPort = @"error";
        self.foreignAddress = @"error";
        self.foreignPort =@"error";
        self.state = @"error";
        self.txBytes = 0;
        self.rxBytes = 0;
        self.txQueue = 0;
        self.rxQueue = 0;
        self.protocol = @"error";
    }
    return self;
}

-(id) initWithConnection: (NSDictionary *) newConnection {
    if (self = [self init]) {
        self.localAddress = [self parseAddress:[newConnection objectForKey:@"Local Address"]];
        self.localPort = [self parsePort:[newConnection objectForKey:@"Local Address"]];
        self.foreignAddress = [self parseAddress:[newConnection objectForKey:@"Foreign Address"]];
        self.foreignPort = [self parsePort:[newConnection objectForKey:@"Foreign Address"]];
        self.state = [newConnection objectForKey:@"State"];
        self.txBytes = [[newConnection objectForKey:@"Tx-Bytes"] stringValue];
        self.rxBytes = [[newConnection objectForKey:@"Rx-Bytes"] stringValue];
        self.txQueue = [[newConnection objectForKey:@"Send-Q"] stringValue];
        self.rxQueue = [[newConnection objectForKey:@"Recv-Q"] stringValue];
        self.protocol = [newConnection objectForKey:@"Proto"];
    }
    
    
    return self;
    
}

-(NSString *) parseAddress: (NSString *)rawAddress {
    NSArray *addressArray = [rawAddress componentsSeparatedByString:@"."];
    NSString *host = @"";
    if (rawAddress != nil) {
        for(int i = 0; i <=(addressArray.count - 2) ; i++) {
            host = [host stringByAppendingString:addressArray[i]];
            host = [host stringByAppendingString:@"."];
        }
        //get rid of trailing "dot"
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

-(NSString *) parsePort: (NSString *)rawAddress {
    NSArray *addressArray = [rawAddress componentsSeparatedByString:@"."];
    NSString *port = @"";
    if (rawAddress != nil) {
        //Parsing only IPv4 addresses (avoiding *.* listening ports)
        if(addressArray.count > 2) {
            port = addressArray[addressArray.count -1];
        }
        
        
    }
    return port;
    
}
@end
