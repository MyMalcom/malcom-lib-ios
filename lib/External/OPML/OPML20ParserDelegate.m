//
//  OPML20ParserDelegate.m
//  rss20
//
//  Created by Angel Garcia Olloqui on 04/02/09.
//  Copyright 2009 Mi Mundo iPhone. All rights reserved.
//

#import "OPML20ParserDelegate.h"


@interface OPML20ParserDelegate ()

- (void) parseHeadElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qName:(NSString *)qName attributes:(NSDictionary *)attributeDict  currentString:(NSString *)currentString;
- (void) parseBodyElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qName:(NSString *)qName attributes:(NSDictionary *)attributeDict  currentString:(NSString *)currentString;
- (void) parseOutlineElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qName:(NSString *)qName attributes:(NSDictionary *)attributeDict  currentString:(NSString *)currentString;


@end






@implementation OPML20ParserDelegate


@synthesize parseFormatter, opml, outlines;


//Creacion de variables estaticas para evitar crearlas en ejecucion multiples veces
static NSString *kHead = @"head";
static NSString *kHead_dateModified = @"dateModified";
static NSString *kHead_dateCreated = @"dateCreated";
static NSString *kHead_vertScrollState = @"vertScrollState";
static NSString *kHead_windowTop = @"windowTop";
static NSString *kHead_windowLeft = @"windowLeft";
static NSString *kHead_windowBottom = @"windowBottom";
static NSString *kHead_windowRight = @"windowRight";
static NSString *kBody = @"body";
static NSString *kOutline = @"outline";


- (id) init {

	self = [super init];
	if (self != nil){
		
		self.opml = [[OPML alloc] init];
		
		//Formateador de texto
		self.parseFormatter = [[NSDateFormatter alloc] init];
		[parseFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
//		[parseFormatter setDateFormat:@"MMM dd yyyy HH:mm:ss zzz"];
		[parseFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];		
		
		outlines = [[NSMutableArray alloc] initWithCapacity:1];
	}
	return self;
}


//Funcion encargada de manejar la recursividad de los elementos outline mediante pilas
- (void) initElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qName:(NSString *)qName attributes:(NSDictionary *)attributeDict parent:(NSString *)parent {
	//Si es un outline, lo agregamos a la pila
	if ([elementName isEqualToString:kOutline]){
		Outline *outline = [[Outline alloc] init];
		[outlines addObject:outline];			
		[outline release];
	}
}


- (void) parseElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qName:(NSString *)qName attributes:(NSDictionary *)dict parent:(NSString *)parent currentString:(NSString *)currentString{
	
	if ([parent isEqualToString:kHead]){
		[self parseHeadElement:elementName namespaceURI:namespaceURI qName:qName attributes:dict currentString:currentString];	
	}
	else if ([parent isEqualToString:kBody]){
		[self parseBodyElement:elementName namespaceURI:namespaceURI qName:qName attributes:dict currentString:currentString];	
	}	
	else if ([parent isEqualToString:kOutline]){
		[self parseOutlineElement:elementName namespaceURI:namespaceURI qName:qName attributes:dict currentString:currentString];	
	}
}


/************ PARSERS A MEDIDA POR ELEMENTO ************/
- (void) parseOutlineAttributes:(Outline *)outline elementName:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qName:(NSString *)qName attributes:(NSDictionary *)attributeDict  currentString:(NSString *)currentString {

	[self executeSettersFromDict:outline dict:attributeDict];
	
	outline.isBreakpoint=[[attributeDict valueForKey:@"isBreakpoint"] isEqualToString:@"true"];
	outline.isComment=[[attributeDict valueForKey:@"isComment"] isEqualToString:@"true"];
	outline.outlineId=[attributeDict valueForKey:@"id"];
	if ([attributeDict valueForKey:@"created"]!=nil)
		outline.created=[parseFormatter dateFromString:[attributeDict valueForKey:@"created"]];	
	else{
		[outline.created release];
		outline.created=nil;
	}
}


- (void) parseHeadElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qName:(NSString *)qName attributes:(NSDictionary *)attributeDict  currentString:(NSString *)currentString {
	if ([elementName isEqualToString:kHead_dateCreated])
		opml.head.dateCreated=[parseFormatter dateFromString:currentString];	
	else if ([elementName isEqualToString:kHead_dateModified])
		opml.head.dateModified=[parseFormatter dateFromString:currentString];	
	else if ([elementName isEqualToString:kHead_vertScrollState])
		opml.head.vertScrollState=[currentString intValue];	
	else if ([elementName isEqualToString:kHead_windowTop])
		opml.head.windowTop=[currentString intValue];	
	else if ([elementName isEqualToString:kHead_windowLeft])
		opml.head.windowLeft=[currentString intValue];	
	else if ([elementName isEqualToString:kHead_windowBottom])
		opml.head.windowBottom=[currentString intValue];	
	else if ([elementName isEqualToString:kHead_windowRight])
		opml.head.windowRight=[currentString intValue];	
	else
		[self executeSetter:elementName objeto:opml.head  currentString:currentString];

}


- (void) parseBodyElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qName:(NSString *)qName attributes:(NSDictionary *)attributeDict  currentString:(NSString *)currentString{
	if ([elementName isEqualToString:kOutline]){
		Outline *outline = [[outlines lastObject] retain];
		[self parseOutlineAttributes:outline elementName:elementName namespaceURI:namespaceURI qName:qName attributes:attributeDict currentString:currentString];
		[outlines removeLastObject];		
		[opml.body addOutline:outline];
		[outline release];
	}
}



- (void) parseOutlineElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qName:(NSString *)qName attributes:(NSDictionary *)attributeDict  currentString:(NSString *)currentString{
	if ([elementName isEqualToString:kOutline]){
		Outline *outline = [[outlines lastObject] retain];
		[self parseOutlineAttributes:outline elementName:elementName namespaceURI:namespaceURI qName:qName attributes:attributeDict currentString:currentString];
		[outlines removeLastObject];
		Outline *parent = [outlines lastObject];
		[parent addOutline:outline];
		[outline release];
	}
}


/************ FIN DE PARSERS A MEDIDA ************/



- (void) executeSetter:(NSString *)name objeto:(NSObject *)objeto currentString:(NSString *)currentString{
	
	NSString *setter = [[NSString alloc] initWithFormat:@"set%@%@:",[[name substringToIndex:1] capitalizedString], [name substringFromIndex:1]];
	SEL sel = NSSelectorFromString(setter);
	
	if ( [objeto respondsToSelector:sel] )
		[objeto performSelector:sel withObject:currentString];
	else
		NSLog(@"%@ no implementado", setter);
	[setter release];
}


- (void) executeSettersFromDict:(NSObject *)objeto dict:(NSDictionary *)dict{
	
	for (NSString *key in dict){
		NSString *setter = [[NSString alloc] initWithFormat:@"set%@%@:",[[key substringToIndex:1] capitalizedString], [key substringFromIndex:1]];
		SEL sel = NSSelectorFromString(setter);
		
		if ( [objeto respondsToSelector:sel] )
			[objeto performSelector:sel withObject:[dict valueForKey:key]];
		else
			NSLog(@"%@ no implementado", setter);
		
		[setter release];
	}	
}


- (id) allocNewInstanceFromAndRelease:(id)instance {	
	id new_obj=[[instance class] alloc];
	[instance release];
	return new_obj;
}

- (void) dealloc {

	[opml release];
	
	[parseFormatter release];
	[outlines release];
	
	[super dealloc];
}

@end
