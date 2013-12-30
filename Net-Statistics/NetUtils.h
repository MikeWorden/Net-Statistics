//
//  NetUtils.h
//  iNetstat
//
//  Created by Michael Worden on 12/5/13.
//  Copyright (c) 2013 Michael Worden. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface iDevice : NSObject {
    NSMutableArray *netInterfaces;
    
        
}

@property (nonatomic, retain) NSArray* netInterfaces;

-(NSArray *)getInterfaces;
-(void) updateConnections;




@end



