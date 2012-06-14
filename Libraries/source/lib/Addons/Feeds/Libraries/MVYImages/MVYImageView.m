//
//  MVYImageView.m
//  ateneo-ui-poc
//
//  Created by Angel Garcia Olloqui on 15/10/10.
//  Copyright 2010 Mi Mundo iPhone. All rights reserved.
//

#import "MVYImageView.h"
#import "UIImageExtras.h"


//Operation queue for images
static NSOperationQueue *sDownloadQueue=nil;
static NSOperationQueue *sCacheQueue=nil;

@interface MVYImageOperation : NSOperation
{
	MVYImageView *imageView_;	
	NSOperationQueue *queue_;
}

@property (assign) NSOperationQueue *queue;

- (id) initWithImageView:(MVYImageView *)imageView;

@end


@interface MVYImageView(private)

- (void) setUpdating:(BOOL)updating;
- (void) setOperation:(NSOperation *)operation;
- (void) setImageWithoutEffect:(UIImage *)image;

@end


@implementation MVYImageView


@synthesize updating=updating_, appearEfect=appearEfect_, url=url_, indicator=indicator_, useCache = useCache_, error=error_, operation=operation_, useThumbnails=useThumbnails_, effectWithCache=effectWithCache_;

#pragma mark Init methods

- (void) initValues {	
	updating_=NO;
	error_=NO;
	appearEfect_=YES;
    effectWithCache_=NO;
	useCache_=YES;	
	useThumbnails_=YES;
	indicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[indicator_ setHidesWhenStopped:YES];
	[indicator_ stopAnimating];
	[indicator_ setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
	[self addSubview:indicator_];	 
	[self setBackgroundColor:[UIColor clearColor]];	
}

- (id) initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self!=nil){
		[self initValues];		
	}
	return self;
}

- (id) initWithImage:(UIImage *)image {
	self = [super initWithImage:image];
	if (self!=nil){
		[self initValues];
	}
	return self;
}

- (id) init {
	self = [super init];
	if (self!=nil){
		[self initValues];
	}
	return self;
}

- (void) awakeFromNib {
	[super awakeFromNib];
	[self initValues];
}

- (void) dealloc{
	[self cancelLoad];
	
	[operation_ release]; operation_=nil;
	[indicator_ release]; indicator_=nil;
	[url_ release]; url_=nil;

	[super dealloc];
}

- (void) setUpdating:(BOOL)updating{
	if (updating!=updating_){
//		[self willChangeValueForKey:@"updating"];
		[self performSelectorOnMainThread:@selector(willChangeValueForKey:) withObject:@"updating" waitUntilDone:YES];
		updating_=updating;
//		[self didChangeValueForKey:@"updating"];
		[self performSelectorOnMainThread:@selector(didChangeValueForKey:) withObject:@"updating" waitUntilDone:YES];
	}
		
	if (updating){
		[indicator_ performSelectorOnMainThread:@selector(startAnimating) withObject:nil waitUntilDone:NO];
	}else {
		[operation_ release]; operation_=nil;
		[indicator_ performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
	}		 
}

- (void) setError:(BOOL)error{
	if (error!=error_){
		[self performSelectorOnMainThread:@selector(willChangeValueForKey:) withObject:@"error" waitUntilDone:YES];
		error_=error;
		[self performSelectorOnMainThread:@selector(didChangeValueForKey:) withObject:@"error" waitUntilDone:YES];
	}
}

- (void) setOperation:(NSOperation *)operation{
	if (operation==operation_) return;
	
	[operation_ release]; operation_=nil;
	operation_ = (MVYImageOperation*) [operation retain];
}

- (void) fadeImage {
	alpha_ = self.alpha;
	[UIView beginAnimations:nil context:NULL];	
	[UIView setAnimationDuration: 0.15];
	[self setAlpha: 0.0]; 
	[UIView commitAnimations]; 
}

- (void) unfadeWithImage:(UIImage *)image {
	if (![[NSThread currentThread] isMainThread]){
		[self performSelectorOnMainThread:@selector(unfadeWithImage:) withObject:image waitUntilDone:NO];
		return;
	}	
	[super setImage:image];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration: 0.75];
	[self setAlpha:alpha_]; 
	[UIView commitAnimations]; 
}

- (void) setImage:(UIImage *)image{
	if (![[NSThread currentThread] isMainThread]){
		[self performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
		return;
	}
	if (appearEfect_){		
		[self fadeImage];
		[self performSelector:@selector(unfadeWithImage:) withObject:image afterDelay:0.15 
					  inModes:[NSArray arrayWithObjects:NSRunLoopCommonModes, NSDefaultRunLoopMode, nil]];
	}
	else {
		[super setImage:image];		
	}
}

- (void) setImageWithoutEffect:(UIImage *)image{
	if (![[NSThread currentThread] isMainThread]){
		[self performSelectorOnMainThread:@selector(setImageWithoutEffect:) withObject:image waitUntilDone:NO];
		return;
	}
	[super setImage:image];
}

#pragma mark Loading Methods

- (void)loadImageFromURL:(NSURL*)url loadingImage:(UIImage *)loadingImage {

	//Si habia otra conexion paramos la anterior
	if (self.updating){
		[self cancelLoad];
	}
	
	if ((url!=nil) && (![url_ isEqual:url])){		
		self.updating=YES;
		[url_ release];
		url_ = [url retain];
		
		//Quitamos el efecto de aparicion para poner la imagen de fondo
		[self setImageWithoutEffect:loadingImage];
		
		//Lanzamos la operation en la cache
		[operation_ release]; 
		operation_ = [[MVYImageOperation alloc] initWithImageView:self];
		operation_.queue=[MVYImageView cacheQueue];
		[[MVYImageView cacheQueue] addOperation:operation_];
		
		indicator_.frame = CGRectMake(self.frame.size.width/2-indicator_.frame.size.width/2, self.frame.size.height/2-indicator_.frame.size.height/2, indicator_.frame.size.width, indicator_.frame.size.height);
	}
}


- (void) cancelLoad{
	[operation_ cancel];
    [url_ release]; url_=nil;
	[operation_ release]; operation_=nil;
	[self setUpdating:NO];
}

+ (NSOperationQueue *) downloadQueue{	
	if (sDownloadQueue==nil){
		sDownloadQueue = [[NSOperationQueue alloc] init];
		[sDownloadQueue setMaxConcurrentOperationCount:10];
	}
	return sDownloadQueue;
}

+ (NSOperationQueue *) cacheQueue{
	if (sCacheQueue==nil){
		sCacheQueue = [[NSOperationQueue alloc] init];
		[sCacheQueue setMaxConcurrentOperationCount:1];
	}
	return sCacheQueue;
}

@end



#pragma mark NSOperation class


@implementation MVYImageOperation

@synthesize queue=queue_;


- (id) initWithImageView:(MVYImageView *)imageView{
	if ((self=[super init])){
		imageView_ = [imageView retain];	//Retenemos la imagen hasta que finalice la operacion	
	}
	return self;
}

#pragma mark Cache Methods
- (NSString *) getImagePath{
	return [NSTemporaryDirectory() stringByAppendingString:[NSString stringWithFormat:@"%U",[[imageView_.url absoluteString] hash]]];
}

- (NSString *) getImagePathOptimized{
	return [[self getImagePath] stringByAppendingFormat:@"-%dx%d.png", (int) imageView_.frame.size.width, (int) imageView_.frame.size.height];
}

- (BOOL) imageHasCache {	
	if ([[NSFileManager defaultManager] fileExistsAtPath:[self getImagePath]]){
		return YES;
	}
	if ([[NSFileManager defaultManager] fileExistsAtPath:[self getImagePathOptimized]]){
		return YES;
	}	
	return NO;
}

- (UIImage *) newImageFromCache{
	
	NSString *imagePath = [self getImagePath];
	NSString *imagePathOptimized = [self getImagePathOptimized];
	
	//Si existe imagen optimizada la devolvemos
	if (([[NSFileManager defaultManager] fileExistsAtPath:imagePathOptimized]) && (imageView_.useThumbnails)){
		return [[UIImage alloc] initWithContentsOfFile:imagePathOptimized];	
	}
	
	//Sin imagen optimizada, comprobamos que haya imagen original
	if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]){
		return nil;
	}
	
	//Sacamos la imagen original y la devolvemos si no se permiten miniautras o la imagen original es pequeña
	UIImage *originalImage = [[UIImage alloc] initWithContentsOfFile:imagePath];
	if ((imageView_.useThumbnails==NO) || (imageView_.bounds.size.width>originalImage.size.width)|| (imageView_.bounds.size.height>originalImage.size.height)){
		return originalImage;
	}
	
	//Optimizamos la imagen al tamanio de la view para posteriores usos y mejorar la gestion de memoria
	NSAutoreleasePool *pool= [[NSAutoreleasePool alloc] init];	
	
	UIImage *optimizedImage=[originalImage resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:imageView_.bounds.size interpolationQuality:kCGInterpolationHigh];		
	NSData *optimizedImageData = UIImagePNGRepresentation(optimizedImage);
	if (optimizedImageData==nil){
		[pool release];
		return originalImage;	
	}
	[originalImage release]; originalImage=nil;	
	//Guardamos la nueva imagen en cache
	[optimizedImageData writeToFile:imagePathOptimized atomically:YES];
	optimizedImage = [[UIImage alloc] initWithData:optimizedImageData];
	[pool release];
	
	return optimizedImage;
}

- (void) setCachedImageData:(NSData *)data{	
	[data writeToFile:[self getImagePath] atomically:YES];
}

- (void) configureImageWithData:(NSData *)data {
	
	//Comprobamos que haya datos
	if (([data length]<=0) || (self.isCancelled)){
		//Notificamos y configuramos la imageview
		[imageView_ setError:!self.isCancelled];
		[imageView_ setUpdating:NO];
		[imageView_ release]; imageView_=nil;			
	}
	else {				
		//Guardamos los datos en la cache si es necesario
		if (imageView_.useCache){
			[self setCachedImageData:data];
			
			[imageView_ setUpdating:NO];
			
			//Creamos un nuevo operation para que lea la optimizada de cache
			MVYImageOperation *operation = [[MVYImageOperation alloc] initWithImageView:imageView_];
			operation.queue=[MVYImageView cacheQueue];
			[[MVYImageView cacheQueue] addOperation:operation];
			[imageView_ setOperation:operation];
			[operation release];		
		}  
		else {
			UIImage *image = [[UIImage alloc] initWithData:data];
			
			//Notificamos y configuramos la imageview
			[imageView_ setError:NO];
			[imageView_ setUpdating:NO];
			[imageView_ setImage:image];	
			[imageView_ release]; imageView_=nil;	
			[image release];													
		}
	}	
}

#pragma mark Metodos de control de operation

- (void)main {
	if (!self.isCancelled){		
		
		//Obtenemos la imagen de la cache
		UIImage *image = nil;
		if ((imageView_.useCache) && (queue_==[MVYImageView cacheQueue])){
			image=[self newImageFromCache];
		}
		
		//Si hay imagen valida la cargamos
		if (image!=nil){				
			//Notificamos y configuramos la imageview
			[imageView_ setError:NO];
			[imageView_ setUpdating:NO];
            if (imageView_.effectWithCache)
                [imageView_ setImage:image];			
            else
                [imageView_ setImageWithoutEffect:image];			
			[imageView_ release]; imageView_=nil;	
			[image release];
		}
		//En otro caso descargamos la imagen si no se ha hecho antes
		else if (imageView_.updating){				
			
			//Comprobamos que estemos en la cola correcta para la descarga
			if (queue_==[MVYImageView downloadQueue]){
				NSURLRequest *request = [NSURLRequest requestWithURL:imageView_.url];
				NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
				[self configureImageWithData:data];		
			}
			else {
				MVYImageOperation *operation = [[MVYImageOperation alloc] initWithImageView:imageView_];
				operation.queue=[MVYImageView downloadQueue];
				[[MVYImageView downloadQueue] addOperation:operation];			
				[imageView_ setOperation:operation];
				[operation release];							
			}
		}
		//En otro caso se ha producido un error en la descarga
		else {
			[imageView_ setError:YES];
			[imageView_ setUpdating:NO];				
		}
	}
}

- (BOOL)isConcurrent{
	return NO;	
}




@end



