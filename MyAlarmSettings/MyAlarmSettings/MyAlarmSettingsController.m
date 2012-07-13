//
//  MyAlarmSettingsController.m
//  MyAlarmSettings
//
//  Created by TJ on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyAlarmSettingsController.h"
#import <Preferences/PSSpecifier.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>


@implementation MyAlarmSettingsController

@synthesize songLabel;
@synthesize artistLabel;
@synthesize sizeLabel;
@synthesize coverArtView;
@synthesize conversionProgress;



- (void)visitWebSite:(PSSpecifier*)specifier
{
	NSURL *assetURL = [song valueForProperty:MPMediaItemPropertyAssetURL];
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    
    NSError *assetError = nil;
    AVAssetReader *assetReader = [[AVAssetReader assetReaderWithAsset:songAsset
                                                                error:&assetError]
                                  retain];
    if (assetError) {
        NSLog (@"error: %@", assetError);
        return;
    }
    
    AVAssetReaderOutput *assetReaderOutput = [[AVAssetReaderAudioMixOutput 
                                               assetReaderAudioMixOutputWithAudioTracks:songAsset.tracks
                                               audioSettings: nil]
                                              retain];
    if (! [assetReader canAddOutput: assetReaderOutput]) {
        NSLog (@"can't add reader output... die!");
        return;
    }
    [assetReader addOutput: assetReaderOutput];
    
    
    NSString *exportPath = @"Library/PreferenceBundles/MyAlarmSettings.bundle/export.caf";
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath]) {
		[[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
	}

    NSURL *exportURL = [NSURL fileURLWithPath:exportPath];
    AVAssetWriter *assetWriter = [[AVAssetWriter assetWriterWithURL:exportURL
                                                           fileType:AVFileTypeCoreAudioFormat
                                                              error:&assetError]
                                  retain];
    if (assetError) {
        NSLog (@"error: %@", assetError);
        return;
    }
    AudioChannelLayout channelLayout;
    memset(&channelLayout, 0, sizeof(AudioChannelLayout));
    channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    NSDictionary *outputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey, 
                                    [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                                    [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
                                    [NSData dataWithBytes:&channelLayout length:sizeof(AudioChannelLayout)], AVChannelLayoutKey,
                                    [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                    [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                    [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                    [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                                    nil];
    AVAssetWriterInput *assetWriterInput = [[AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
                                                                               outputSettings:outputSettings]
                                            retain];
    if ([assetWriter canAddInput:assetWriterInput]) {
        [assetWriter addInput:assetWriterInput];
    } else {
        NSLog (@"can't add asset writer input... die!");
        return;
    }
    
    assetWriterInput.expectsMediaDataInRealTime = NO;
    
    [assetWriter startWriting];
    [assetReader startReading];
    
    AVAssetTrack *soundTrack = [songAsset.tracks objectAtIndex:0];
    CMTime startTime = CMTimeMake (0, soundTrack.naturalTimeScale);
    [assetWriter startSessionAtSourceTime: startTime];
    
    __block UInt64 convertedByteCount = 0;
    
    dispatch_queue_t mediaInputQueue = dispatch_queue_create("mediaInputQueue", NULL);
    [assetWriterInput requestMediaDataWhenReadyOnQueue:mediaInputQueue 
                                            usingBlock: ^ 
     {
         // NSLog (@"top of block");
         while (assetWriterInput.readyForMoreMediaData) {
             CMSampleBufferRef nextBuffer = [assetReaderOutput copyNextSampleBuffer];
             if (nextBuffer) {
                 // append buffer
                 [assetWriterInput appendSampleBuffer: nextBuffer];
                 //				NSLog (@"appended a buffer (%d bytes)", 
                 //					   CMSampleBufferGetTotalSampleSize (nextBuffer));
                 convertedByteCount += CMSampleBufferGetTotalSampleSize (nextBuffer);
                 // oops, no
                 // sizeLabel.text = [NSString stringWithFormat: @"%ld bytes converted", convertedByteCount];
                 
                 NSNumber *convertedByteCountNumber = [NSNumber numberWithLong:convertedByteCount];
                 [self performSelectorOnMainThread:@selector(updateSizeLabel:)
                                        withObject:convertedByteCountNumber
                                     waitUntilDone:NO];
             } else {
                 // done!
                 [assetWriterInput markAsFinished];
                 [assetWriter finishWriting];
                 [assetReader cancelReading];
                 NSDictionary *outputFileAttributes = [[NSFileManager defaultManager]
                                                       attributesOfItemAtPath:exportPath
                                                       error:nil];
                 NSLog (@"done. file size is %llu",
                        [outputFileAttributes fileSize]);
                 NSNumber *doneFileSize = [NSNumber numberWithLong:[outputFileAttributes fileSize]];
                 [self performSelectorOnMainThread:@selector(updateCompletedSizeLabel:)
                                        withObject:doneFileSize
                                     waitUntilDone:NO];
                 // release a lot of stuff
                 
                 
                 [assetReader release];
                 [assetReaderOutput release];
                 [assetWriter release];
                 [assetWriterInput release];
                 [exportPath release];
                 break;
             }
         }
         
     }];
    
    NSString *hax =  [[NSString alloc]initWithFormat:@"Alarm sound set to '%@'",[song valueForProperty:MPMediaItemPropertyTitle]];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Done!" message:hax delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
    NSLog (@"bottom of convertTapped:");
}

- (void)makeDonation:(PSSpecifier *)specifier
{
	MPMediaPickerController *pickerController =	[[MPMediaPickerController alloc]
												 initWithMediaTypes: MPMediaTypeMusic];
	pickerController.prompt = @"Choose song to  be set as alarm";
	pickerController.allowsPickingMultipleItems = NO;
	pickerController.delegate = self;
	[self presentModalViewController:pickerController animated:YES];
	[pickerController release];
}

#pragma mark MPMediaPickerControllerDelegate
- (void)mediaPicker: (MPMediaPickerController *)mediaPicker
  didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
	[self dismissModalViewControllerAnimated:YES];
	if ([mediaItemCollection count] < 1) {
		return;
	}
	[song release];
	song = [[[mediaItemCollection items] objectAtIndex:0] retain];
	songLabel.hidden = NO;
	artistLabel.hidden = NO;
	coverArtView.hidden = NO;
	songLabel.text = [song valueForProperty:MPMediaItemPropertyTitle];
	artistLabel.text = [song valueForProperty:MPMediaItemPropertyArtist];
	coverArtView.image = [[song valueForProperty:MPMediaItemPropertyArtwork]
						  imageWithSize: coverArtView.bounds.size];

}

-(void) updateSizeLabel: (NSNumber*) convertedByteCountNumber {
	UInt64 convertedByteCount = [convertedByteCountNumber longValue];
	sizeLabel.text = [NSString stringWithFormat: @"%ld bytes converted", convertedByteCount];
}

-(void) updateCompletedSizeLabel: (NSNumber*) convertedByteCountNumber {
	UInt64 convertedByteCount = [convertedByteCountNumber longValue];
	sizeLabel.text = [NSString stringWithFormat: @"done. file size is %ld", convertedByteCount];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
	[self dismissModalViewControllerAnimated:YES];
}


- (id)specifiers
{
	if (_specifiers == nil)
		_specifiers = [[self loadSpecifiersFromPlistName:@"MyAlarmSettings" target:self] retain];
	
	return _specifiers;
}

- (id)init
{
	if ((self = [super init]))
	{
	}
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

@end