//
//  MVYImageView.h
//  ateneo-ui-poc
//
//  Created by Angel Garcia Olloqui on 15/10/10.
//  Copyright 2010 Mi Mundo iPhone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//Operations
@class MVYImageOperation;

@interface MVYImageView : UIImageView {

	BOOL useCache_;
	BOOL useThumbnails_;
	BOOL appearEfect_;
    BOOL effectWithCache_;
	BOOL updating_;
	BOOL error_;
	NSURL *url_;
	UIActivityIndicatorView *indicator_;
	CGFloat alpha_;
	MVYImageOperation *operation_;
}

//Acceso a la cola de prioridades que usan las imagenes para su descarga
+ (NSOperationQueue *) downloadQueue;
//Acceso a la cola de prioridades que usan las imagenes para su optimizado y lectura de cache
+ (NSOperationQueue *) cacheQueue;

//-----------------------
//Properties modificables
//-----------------------
//Establece si la imagen debe cargar con un efecto de fade o no. Default YES
@property BOOL appearEfect;
//Establece si la imagen debe guardar y cargar de cache. Default YES
@property BOOL useCache;
//Establece si la imagen debe guardar una miniatura. Usar miniaturas reduce consumo de memoria y CPU en posteriores usos, pero 
//amplia CPU en la descarga. Default YES. Recomendado NO en casos de imagenes muy cambiantes en cada apertura.
@property BOOL useThumbnails;
//Establece si la imagen debe aplicar el efecto tambien cuando carga de cache. Default NO
@property BOOL effectWithCache;

//-----------------------
//Properties de solo lectura
//-----------------------
//Informa de si la imagen esta en proceso de descarga o no
@property (readonly) BOOL updating;
//Informa de si se ha producido un error en la descarga
@property (readonly) BOOL error;
//Contiene la URL destino
@property (readonly) NSURL *url;
//Contiene un acceso al activity mostrado dentro de la imagen. Hacer hidden si no se quiere
@property (readonly) UIActivityIndicatorView *indicator;
//Contiene la referencia de la NSOperation relacionada con esta imagen
@property (readonly) MVYImageOperation *operation;

//-----------------------
//Metodos 
//-----------------------
//Carga la imagen desde una URL remota con una imagen de loading temporal
- (void)loadImageFromURL:(NSURL*)url loadingImage:(UIImage *)loadingImage;
//Cancela la carga de la imagen remota (solo si esta descargando)
- (void) cancelLoad;


@end
