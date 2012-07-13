
// Logos by Dustin Howett
// See http://iphonedevwiki.net/index.php/Logos
/*
#error iOSOpenDev post-project creation from template requirements (remove these lines after completed) -- \
	Link to libsubstrate.dylib: \
	(1) go to TARGETS > Build Phases > Link Binary With Libraries and add /opt/iOSOpenDev/lib/libsubstrate.dylib \
	(2) remove these lines from *.xm files (not *.mm files as they're automatically generated from *.xm files)

 */

#include <MobileTimer/Alarm.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>




%hook SBSystemLocalNotificationAlert


+ (void)playAlertSound:(BOOL)sound soundName:(NSString *)name inBundle:(id)bundle isRingtone:(BOOL)ringtone sandboxPath:(id)path
{
    
    
    %log;
    
    NSString *player = @"Library/PreferenceBundles/MyAlarmSettings.bundle/export.caf";
    
    %orig(TRUE,player,NULL,TRUE,NULL);
  
    
}

%end