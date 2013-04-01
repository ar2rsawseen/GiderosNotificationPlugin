//
//  GNotification.h
//  NotificatinTest
//
//  Created by Arturs Sosins on 3/13/13.
//  Copyright (c) 2013 Arturs Sosins. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GNotification : NSObject
    @property int nid;
    @property int number;
    @property bool isDispatched;
    @property (nonatomic, assign) NSString *title;
    @property (nonatomic, assign) NSString *body;
    @property (nonatomic, assign) NSString *sound;
    @property (nonatomic, assign) NSDate *ftime;
    @property (nonatomic, assign) int repeat;

- (void) createNotification;


@end
