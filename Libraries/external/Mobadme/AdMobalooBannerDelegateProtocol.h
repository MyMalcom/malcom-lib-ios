//
//  AdMobalooDelegateProtocol.h
//  AdMobalooLibrary
//
//  Copyright 2010 Mobaloo. All rights reserved.
//

/*****
   Define el protocolo que cumplirán todas las Views que requieran de un Ad
 
 ******/

#import <UIKit/UIKit.h>
@class AdMobalooView;


/**** Constantes para definir el tamaño de AdBanner ****/
#define AD_SIZE_WIDTH     320
#define AD_SIZE_HEIGHT    50
#define AD_X_POSITION 0
#define AD_Y_POSITION 410
/********/
@protocol AdMobalooBannerDelegate<NSObject>


@required
#pragma mark required methods

/**** Define el método que proporciona el ID (proporcionado por AdMobaloo) necesario para activar los Ads. ****/
- (NSString *)publisherIdForAd;

/**** Define el tiempo de refresco para recargar un nuevo Ad ****/
- (NSInteger)timeToRefreshAd;

/**** Método para la integración con AdWhirl ****/
-(void)refreshAdwhirl;

@optional
#pragma mark optional notification methods

// Enviado cuando se recibe satisfactoriamente un Ad. Es un buen momento para añadir la vista 
// a la jerarquía de vistas del proyecto
- (void)didReceiveAd:(AdMobalooView *)adView;


// Enviado cuando se ha producido un error al recibir un nuevo Ad
- (void)didFailToReceiveAd:(AdMobalooView *)adView;




@end

