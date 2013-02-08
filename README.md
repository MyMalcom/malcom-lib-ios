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
   * CoreLocation.framework (Optional if app works whith versions minor than 5.0)
   * AudioToolbox.framework
   * MessageUI.framework
   * CoreGraphics.framework
   * StoreKit.framework
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

We can use these modules:

* [Configuration](https://github.com/MyMalcom/malcom-lib-ios/wiki/Configuration)
* [Notifications](https://github.com/MyMalcom/malcom-lib-ios/wiki/Notifications)
* [Stats](https://github.com/MyMalcom/malcom-lib-ios/wiki/Stats)	
* [Ads](https://github.com/MyMalcom/malcom-lib-ios/wiki/Ads)	
* [Campaings](https://github.com/MyMalcom/malcom-lib-ios/wiki/Campaing)
