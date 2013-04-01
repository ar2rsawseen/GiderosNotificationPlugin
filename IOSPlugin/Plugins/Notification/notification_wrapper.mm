#include "notification_wrapper.h"
#import "NotificationClass.h"

class GNotification
{
public:
	GNotification()
	{
		gid_ = g_NextId();
        
        [NotificationClass initialize];
		
		//subscribe to event
		gevent_AddCallback(onEnterFrame, this);
	}

	~GNotification()
	{
		[NotificationClass deinitialize];
		gevent_RemoveEventsWithGid(gid_);
	}
	
	void init(int id)
	{
		[NotificationClass init:id];
	}
	
	void cleanup(int id){
		[NotificationClass cleanup:id];
	}
	
	void set_title(int id, const char *title){
		[NotificationClass setTitle:[NSString stringWithUTF8String:title] withID: id];
	}
	
	const char* get_title(int id){
        return [[NotificationClass getTitle:id] UTF8String];
	}
	
	void set_body(int id, const char *body){
		[NotificationClass setBody:[NSString stringWithUTF8String:body] withID: id];
	}
	
	const char* get_body(int id){
		return [[NotificationClass getBody:id] UTF8String];
	}
	
	void set_number(int id, int number){
		[NotificationClass setNumber:number withID: id];
	}
	
	int get_number(int id){
		return [NotificationClass getNumber:id];
	}
	
	void set_sound(int id, const char *sound){
		[NotificationClass setSound:[NSString stringWithUTF8String:sound] withID: id];
	}
	
	const char* get_sound(int id){
		return [[NotificationClass getSound:id] UTF8String];
	}
	
	void dispatch_now(int id){
		[NotificationClass dispatchNow:id];
	}
	
	void cancel(int id){
		[NotificationClass cancel:id];
	}
	
	void cancel_all(){
		[NotificationClass cancelAll];
	}
	
	void dispatch_after(int nid, gnotification_Parameter *params1, gnotification_Parameter *params2){
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
		while(params1->key){
            [dic setObject:[NSString stringWithUTF8String:params1->value] forKey:[NSString stringWithUTF8String:params1->key]];
            ++params1;
        }
        
        if(params2){
            NSMutableDictionary *dic2 = [NSMutableDictionary dictionary];
            while(params2->key){
                [dic2 setObject:[NSString stringWithUTF8String:params2->value] forKey:[NSString stringWithUTF8String:params2->key]];
                ++params2;
            }
            [NotificationClass dispatchAfter:nid onDate:dic repeating:dic2];
        }
        else
        {
            [NotificationClass dispatchAfter:nid onDate:dic];
        }
	}
	
	void dispatch_on(int nid, gnotification_Parameter *params1, gnotification_Parameter *params2){
		NSMutableDictionary *dic = [NSMutableDictionary dictionary];
		while(params1->key){
            [dic setObject:[NSString stringWithUTF8String:params1->value] forKey:[NSString stringWithUTF8String:params1->key]];
            ++params1;
        }
        
        if(params2){
            NSMutableDictionary *dic2 = [NSMutableDictionary dictionary];
            while(params2->key){
                [dic2 setObject:[NSString stringWithUTF8String:params2->value] forKey:[NSString stringWithUTF8String:params2->key]];
                ++params2;
            }
            [NotificationClass dispatchOn:nid onDate:dic repeating:dic2];
        }
        else
        {
            [NotificationClass dispatchOn:nid onDate:dic];
        }
	}
	
	void clear_local(){
		[NotificationClass clearLocalNotifications];
	}
	
	void clear_push(){
		[NotificationClass clearPushNotifications];
	}
	
	gnotification_Group* get_scheduled(){
        NSMutableDictionary *dic = [NotificationClass getScheduledNotifications];
		return this->dic2group(dic);
	}
	
	gnotification_Group* get_local(){
        NSMutableDictionary *dic = [NotificationClass getLocalNotifications];
		return this->dic2group(dic);
	}
	
	gnotification_Group* get_push(){
        NSMutableDictionary *dic = [NotificationClass getPushNotifications];
		return this->dic2group(dic);
	}
	
	void register_push(const char *project){
		[NotificationClass registerForPushNotifications];
	}
	
	void unregister_push(){
		[NotificationClass unRegisterForPushNotifications];
	}
	
	void ready_for_events(){
		[NotificationClass readyForEvents];
	}
	
	void onLocalNotification(int id, const char *title, const char *text, int number, const char *sound)
	{
		gnotification_LocalEvent *event = (gnotification_LocalEvent*)gevent_CreateEventStruct3(
			sizeof(gnotification_LocalEvent),
			offsetof(gnotification_LocalEvent, title), title,
			offsetof(gnotification_LocalEvent, text), text,
			offsetof(gnotification_LocalEvent, sound), sound);
			
		event->id = id;
		event->number = number;

		gevent_EnqueueEvent(gid_, callback_s, NOTIFICATION_LOCAL_EVENT, event, 1, this);
	}
	
	void onPushNotification(int id, const char *title, const char *text, int number, const char *sound)
	{
		gnotification_PushEvent *event = (gnotification_PushEvent*)gevent_CreateEventStruct3(
			sizeof(gnotification_PushEvent),
			offsetof(gnotification_PushEvent, title), title,
			offsetof(gnotification_PushEvent, text), text,
			offsetof(gnotification_PushEvent, sound), sound);
			
		event->id = id;
		event->number = number;

		gevent_EnqueueEvent(gid_, callback_s, NOTIFICATION_PUSH_EVENT, event, 1, this);
	}
	
	void onPushRegistration(const char *regId)
	{
		gnotification_RegisterPushEvent *event = (gnotification_RegisterPushEvent*)gevent_CreateEventStruct1(
			sizeof(gnotification_RegisterPushEvent),
			offsetof(gnotification_RegisterPushEvent, regId), regId);

		gevent_EnqueueEvent(gid_, callback_s, NOTIFICATION_PUSH_REGISTER_EVENT, event, 1, this);
	}
	
	void onPushRegistrationError(const char *errorId)
	{
		gnotification_RegisterPushErrorEvent *event = (gnotification_RegisterPushErrorEvent*)gevent_CreateEventStruct1(
			sizeof(gnotification_RegisterPushErrorEvent),
			offsetof(gnotification_RegisterPushErrorEvent, errorId), errorId);

		gevent_EnqueueEvent(gid_, callback_s, NOTIFICATION_PUSH_REGISTER_ERROR_EVENT, event, 1, this);
	}
	
	
	//helping functions
	
	struct gnotification_Group* dic2group(NSMutableDictionary *dic)
	{
		group.clear();

		for (NSString *key in dic) {
            NSMutableDictionary *n = [dic objectForKey:key];
			gnotification_Group gparam = {[key intValue], [[n objectForKey:@"title"] UTF8String], [[n objectForKey:@"body"] UTF8String], [[n objectForKey:@"number"] intValue], [[n objectForKey:@"sound"] UTF8String]};
			
			group.push_back(gparam);
		}
		
		gnotification_Group param = {0, NULL, NULL, 0, NULL};
		group.push_back(param);
		
		return &group[0];
	}
	
	g_id addCallback(gevent_Callback callback, void *udata)
	{
		return callbackList_.addCallback(callback, udata);
	}
	void removeCallback(gevent_Callback callback, void *udata)
	{
		callbackList_.removeCallback(callback, udata);
	}
	void removeCallbackWithGid(g_id gid)
	{
		callbackList_.removeCallbackWithGid(gid);
	}

private:
	static void callback_s(int type, void *event, void *udata)
	{
		((GNotification*)udata)->callback(type, event);
	}
	
	static void onEnterFrame(int type, void *event, void *udata)
	{
		if(type == GEVENT_PRE_TICK_EVENT || type == GEVENT_POST_TICK_EVENT)
		{
			((GNotification*)udata)->ready_for_events();
			gevent_RemoveCallback(onEnterFrame, udata);
		}
	}

	void callback(int type, void *event)
	{
		callbackList_.dispatchEvent(type, event);
	}

private:
	gevent_CallbackList callbackList_;

private:
	g_id gid_;
	std::vector<gnotification_Group> group;
};

//C Wrapper

static GNotification *s_note = NULL;

extern "C" {

void gnotification_construct(){
	s_note = new GNotification;
}

void gnotification_destroy(){
	delete s_note;
	s_note = NULL;
}

void gnotification_init(int id){
	s_note->init(id);
}

void gnotification_cleanup(int id){
	if(s_note)
	{
		s_note->cleanup(id);
	}
}

void gnotification_set_title(int id, const char *title){
	s_note->set_title(id, title);
}

const char* gnotification_get_title(int id){
	return s_note->get_title(id);
}

void gnotification_set_body(int id, const char *body){
	s_note->set_body(id, body);
}

const char* gnotification_get_body(int id){
	return s_note->get_body(id);
}

void gnotification_set_number(int id, int number){
	s_note->set_number(id, number);
}

int gnotification_get_number(int id){
	return s_note->get_number(id);
}

void gnotification_set_sound(int id, const char *sound){
	s_note->set_sound(id, sound);
}

const char* gnotification_get_sound(int id){
	return s_note->get_sound(id);
}

void gnotification_dispatch_now(int id){
	s_note->dispatch_now(id);
}

void gnotification_cancel(int id){
	s_note->cancel(id);
}

void gnotification_cancel_all(){
	s_note->cancel_all();
}

void gnotification_dispatch_after(int id, gnotification_Parameter *params1, gnotification_Parameter *params2){
	s_note->dispatch_after(id, params1, params2);
}

void gnotification_dispatch_on(int id, gnotification_Parameter *params1, gnotification_Parameter *params2){
	s_note->dispatch_on(id, params1, params2);
}

void gnotification_clear_local(){
	s_note->clear_local();
}

void gnotification_clear_push(){
	s_note->clear_push();
}

gnotification_Group* gnotification_get_scheduled(){
	return s_note->get_scheduled();
}

gnotification_Group* gnotification_get_local(){
	return s_note->get_local();
}

gnotification_Group* gnotification_get_push(){
	return s_note->get_push();
}

void gnotification_register_push(const char *project){
	s_note->register_push(project);
}

void gnotification_unregister_push(){
	s_note->unregister_push();
}

g_id gnotification_addCallback(gevent_Callback callback, void *udata)
{
	return s_note->addCallback(callback, udata);
}

void gnotification_removeCallback(gevent_Callback callback, void *udata)
{
	s_note->removeCallback(callback, udata);
}

void gnotification_removeCallbackWithGid(g_id gid)
{
	s_note->removeCallbackWithGid(gid);
}

}


//events
void gnotification_onLocalNotification(int nid, const char *title, const char *text, int number, const char *sound)
{
    s_note->onLocalNotification(nid, title, text, number, sound);
}
	
void gnotification_onPushNotification(int nid, const char *title, const char *text, int number, const char *sound)
{
	s_note->onPushNotification(nid, title, text, number, sound);
}
	
void gnotification_onPushRegistration(const char* token)
{
    s_note->onPushRegistration(token);
}
	
void gnotification_onPushRegistrationError(const char* error)
{
	s_note->onPushRegistrationError(error);
}