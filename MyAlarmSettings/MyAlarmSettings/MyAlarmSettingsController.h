//
//  MyAlarmSettingsController.h
//  MyAlarmSettings
//
//  Created by TJ on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Preferences/Preferences.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreMedia/CoreMedia.h>

@interface MyAlarmSettingsController : PSListController < MPMediaPickerControllerDelegate>{
	MPMediaItem *song;
    
	UILabel *songLabel;
	UILabel *artistLabel;
	UILabel *sizeLabel;
	UIImageView *coverArtView;
	UIProgressView *conversionProgress;
	
}


- (id)getValueForSpecifier:(PSSpecifier*)specifier;
- (void)setValue:(id)value forSpecifier:(PSSpecifier*)specifier;
- (void)visitWebSite:(PSSpecifier*)specifier;
- (void)makeDonation:(PSSpecifier*)specifier;

@property (nonatomic, retain) IBOutlet UILabel *songLabel;
@property (nonatomic, retain) IBOutlet UILabel *artistLabel;
@property (nonatomic, retain) IBOutlet UILabel *sizeLabel;
@property (nonatomic, retain) IBOutlet UIImageView *coverArtView;
@property (nonatomic, retain) IBOutlet UIProgressView *conversionProgress;

@end