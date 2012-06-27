//
//  AdMobalooView.h
//  AdMobalooLibrary
//
//  Copyright 2010 Mobaloo. All rights reserved.
//
//  ---------
//     
//    Representa el punto de inicio para pedir un Ad al server. 

#import <UIKit/UIKit.h>

#import "AdInfo.h"
#import "AdMobalooBannerDelegateProtocol.h"
#import <CoreLocation/CoreLocation.h>

@protocol AdMobalooDelegate;


@interface AdMobalooView : UIView<UIWebViewDelegate,NSXMLParserDelegate>{	


    /*** Represnta la información (no accesible) que conforma el Ad.***/
@private
	
    AdInfo *currentAd;
    NSMutableData *responseData;

	id<AdMobalooBannerDelegate> delegate;
	CLLocationManager *locationManager;


 
	
}

/******
 * Inicializa una petición de Ad
 * 
 * El delegado es alertado de cuando se recibe el Ad (o cuando se ha producido un error)
 * siendo una buena oportunidad para añadir la vista a la jerarquía de vistas del proyecto.
 *
 * Este método se deberá invocar desde el hilo principal de ejecución.
 ****/

- (void)requestAdMobalooWithDelegate:(id<AdMobalooBannerDelegate>)delegate;


/******
 * 
 * Método al que puede llamar el desarrollador en el momento que desee para parar el refresco de anuncios
 * 
 ****/

-(void)stopRefresh;


/******
 * 
 * Método llamado desde el ViewController cuando hemos obtenido el anuncion correctamente
 * 
 ****/

- (void)animationAdMobaloo:(AdMobalooView *)adView;


/*** Delegado que permite controlar la recepción de los Ads. A implementar por algún ViewController creado por el desarrollador ***/
@property (assign) id<AdMobalooBannerDelegate> delegate;

@property (nonatomic,retain) AdInfo *currentAd;


@property (nonatomic, retain) CLLocationManager *locationManager;




@end
