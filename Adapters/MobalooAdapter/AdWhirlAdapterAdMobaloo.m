//
//  AdWhirlAdapterAdMobaloo.m
//  GasAll
//
//  Created by Alfonso Miranda Castro on 19/01/12.
//  Copyright (c) 2012 Mobivery. All rights reserved.
//

#import "AdWhirlAdapterAdMobaloo.h"
//#import "AdWhirlAdNetworkConfig.h"
#import "AdWhirlView.h"
//#import "AdWhirlLog.h"
//#import "AdWhirlAdNetworkAdapter+Helpers.h"
//#import "AdWhirlAdNetworkRegistry.h"
#import "GasAllAppDelegate.h"
#import "MalcomLib.h"

@interface AdWhirlAdapterAdMobaloo(Private)

- (void)getAd;

@end

@implementation AdWhirlAdapterAdMobaloo

#pragma mark -
#pragma mark Metodos del singleton

static AdWhirlAdapterAdMobaloo *sharedAdMobalooInstance = nil;

- (id) init
{
	self = [super init];
	if (self != nil) {
		
	}
	return self;
}

+ (AdWhirlAdapterAdMobaloo *)sharedInstance {
    @synchronized(self) {
        if (sharedAdMobalooInstance == nil) {
            sharedAdMobalooInstance = [[self alloc] init];
        }
    }
    return sharedAdMobalooInstance;
}
+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedAdMobalooInstance == nil) {
            sharedAdMobalooInstance = [super allocWithZone:zone];
            return sharedAdMobalooInstance;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

- (id)initWithMobaloo:(AdWhirlView *)adWhirl {
    
    //viewController_ = viewController;
    adWhirlView_ = adWhirl;
    [self getAd];
    
    return self;
    
}

- (void)showMobalooIntersitial:(UIViewController *) viewController {
    
    if (!didShowInterstitial_) {
    
        GasAllAppDelegate *appDelegate = (GasAllAppDelegate*) [[UIApplication sharedApplication] delegate];
    
        // Activar o desactivar el GPS dependiendo de si la app utiliza CoreLocation
        //GPS = 0 Desactivado
        //GPS = 1 Activado
        appDelegate.adViewContainer.GPS = 1;
    
        [appDelegate.adViewContainer requestIntersitialAdMobalooWithDelegate:self oldView:viewController.view];
    
    }
    
}

- (void)getAd {
    
    adMobalooAd = [[AdMobalooView alloc]init];
    
    [adMobalooAd requestAdMobalooWithDelegate:self];
    //adMobalooAd.delegate = self;
    
    //[adMobalooAd release];
    
}

- (void)stopBeingDelegate {
    	
}

- (void)dealloc {
    
    [super dealloc];

}

#pragma mark Mobaloo

- (void)AdWhirlCustomEventMobaloo:(AdWhirlView *)adWhirlView
{      
    //****Uso de Geolocalizacion
    // En el caso de querer usar geolocalizacion a través de CoreLocation se debe pasar un objeto que se utilice en la aplicación
    // como en este ejemplo se le pasa el objeto  lm. 
    
    //CLLocationManager *lm = [[CLLocationManager alloc]init];
    //adMobalooAd.locationManager = lm;
    //********    
	[adMobalooAd requestAdMobalooWithDelegate:self];
    
}

- (NSString *)publisherIdForAd
{
	//return @"infovuelos/principal";
    //return [[MCMConfigManager sharedInstance] settingForKey:@"idMobaloo"];
    return [MalcomLib getAdvanceConfigurationForKey:@"idMobaloo" valueDefault:@"igasall/principal"];
    //return @"ipublisher/multimedia";
    
}

// Gestionado por AdWhirl, ponemos el timer de Mobaloo a 0 para que sea AdWhirl quien maneje el refresco

- (NSInteger)timeToRefreshAd
{
	return 0;
}

-(void)invalidateRefresh{
    
    [adMobalooAd stopRefresh];
}

- (void)didReceiveAd:(AdMobalooView *)adView {
	NSLog(@"Mobaloo Banner: Did receive ad");
	
	//Situamos el banner donde queramos en pantalla por la variables definidas en AdMobalooBannerDelegateProtocol.h
    
	adView.frame = CGRectMake(AD_X_POSITION, AD_Y_POSITION, AD_SIZE_WIDTH, AD_SIZE_HEIGHT);
    
	[adMobalooAd animationAdMobaloo:adView];
    
    //[viewController_.view addSubview:adView];
    
    //[adWhirlView_ replaceBannerViewWith:adView];
    [[adWhirlView_ superview] addSubview:adView];
    
}

// Recibido cuando se ha producido algún error en la recepción del Ad

- (void)didFailToReceiveAd:(AdMobalooView *)adView {
    
	NSLog(@"Mobaloo Banner: Did fail to receive ad");
    [adWhirlView_ rollOver];
    
    
}

//Controlamos el refresco de AdWhirl
-(void) refreshAdwhirl{
    
    if ([adWhirlView_ isIgnoringAutoRefreshTimer]) {
        NSLog(@"Activar refresco AdWhirl");
        [adWhirlView_ doNotIgnoreAutoRefreshTimer];
        
    }else{
        
        NSLog(@"Parar refresco AdWhirl");
        [adWhirlView_ ignoreAutoRefreshTimer];
    }
}

- (void) didReceiveIntersitialAd {
	
	didShowInterstitial_ = YES;
	
}

- (void) didFailToReceiveIntersitialAd {
	
    NSLog(@"Error recibiendo la publicidad de mobaloo intersitial");
    [adWhirlView_ rollOver];
	
}

/**** Define el tiempo de vuelta para el Ad: Sólo en caso de Usar INTERSITIAL ****/
- (NSInteger)timeToBackAd {
	
	return 10;
	
}

@end
