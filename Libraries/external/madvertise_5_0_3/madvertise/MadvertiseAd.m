// Copyright 2011 madvertise Mobile Advertising GmbH
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "MadvertiseAd.h"
#import "MadvertiseUtilities.h"


@implementation MadvertiseAd

@synthesize bannerType;
@synthesize richmediaUrl;
@synthesize richmediaMarkup;
@synthesize bannerUrl;
@synthesize clickUrl;
@synthesize text;
@synthesize hasBanner;
@synthesize isRichMedia;
@synthesize width;
@synthesize height;
@synthesize shouldOpenInAppBrowser;
@synthesize trackingArray;

- (MadvertiseAd*)initFromDictionary:(NSDictionary*)dictionary {

  if ((self = [super init])) {
      MadLog(@"%@", dictionary);

      clickUrl                = [[dictionary objectForKey:@"click_url"] retain];
      text                    = [([dictionary objectForKey:@"text"] ?: @"") retain];
      hasBanner               = [[dictionary objectForKey:@"has_banner"] boolValue];
      shouldOpenInAppBrowser  = [[dictionary objectForKey:@"should_open_in_app"] boolValue];
      
      trackingArray = [dictionary objectForKey:@"tracking"];
      [trackingArray retain];

      width  = 0;
      height = 0;
   
      if (hasBanner) {
          bannerUrl    = [[[dictionary objectForKey:@"banner"] objectForKey:@"url"] retain];
          bannerType   = [[[dictionary objectForKey:@"banner"] objectForKey:@"type"] retain];
          
          // could be rich media
          if ([bannerType isEqualToString:@"rich_media"]) {
              isRichMedia = YES;
              NSDictionary* rm = [[dictionary objectForKey:@"banner"] objectForKey:@"rich_media"];
              richmediaUrl = [[rm objectForKey:@"full_url"] retain];
              richmediaMarkup = [[rm objectForKey:@"markup"] retain];
              isMraid = [[rm objectForKey:@"mraid"] boolValue];
              
              id w = [rm objectForKey:@"width"];
              if (w) {
                  width = [w intValue];
              }
                  
              id h = [rm objectForKey:@"height"];
              if (h) {
                  height = [h intValue];
              }
          } else {
              isRichMedia = NO;
          }
      }
  }
  return self;
}

- (NSString*)trackingHtml {
    if (!trackingArray) {
        return @"";
    }
    
    NSString* template = @"<img src='%@' width='1' height='1' alt=''>";
    
    NSString* result = @"";
    for (NSString* trackingUrl in trackingArray) {
        result = [result stringByAppendingString:[NSString stringWithFormat:template, trackingUrl]];
    }
    
    return result;
}

- (NSString*)textAdToHtml {
  NSString* template = @""
  "<html>"
  "<head>"
  "<style type=\"text/css\">"
  "body {"
  "width:320px;"
  "height:53px;"
  "  margin-left:0px; margin-right:0px; margin-top:0px; margin-bottom:0px; padding:0px; text-align:center; border:none;"
  "overflow: hidden;"
  "}"
  "div {"
  "background: -webkit-gradient(linear, left top, left bottom, from(rgba(0,0,0,0.75)), to(rgba(0,0,0,1)));"
  "width:321px;"
  "height:53px;"
  "  margin-left:0px; margin-right:0px; margin-top:0px; margin-bottom:0px; padding:0px; text-align:center; border:none;"
  "color: #FFF;"
  "  font-family: helvetica;"
  "  font-size: %dpx;"
  "}"
  "p {"
  "padding:10px;"
  "}"
  "div.madvertise {"
  "  font-size: 9px;"
  "position: absolute;"
  "top: 40px;"
  "left: 120px;"
  "background: none;"
  "}"
  "</style>"
  "</head>"
  "<body>"
  "<div><p>%@</p><div class='madvertise'>ad by madvertise</div></div>"
  "%@"
  "</body>"
  "</html>";
  int size = 28;
  if(self.text.length > 30) {
    size -= (self.text.length - 30) * 1.5;
  }
  return [NSString stringWithFormat:template, size < 12 ? 12 : size, self.text, [self trackingHtml]];
}

- (NSString*) richmediaToHtml {
    NSString* template = @""
    "<html>"
    "<head>"
    "<style type=\"text/css\">"
    "body {"
    "  margin-left:0px; margin-right:0px; margin-top:0px; margin-bottom:0px; padding:0px; text-align:center; border:none;"
    "overflow: hidden;"                                                                                                 
    "background-color: transparent !important;"
    "}"
    "</style>"
    "</head>"
    "<body>"
    "<script type='text/javascript' src='mraid.js'></script>"
    "<script>"
    "function ready() {"
    "    mraid.useCustomClose(true);"
    "};"
    "if (mraid.getState() === 'loading') {"
    "    mraid.addEventListener('ready', ready);"
    "} else {"
    "    ready();"
    "}"
    "window.addEventListener('message', function( event ) {"
    "  if(typeof(event.data) == 'string') {"
    "    if(event.data == 'madvertise.ad.close') {"
    "      mraid.close();"
    "    }"
    "  } else {"
    "    if(event.data.type == 'madvertise.ad.redirect') {"
    "      mraid.open(event.data.data);"
    "    }"
    "    else if(event.data.action == 'madvertise.ad.redirect') {"
    "      mraid.open(event.data.url);"
    "    }"
    "    else if(event.data.action == 'madvertise.ad.close') {"
    "      mraid.close();"
    "    }"
    "  }"
    "}, false );"
    "</script>"
    "<iframe id='main' src='%@' allowtransparency='true' width='320' height='480' seamless scrolling='no' style='z-index:10000; background:none;position: fixed;top: 0px;float:left;overflow: hidden !important;border: none !important;background-color: none !important;' />"
    "</body>"
    "</html>";
    
    return [NSString stringWithFormat:template, self.richmediaUrl];
}

- (NSString*) mraidToHtml {
    return [NSString stringWithFormat:@"<script type='text/javascript' src='%@'></script>", self.bannerUrl];
}

- (NSString*) to_html {
    if (self.isRichMedia) {
        if (isMraid) {
            return [self mraidToHtml];
        }
        else {
            return [self richmediaToHtml];
        }
    }
    
    if (!self.hasBanner) {
        return [self textAdToHtml];
    }
  
    NSString* template = @""
        "<html>"
        "<head>"
        "<style type=\"text/css\"> body {margin-left:0px; margin-right:0px; margin-top:0px; margin-bottom:0px; padding:0px; background-color:black; text-align:center; border:none}</style>"
        "</head>"
        "<body>"
        "%@"
        "</body>"
        "</html>";

    NSString* body = @"";

    if (self.bannerUrl) {
        body = [NSString stringWithFormat:@"<img src=\"%@\"></img>%@", self.bannerUrl, [self trackingHtml]];
    }
    
    return [NSString stringWithFormat:template, body];
}

- (Boolean)isLoadableViaUrl {    
    return (self.isRichMedia && self.richmediaUrl && isMraid);
}

- (NSURL*)url {
    return [NSURL URLWithString:self.richmediaUrl];
}

- (void)dealloc {
    self.clickUrl = nil;
    self.bannerUrl = nil;
    self.text = nil;
    self.bannerType = nil;
    self.richmediaUrl = nil;
    self.richmediaMarkup = nil;
    self.trackingArray = nil;

    [super dealloc];
}

@end
