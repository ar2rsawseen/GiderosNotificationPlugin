//
//  NotificationClass.h
//  NotificatinTest
//
//  Created by Arturs Sosins on 3/13/13.
//  Copyright (c) 2013 Arturs Sosins. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationClass : NSObject

+(void)initialize;
+(void)deinitialize;
+(void)onActive;
+(void)init:(int)nid;
+(void)cleanup:(int) nid;

+(void)setTitle:(NSString*)title withID:(int) nid;
+(NSString*)getTitle:(int) nid;
+(void)setBody:(NSString*)body withID:(int) nid;
+(NSString*)getBody:(int) nid;
+(void)setSound:(NSString*)sound withID:(int) nid;
+(NSString*)getSound:(int) nid;
+(void)setNumber:(int)number withID:(int) nid;
+(int)getNumber:(int) nid;


+(void)dispatchNow:(int) nid;
+(void)dispatchOn:(int) nid onDate:(NSMutableDictionary*) date;
+(void)dispatchOn:(int) nid onDate:(NSMutableDictionary*) date repeating:(NSMutableDictionary*)repeat;
+(void)dispatchAfter:(int) nid onDate:(NSMutableDictionary*) date;
+(void)dispatchAfter:(int) nid onDate:(NSMutableDictionary*) date repeating:(NSMutableDictionary*)repeat;

+(void)cancel:(int) nid;
+(void)cancelAll;

+(void)registerForPushNotifications;
+(void)unRegisterForPushNotifications;

+(void)readyForEvents;

+(void)onPreLocalHandler: (NSNotification*) note;
+(void)onPrePushHandler: (NSNotification*) note;
+(void)onLocalHandler: (UILocalNotification*) note;
+(void)onPushHandler: (NSDictionary*) note;
+(void)onPushRegistration: (NSNotification*) n;
+(void)onPushError: (NSNotification*) n;

+(NSMutableDictionary*)getScheduledNotifications;
+(NSMutableDictionary*)getLocalNotifications;
+(NSMutableDictionary*)getPushNotifications;
+(void)clearLocalNotifications;
+(void)clearPushNotifications;


+(void)safe:(int)nid title:(NSString*)title body:(NSString*)body sound:(NSString*)sound number:(int)number inRepo:(NSString*) repo;
+(void)internalCancel:(int) nid;

@end
