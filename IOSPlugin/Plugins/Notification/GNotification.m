//
//  GNotification.m
//  NotificatinTest
//
//  Created by Arturs Sosins on 3/13/13.
//  Copyright (c) 2013 Arturs Sosins. All rights reserved.
//

#import "GNotification.h"
#import "NotificationClass.h"

@implementation GNotification

-(GNotification*)init{
    self.nid = 0;
    self.number = 0;
    self.title = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    self.body = @"";
    self.sound = @"";
    self.repeat = 0;
    self.isDispatched = false;

    return self;
}


-(void)createNotification{
    if(self.isDispatched)
    {
        [NotificationClass internalCancel:self.nid];
    }
    UILocalNotification *notif = [[UILocalNotification alloc] init];
    notif.alertAction = self.title;
    notif.alertBody = self.body;
    notif.timeZone = [NSTimeZone defaultTimeZone];
    
    if (self.number > 0) {
        notif.applicationIconBadgeNumber = self.number;
    }
    
    if (self.repeat > 0) {
        notif.repeatInterval = self.repeat;
    }
    
    if (self.ftime == NULL) {
        NSDate *date = [[NSDate date] addTimeInterval:10];
        notif.fireDate = date;
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    else{
        notif.fireDate = self.ftime;
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"yyyy-MM-dd HH:mm:ss";

    }
    
    if([self.sound isEqualToString:@"default"]){
        notif.soundName = UILocalNotificationDefaultSoundName;
    }
    else if(![self.sound isEqualToString:@""]){
        notif.soundName = [NSString stringWithFormat:@"assets/%@", self.sound];
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", self.nid],@"nid", nil];
    
    notif.userInfo = userInfo;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notif];
    [NotificationClass safe:self.nid title:self.title body:self.body sound:self.sound number:self.number inRepo:@"NotificationLocal"];
}

@end
