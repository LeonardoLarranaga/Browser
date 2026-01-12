//
//  MediaControls.m
//  Browser
//
//  Created by Leonardo Larrañaga on 2/16/25.
//

#import "MediaControls.h"

@implementation MediaControls

+ (void)setPageMuted:(WKMediaMutedState)mutedState forWebView:(WKWebView *)webView {
    if ([webView respondsToSelector:@selector(_setPageMuted:)]) {
        WKMediaMutedState internalMutedState = (WKMediaMutedState)mutedState;
        [webView _setPageMuted:internalMutedState];
    }
}

+ (WKMediaMutedState)getPageMutedStateForWebView:(WKWebView *)webView {
    if ([webView respondsToSelector:@selector(_mediaMutedState)]) {
        return (WKMediaMutedState)[webView _mediaMutedState];
    }
    return WKMediaNoneMuted;
}

+ (BOOL)hasActiveNowPlayingSessionForWebView:(WKWebView *)webView {
    if ([webView respondsToSelector:@selector(_hasActiveNowPlayingSession)]) {
        return [webView _hasActiveNowPlayingSession];
    }
    return NO;
}

@end
