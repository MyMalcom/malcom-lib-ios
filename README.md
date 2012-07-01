Malcom Lib iOS
==============

Integration
------------

* Clone this repository o download the zip:

        git://github.com/MyMalcom/malcom-lib-ios.git
    
* Add one of versions avaibles of library:
    * Static library: Add the folder of static library. If you wan't ad module, don't add 'ads' folder. Add TouchJSON library which is in 'External' folder.
    * Source library: Add source in project. In case that you wan't use any module (Configuration, Ad, Notifications or Stats) you can delete the folder.

* Add this frameworks to project:

   * MediaPlayer.framework
   * AVFoundation.framework
   * CFNetwork.framework
   * SystemConfiguration.framework
   * MobileCoreServices.framework
   * QuartzCore.framework
   * CoreTelephony.framework
   * CoreLocation.framework (Optional)
   * AudioToolbox.framework
   * MessageUI.framework
   * libz.1.2.5.dylib
   * iAd.framework (only for ad module)

* In target, Link Binary With Libraries, push CoreLocation.framework like 'Optional'.

* Add in "Other C Flags", in production:
        
        -DDISTRIBUTION=1

* Add in "Other link Flags"
       
        -all_load -ObjC 

Sample App
----------

In Samples folder there are two projects, each one of them with a integration type different.

Using library
------------------

Init:

First, import MCMLib.h

		#import "MalcomLib.h"

and add this method:

		[MalcomLib initWithUUID:@"UUID" 
                   andSecretKey:@"SECRETKEY" 
                       withAdId:@"ADID"];
                       
With the params of your app in Malcom

If you want that show log for console, use it:

	[MalcomLib showLog:YES];

Configuration:

Call this method

	[MalcomLib loadConfiguration:viewController withDelegate:delegate withLabel:NO];
	
Where first param is view where configuration is charged, secund is delegate and third is appear or not label in splash.

Notifications:

You must have defined -DDISTRIBUTION=1 in production enviorement.
In didFinishLaunchingWithOptions, class AppDelegate add this code:

	#if DISTRIBUTION
	    
	    [MalcomLib startNotifications:application withOptions:launchOptions isDevelopmentMode:NO];
	    
	#else
	    
	    [MalcomLib startNotifications:application withOptions:launchOptions isDevelopmentMode:YES];
	    
	#endif
	
And, in AppDelegate, add this methods:

	- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
	    
	    [MalcomLib didRegisterForRemoteNotificationsWithDeviceToken:devToken];
	    
	}
	
	- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
	    
	    [MalcomLib didFailToRegisterForRemoteNotificationsWithError:err];
	    
	}
	
	- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	    
	    [MalcomLib didReceiveRemoteNotification:userInfo active:NO];
	    
	}

Stats:

First, you must init in didFinishLaunchingWithOption, applicationWillEnterForeground y applicationDidBecomeActive methods of class AppDelegate whith this method:

	[MalcomLib initAndStartBeacon:YES useOnlyWiFi:YES];
	
First param is if app use geolocation and second is for send stats only with wifi connection.

This method:

	[MalcomLib endBeacon];
	
is used when app exit or background in applicationDidEnterBackground and applicationWillTerminate methods.

For get stats of actions, views, etc, you must use:

For start:

	[MalcomLib startBeaconWithName:@"ViewController"];
	

For end and send:
	
	[MalcomLib endBeaconWithName:@"ViewController"];
	

Ads:

For add :

	[MalcomAd presentAd:viewController atPosition:point];
	
where viewController is view where ads is showed, and point is position.

If you want add the size of ads, use this method:

	[MalcomAd presentAd:viewController atPosition:point withSize:size];
