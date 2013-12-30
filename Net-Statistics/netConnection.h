//
//  netConnection.h
//  iNetstat
//
//  Created by Michael Worden on 12/8/13.
//  Copyright (c) 2013 Michael Worden. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface netConnection : NSObject {
    NSString *foreignAddress;
    NSString *foreignPort;
    NSString *localAddress;
    NSString *localPort;
    NSString *state;
    NSString *rxBytes;  //TODO:  change this to a uLongLong later
    NSString *txBytes;  //TODO:  change this to a ulongLong later
    NSString *rxQueue;  //TODO:  change this to a uLong later
    NSString *txQueue;  //TODO:  change this to a ulong later
    NSString *protocol;
}

@property (nonatomic, strong) NSString *foreignAddress;
@property (nonatomic, strong) NSString *foreignPort;
@property (nonatomic, strong) NSString *localAddress;
@property (nonatomic, strong) NSString *localPort;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *rxBytes;
@property (nonatomic, strong) NSString *txBytes;
@property (nonatomic, strong) NSString *rxQueue;
@property (nonatomic, strong) NSString *txQueue;
@property (nonatomic, strong) NSString *protocol;

-(id) initWithConnection: (NSDictionary *) newConnection;



@end
