//
//  OPMLReader.m
//  rss20
//
//  Created by Angel Garcia Olloqui on 02/02/09.
//  Copyright 2009 Mi Mundo iPhone. All rights reserved.
//

#import "OPMLReader.h"


@interface OPMLReader ()

@property (nonatomic, assign) NSMutableString *currentString;
@property (nonatomic, assign) NSMutableArray *elementStack;
@property (nonatomic, assign) NSMutableArray *attributesStack;
@property (nonatomic, assign) OPML20ParserDelegate *parser;


@end


@implementation OPMLReader

@synthesize currentString, elementStack, attributesStack, parser, opml;


- (id) initWithUrl:(NSURL *)url{
	self = [super init];
	
	if (self !=nil){
		
		//Nueva pool para gestionar autorelease
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		//Inicializacion de variables
		self.currentString = [[[NSMutableString alloc] initWithCapacity:32] autorelease];
		self.elementStack = [[[NSMutableArray alloc] initWithCapacity:6] autorelease];
		self.attributesStack = [[[NSMutableArray alloc] initWithCapacity:6] autorelease];
		
		//Parseador de XML
		//[self performSelectorOnMainThread:@selector(downloadStarted) withObject:nil waitUntilDone:NO];
		NSXMLParser *XMLparser = [[NSXMLParser alloc] initWithContentsOfURL:url];
		//[self performSelectorOnMainThread:@selector(downloadEnded) withObject:nil waitUntilDone:NO];
		XMLparser.delegate = self;
		[XMLparser parse];
		[XMLparser release];
		
		//Quitar referencias a objetos borrados
		self.currentString = nil;
		
		[pool release];
	}
	return self;	
}


- (id) initWithData:(NSData *)data{
	self = [super init];
	
	if (self !=nil){
		
		//Nueva pool para gestionar autorelease
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		//Inicializacion de variables
		self.currentString = [[[NSMutableString alloc] initWithCapacity:32] autorelease];
		self.elementStack = [[[NSMutableArray alloc] initWithCapacity:6] autorelease];
		self.attributesStack = [[[NSMutableArray alloc] initWithCapacity:6] autorelease];
		
		//Parseador de XML
		//[self performSelectorOnMainThread:@selector(downloadStarted) withObject:nil waitUntilDone:NO];
		NSXMLParser *XMLparser = [[NSXMLParser alloc] initWithData:data];
		//[self performSelectorOnMainThread:@selector(downloadEnded) withObject:nil waitUntilDone:NO];
		XMLparser.delegate = self;
		[XMLparser parse];
		[XMLparser release];
		
		//Quitar referencias a objetos borrados
		self.currentString = nil;
		
		[pool release];
	}
	return self;	
}


static NSString *kOPML = @"opml";

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *) qualifiedName attributes:(NSDictionary *)attributeDict {
	
	//Añadimos el elemento a la pila y borramos el texto recogido
	NSString *parent = [elementStack lastObject];
	[elementStack addObject:[[elementName copy] autorelease]];
	[attributesStack addObject:attributeDict];
	[currentString setString:@""];
	
	//Si es la definicion de OPML, buscamos namespaces conocidos para crear su parser
	if ([elementName isEqualToString:kOPML]){		
		self.parser = [[[OPML20ParserDelegate alloc] init] autorelease];		
		self.opml = self.parser.opml;
	}
//	if ([self.parser respondsToSelector:@selector(initElement:::::)])
		[self.parser initElement:elementName namespaceURI:namespaceURI qName:qualifiedName attributes:attributeDict parent:parent];
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {

	//Quitamos el ultimo elemento, que será elementName
	[elementStack removeLastObject];
	
	//Obtenemos los atributos
	NSDictionary *dict = [[attributesStack lastObject] retain];
	[attributesStack removeLastObject];
	
	//Obtenemos el padre
	NSString *parent = [elementStack lastObject];
	[self.parser parseElement:elementName namespaceURI:namespaceURI qName:qName attributes:dict parent:parent currentString:currentString];
	
	[dict release];
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	@try {
		[currentString appendString:string];
	}
	@catch (NSException * e) {
		NSLog(@"Error en parser");
	}
}


- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSLog(@"parseErrorOccurred");
}

- (void) dealloc {
	[opml release];	
	[super dealloc];
}

@end
