//
//  DeveloperFeatures.h
//  Browser
//
//  Created by Leonardo Larrañaga on 2/12/25.
//

#ifndef DeveloperFeatures_h
#define DeveloperFeatures_h

#import <WebKit/WebKit.h>

@class WKWebView;
@class _WKInspector;

// Declare the private _WKInspector class
@interface _WKInspector : NSObject
- (BOOL)isVisible;
- (void)show;
- (void)hide;
@end

// Declare the private WKWebView method
@interface WKWebView (Private)
@property (nonatomic, readonly) _WKInspector *_inspector;
@end

@interface DeveloperFeatures : NSObject

+ (void)toggleWebInspectorForWebView:(WKWebView *)webView;

@end

#endif /* DeveloperFeatures_h */
