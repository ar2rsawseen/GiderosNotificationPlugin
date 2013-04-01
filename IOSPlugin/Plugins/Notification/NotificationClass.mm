//
//  NotificationClass.mm
//  NotificatinTest
//
//  Created by Arturs Sosins on 3/13/13.
//  Copyright (c) 2013 Arturs Sosins. All rights reserved.
//
#import "NotificationClass.h"
#import "GNotification.h"
#include "notification_wrapper.h"

@implementation NotificationClass

static bool canDispatch = false;
static NSMutableDictionary *notifics = [NSMutableDictionary dictionary];
+(void)initialize{

    //subscribe to events
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(onLocalHandler) name:UIApplicationLaunchOptionsLocalNotificationKey object:nil];
    [center addObserver:self selector:@selector(onPushHandler) name:UIApplicationLaunchOptionsRemoteNotificationKey object:nil];
    [center addObserver:self selector:@selector(onActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [center addObserver:self selector:@selector(onPushRegistration:) name:@"onPushRegistration" object:nil];
    [center addObserver:self selector:@selector(onPushError:) name:@"onPushRegistrationError" object:nil];
    [center addObserver:self selector:@selector(onPrePushHandler:) name:@"onPushNotification" object:nil];
    [center addObserver:self selector:@selector(onPreLocalHandler:) name:@"onLocalNotification" object:nil];
}

+(void)onActive{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

+(void)deinitialize{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
    
    for(NSString *key in notifics){
        GNotification *note = [notifics objectForKey:key];
        [note release];
        note = nil;
    }
    
    [notifics removeAllObjects];
    
    canDispatch = false;
}

+(void)init:(int) nid{
 
    GNotification *note = [[[GNotification alloc] init] autorelease];
        
    note.nid = nid;
    NSMutableDictionary *dic = [NotificationClass get:nid fromRepo:@"NotificationLocal"];
    if(dic != NULL)
    {
        note.isDispatched = true;
        note.title = [dic objectForKey:@"title"];
        note.body = [dic objectForKey:@"body"];
        note.sound = [dic objectForKey:@"sound"];
        note.number = [[dic objectForKey:@"title"] intValue];
    }
    [notifics setObject:note forKey:[NSString stringWithFormat:@"%d", nid]];
        
}

+(void)cleanup:(int) nid{
    GNotification *note = [notifics objectForKey:[NSString stringWithFormat:@"%d", nid]];
    if(note != NULL){
        [notifics removeObjectForKey:[NSString stringWithFormat:@"%d", nid]];
        note = nil;
    }
}

+(void)setTitle:(NSString*)title withID:(int) nid{
    GNotification *note = [notifics objectForKey:[NSString stringWithFormat:@"%d", nid]];
    if(note != NULL){
        note.title = title;
    }
}

+(NSString*)getTitle:(int) nid{
    GNotification *note = [notifics objectForKey:[NSString stringWithFormat:@"%d", nid]];
    if(note != NULL){
        return note.title;
    }
    return @"";
}

+(void)setBody:(NSString*)body withID:(int) nid{
    GNotification *note = [notifics objectForKey:[NSString stringWithFormat:@"%d", nid]];
    if(note != NULL){
        note.body = body;
    }
}

+(NSString*)getBody:(int) nid{
    GNotification *note = [notifics objectForKey:[NSString stringWithFormat:@"%d", nid]];
    if(note != NULL){
        return note.body;
    }
    return @"";
}

+(void)setSound:(NSString*)sound withID:(int) nid{
    GNotification *note = [notifics objectForKey:[NSString stringWithFormat:@"%d", nid]];
    if(note != NULL){
        note.sound = sound;
    }
}

+(NSString*)getSound:(int) nid{
    GNotification *note = [notifics objectForKey:[NSString stringWithFormat:@"%d", nid]];
    if(note != NULL){
        return note.sound;
    }
    return @"";
}

+(void)setNumber:(int)number withID:(int) nid{
    GNotification *note = [notifics objectForKey:[NSString stringWithFormat:@"%d", nid]];
    if(note != NULL){
        note.number = number;
    }
}

+(int)getNumber:(int) nid{
    GNotification *note = [notifics objectForKey:[NSString stringWithFormat:@"%d", nid]];
    if(note != NULL){
        return note.number;
    }
    return 0;
}

+(void)dispatchNow:(int) nid{
    GNotification *note = [notifics objectForKey:[NSString stringWithFormat:@"%d", nid]];
    if(note != NULL){
        [note createNotification];
    }
}

+(void)dispatchOn:(int) nid onDate:(NSMutableDictionary*) date {
    GNotification *note = [notifics objectForKey:[NSString stringWithFormat:@"%d", nid]];
    if(note != NULL){
        NSDateComponents *comps = [NotificationClass getDate:date];
        note.ftime = [[NSCalendar currentCalendar] dateFromComponents:comps];
        [note createNotification];
    }
}

+(void)dispatchOn:(int) nid onDate:(NSMutableDictionary*) date repeating:(NSMutableDictionary*)repeat {
    GNotification *note = [notifics objectForKey:[NSString stringWithFormat:@"%d", nid]];
    if(note != NULL){
        NSDateComponents *comps = [NotificationClass getDate:date];
        note.ftime = [[NSCalendar currentCalendar] dateFromComponents:comps];
        comps = [NotificationClass getDate:date];
        note.repeat = [[[NSCalendar currentCalendar] dateFromComponents:comps] timeIntervalSince1970];
        [note createNotification];
    }
}

+(void)dispatchAfter:(int) nid onDate:(NSMutableDictionary*) date {
    GNotification *note = [notifics objectForKey:[NSString stringWithFormat:@"%d", nid]];
    if(note != NULL){
        NSDateComponents *comps = [NotificationClass getDate:date];
        note.ftime = [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:[NSDate date] options:0];
        [note createNotification];
    }
}

+(void)dispatchAfter:(int) nid onDate:(NSMutableDictionary*) date repeating:(NSMutableDictionary*)repeat {
    GNotification *note = [notifics objectForKey:[NSString stringWithFormat:@"%d", nid]];
    if(note != NULL){
        NSDateComponents *comps = [NotificationClass getDate:date];
        note.ftime = [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:[NSDate date] options:0];
        comps = [NotificationClass getDate:date];
        note.repeat = [[[NSCalendar currentCalendar] dateFromComponents:comps] timeIntervalSince1970];
        [note createNotification];
    }
}

+(void)registerForPushNotifications{
    // Let the device know we want to receive push notifications
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
}

+(void)unRegisterForPushNotifications{
    // Let the device know we don't want to receive push notifications
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
}

+(void)readyForEvents{
    canDispatch = true;
    [NotificationClass dispatchEvents:@"NotificationLocalEvent"];
    [NotificationClass dispatchEvents:@"NotificationPushEvent"];
}

+(void)dispatchEvents:(NSString*)type{
    NSMutableDictionary *arr = [NotificationClass getAll:type];
    if(arr)
    {
        for (NSString *key in arr) {
            NSMutableDictionary *dic = [arr objectForKey:key];
            if([type isEqualToString:@"NotificationLocalEvent"])
            {
                [NotificationClass onLocalNotification:dic];
            }
            else if([type isEqualToString:@"NotificationPushEvent"])
            {
                [NotificationClass onPushNotification:dic];
            }
        }
    }
}

+(void)onPreLocalHandler: (NSNotification*) note{
    if (note) {
        [NotificationClass onLocalHandler:[[note userInfo] objectForKey:@"notification"]];
    }
}

+(void)onPrePushHandler: (NSNotification*) note{
    if (note) {
        [NotificationClass onPushHandler:[note userInfo]];
    }
}

+(void)onLocalHandler: (UILocalNotification*) note{
    if (note) {
        if(canDispatch)
        {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:[note alertAction] forKey:@"title"];
            [dic setObject:[note alertBody] forKey:@"body"];
            [dic setObject:[note soundName] ?: @"" forKey:@"sound"];
            [dic setObject:[NSString stringWithFormat:@"%d", [note applicationIconBadgeNumber] ?: 0] forKey:@"number"];
            [dic setObject:[[note userInfo] objectForKey:@"nid"] ?: @"0" forKey:@"id"];
            [NotificationClass onLocalNotification:dic];
        }
        else
        {
            [NotificationClass safe:[[[note userInfo] objectForKey:@"nid"] intValue] title:[note alertAction] body:[note alertBody] sound:[note soundName] ?: @"" number:[note applicationIconBadgeNumber] ?: 0 inRepo:@"NotificationLocalEvent"];
        }
    }
}

+(void)onPushHandler: (NSDictionary*) note{
    if(note){
        NSDictionary *aps = [note valueForKey:@"aps"];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        if([[aps valueForKey:@"alert"] isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *alert = [aps valueForKey:@"alert"];
            [dic setObject:[alert valueForKey:@"action-loc-key"] ?: [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] forKey:@"title"];
            [dic setObject:[alert valueForKey:@"body"] ?: @"" forKey:@"body"];
        }
        else{
            [dic setObject:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] forKey:@"title"];
            [dic setObject:[aps valueForKey:@"alert"] ?: @"" forKey:@"body"];
        }
        [dic setObject:[aps valueForKey:@"sound"] ?: @"" forKey:@"sound"];
        [dic setObject:[aps valueForKey:@"badge"] ?: @"0" forKey:@"number"];
        [dic setObject:[aps valueForKey:@"id"] ?: @"0" forKey:@"id"];

        if(canDispatch)
        {
            [NotificationClass onPushNotification:dic];
        }
        else
        {
            [NotificationClass safe:[[dic objectForKey:@"id"] intValue] title:[dic objectForKey:@"title"] body:[dic objectForKey:@"body"] sound:[dic objectForKey:@"sound"] number:[[dic objectForKey:@"number"] intValue] inRepo:@"NotificationPushEvent"];
        }
        [NotificationClass safe:[[dic objectForKey:@"id"] intValue] title:[dic objectForKey:@"title"] body:[dic objectForKey:@"body"] sound:[dic objectForKey:@"sound"] number:[[dic objectForKey:@"number"] intValue] inRepo:@"NotificationPush"];
    }
}

+(void)onLocalNotification: (NSMutableDictionary*) note{
    //call the C API
    int nid = [[note objectForKey:@"id"] intValue];
    const char *title = [[note objectForKey:@"title"] UTF8String];
    const char *text = [[note objectForKey:@"body"] UTF8String];
    int number = [[note objectForKey:@"number"] intValue];
    const char *sound = [[note objectForKey:@"sound"] UTF8String];
    gnotification_onLocalNotification(nid, title, text, number, sound);
}

+(void)onPushNotification: (NSMutableDictionary*) note{
    //call the C API
    int nid = [[note objectForKey:@"id"] intValue];
    const char *title = [[note objectForKey:@"title"] UTF8String];
    const char *text = [[note objectForKey:@"body"] UTF8String];
    int number = [[note objectForKey:@"number"] intValue];
    const char *sound = [[note objectForKey:@"sound"] UTF8String];
    gnotification_onPushNotification(nid, title, text, number, sound);
}

+(void)onPushRegistration: (NSNotification*) n{
    NSString *token = [[n userInfo] objectForKey:@"token"];
    token = [token stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    gnotification_onPushRegistration([token UTF8String]);
}

+(void)onPushError: (NSNotification*) n{
    NSError *error = [[n userInfo] objectForKey:@"error"];
    gnotification_onPushRegistrationError([[error localizedDescription] UTF8String]);
}

+(void)cancel:(int) nid{
    [NotificationClass cleanup: nid];
    [NotificationClass internalCancel:nid];
}

+(void)internalCancel:(int) nid{
    NSString *strId = [NSString stringWithFormat:@"%d", nid];
    NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for(UILocalNotification *note in notifications){
        NSString *notId = [note.userInfo objectForKey:@"nid"];
        if([strId isEqualToString:notId])
        {
            [[UIApplication sharedApplication] cancelLocalNotification:note];
        }
    }
    [NotificationClass del:nid inRepo:@"NotificationLocal"];
}

+(void)cancelAll{
    for(NSString *key in notifics){
        GNotification *note = [notifics objectForKey:key];
        [note release];
        note = nil;
    }
    [notifics removeAllObjects];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    NSMutableDictionary *local = [NotificationClass getAll:@"NotificationLocal"];
    if(local)
    {
        for(NSString *key in local) {
            NSMutableDictionary *dic = [local objectForKey:key];
            if([NotificationClass checkNotification:[dic objectForKey:@"id"]])
            {
                [local removeObjectForKey:[dic objectForKey:@"id"]];
            }
        }
    
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:local forKey:@"NotificationLocal"];
        [defaults synchronize];
    }
}

+(NSMutableDictionary*)getScheduledNotifications{
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    
    NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for(UILocalNotification *note in notifications){
        
        NSMutableDictionary *d = [NSMutableDictionary dictionary];
        int nid = [[note.userInfo objectForKey:@"nid"] intValue];
        [d setObject:[NSNumber numberWithInt:nid] forKey:@"id"];
        [d setObject:note.alertAction forKey:@"title"];
        [d setObject:note.alertBody forKey:@"body"];
        [d setObject:note.soundName forKey:@"sound"];
        NSNumber *number = [NSNumber numberWithInt:note.applicationIconBadgeNumber];
        [d setObject:number forKey:@"number"];
        
        [ret setObject:d forKey:[NSString stringWithFormat:@"%d", nid]];
    }
    return ret;
}

+(NSMutableDictionary*)getLocalNotifications{
    NSMutableDictionary *local = [NotificationClass getAll:@"NotificationLocal"];
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    if(local)
    {
        for(NSString *key in local) {
            NSMutableDictionary *dic = [local objectForKey:key];
            if(![NotificationClass checkNotification:[dic objectForKey:@"id"]])
            {
                [ret setObject:dic forKey:[dic objectForKey:@"id"]];
            }
        }
    }
    return ret;
}

+(NSMutableDictionary*)getPushNotifications{
    return [NotificationClass getAll:@"NotificationPush"];
}

+(void)clearLocalNotifications{
    NSMutableDictionary *local = [NotificationClass getAll:@"NotificationLocal"];
    if(local)
    {
        for(NSString *key in local) {
            NSMutableDictionary *dic = [local objectForKey:key];
            if(![NotificationClass checkNotification:[dic objectForKey:@"id"]])
            {
                [local removeObjectForKey:[dic objectForKey:@"id"]];
            }
        }
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:local forKey:@"NotificationLocal"];
        [defaults synchronize];
    }
}

+(void)clearPushNotifications{
    [NotificationClass deleteAll:@"NotificationPush"];
}

+(NSDateComponents*)getDate:(NSMutableDictionary*) date{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setSecond:[[date objectForKey:@"sec"] intValue]];
    [comps setMinute:[[date objectForKey:@"min"] intValue]];
    [comps setHour:[[date objectForKey:@"hour"] intValue]];
    [comps setDay:[[date objectForKey:@"day"] intValue]];
    [comps setMonth:[[date objectForKey:@"month"] intValue]];
    [comps setYear:[[date objectForKey:@"year"] intValue]];
    return comps;
}

+(void)safe:(int)nid title:(NSString*)title body:(NSString*)body sound:(NSString*)sound number:(int)number inRepo:(NSString*) repo{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *arr = [[defaults objectForKey:repo] mutableCopy];
    if(arr == NULL)
    {
        arr = [NSMutableDictionary dictionary];
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:[NSString stringWithFormat:@"%d", nid] forKey:@"id"];
    [dic setObject:title forKey:@"title"];
    [dic setObject:body forKey:@"body"];
    [dic setObject:sound forKey:@"sound"];
    [dic setObject:[NSString stringWithFormat:@"%d", number] forKey:@"number"];
    [arr setObject:dic forKey:[NSString stringWithFormat:@"%d", nid]];
    [defaults setObject:arr forKey:repo];
    [defaults synchronize];
}

+(void)del:(int) nid inRepo:(NSString*) repo{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *arr = [[defaults objectForKey:repo] mutableCopy];
    if(arr)
    {
        [arr removeObjectForKey:[NSString stringWithFormat:@"%d", nid]];
        [defaults setObject:arr forKey:repo];
        [defaults synchronize];
    }
}

+(void)deleteAll:(NSString*) repo{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:repo];
    [defaults synchronize];
}

+(NSMutableDictionary*)get:(int) nid fromRepo:(NSString*) repo{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *arr = [[defaults objectForKey:repo] mutableCopy];
    return [arr objectForKey:[NSString stringWithFormat:@"%d", nid]];
}

+(NSMutableDictionary*)getAll:(NSString*) repo{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [[defaults objectForKey:repo] mutableCopy];
}

+(bool)checkNotification:(NSString*)nid{
    bool ret = false;
    NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for(UILocalNotification *note in notifications){
        NSString *notId = [note.userInfo objectForKey:@"nid"];
        if([nid isEqualToString:notId])
        {
            ret = true;
            break;
        }
    }
    return ret;
}

@end