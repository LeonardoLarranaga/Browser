//
//  BrowserWKWebView.h
//  Browser
//
//  Created by Leonardo Larrañaga on 11/1/26.
//

#include <WebKit/WebKit.h>

typedef NS_OPTIONS(NSInteger, WKMediaMutedState) {
    WKMediaNoneMuted = 0,
    WKMediaAudioMuted = 1 << 0,
    WKMediaCaptureDevicesMuted = 1 << 1,
    WKMediaScreenCaptureMuted = 1 << 2,
};

@class _WKInspector;

@interface WKWebView (Private)

@property (nonatomic, setter=_setUsePlatformFindUI:) BOOL _usePlatformFindUI;
- (void)_hideFindUI;

- (void)_setPageMuted:(WKMediaMutedState)mutedState;
- (WKMediaMutedState)_mediaMutedState;
- (BOOL)_hasActiveNowPlayingSession;
- (void)_stopMediaCapture;

@property (nonatomic, getter=_isEditable, setter=_setEditable:) BOOL _editable;

@end
