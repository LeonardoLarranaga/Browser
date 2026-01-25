//
//  MediaControls.h
//  Browser
//
//  Created by Leonardo Larrañaga on 2/16/25.
//

#ifndef MediaControls_h
#define MediaControls_h

#include "BrowserWKWebView.h"
#import <WebKit/WebKit.h>

@interface MediaControls : NSObject

+ (void)setPageMuted:(WKMediaMutedState)mutedState forWebView:(WKWebView *)webView;
+ (WKMediaMutedState)getPageMutedStateForWebView:(WKWebView *)webView;

+ (BOOL)hasActiveNowPlayingSessionForWebView:(WKWebView *)webView;

@end


#endif /* MediaControls_h */
