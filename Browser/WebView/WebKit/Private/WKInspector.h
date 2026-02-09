//
//  WKInspector.h
//  Browser
//
//  Created by Leonardo Larrañaga on 8/2/26.
//

#import <Foundation/Foundation.h>
#import <WebKit/WKFoundation.h>

@class WKWebView;
@class _WKFrameHandle;
@protocol _WKInspectorDelegate;

@interface _WKInspector : NSObject

- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, weak, nullable) id <_WKInspectorDelegate> delegate;
@property (nonatomic, readonly) WKWebView *webView;
@property (nonatomic, readonly) BOOL isConnected;
@property (nonatomic, readonly) BOOL isVisible;
@property (nonatomic, readonly) BOOL isFront;
@property (nonatomic, readonly) BOOL isProfilingPage;
@property (nonatomic, readonly) BOOL isElementSelectionActive;

- (void)connect;
- (void)show;
- (void)hide;
- (void)close;

- (void)showConsole;
- (void)showResources;
- (void)showMainResourceForFrame:(_WKFrameHandle *)frame;

- (void)attach;
- (void)detach;

- (void)togglePageProfiling;
- (void)toggleElementSelection;

- (void)printErrorToConsole:(NSString *)error;

@end

@protocol _WKInspectorDelegate <NSObject>
@optional
@end

// WKWebView category to access inspector
@interface WKWebView (Inspector)
@property (nonatomic, readonly) _WKInspector *_inspector;
@end
