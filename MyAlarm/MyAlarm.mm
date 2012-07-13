#line 1 "/Users/tj/Documents/iOS Development/MyAlarm/MyAlarm/MyAlarm.xm"











#include <MobileTimer/Alarm.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>




#include <substrate.h>
@class SBSystemLocalNotificationAlert; 
static void (*_logos_meta_orig$_ungrouped$SBSystemLocalNotificationAlert$playAlertSound$soundName$inBundle$isRingtone$sandboxPath$)(Class, SEL, BOOL, NSString *, id, BOOL, id); static void _logos_meta_method$_ungrouped$SBSystemLocalNotificationAlert$playAlertSound$soundName$inBundle$isRingtone$sandboxPath$(Class, SEL, BOOL, NSString *, id, BOOL, id); 

#line 20 "/Users/tj/Documents/iOS Development/MyAlarm/MyAlarm/MyAlarm.xm"




static void _logos_meta_method$_ungrouped$SBSystemLocalNotificationAlert$playAlertSound$soundName$inBundle$isRingtone$sandboxPath$(Class self, SEL _cmd, BOOL sound, NSString * name, id bundle, BOOL ringtone, id path) {
    
    
    NSLog(@"+[<SBSystemLocalNotificationAlert: %p> playAlertSound:%d soundName:%@ inBundle:%@ isRingtone:%d sandboxPath:%@]", self, sound, name, bundle, ringtone, path);
    
    NSString *player = @"Library/PreferenceBundles/MyAlarmSettings.bundle/export.caf";
    
    _logos_meta_orig$_ungrouped$SBSystemLocalNotificationAlert$playAlertSound$soundName$inBundle$isRingtone$sandboxPath$(self, _cmd, TRUE,player,NULL,TRUE,NULL);
  
    
}


static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SBSystemLocalNotificationAlert = objc_getClass("SBSystemLocalNotificationAlert"); Class _logos_metaclass$_ungrouped$SBSystemLocalNotificationAlert = object_getClass(_logos_class$_ungrouped$SBSystemLocalNotificationAlert); MSHookMessageEx(_logos_metaclass$_ungrouped$SBSystemLocalNotificationAlert, @selector(playAlertSound:soundName:inBundle:isRingtone:sandboxPath:), (IMP)&_logos_meta_method$_ungrouped$SBSystemLocalNotificationAlert$playAlertSound$soundName$inBundle$isRingtone$sandboxPath$, (IMP*)&_logos_meta_orig$_ungrouped$SBSystemLocalNotificationAlert$playAlertSound$soundName$inBundle$isRingtone$sandboxPath$);}  }
#line 37 "/Users/tj/Documents/iOS Development/MyAlarm/MyAlarm/MyAlarm.xm"
