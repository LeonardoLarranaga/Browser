//
//  DeveloperFeatures.m
//  Browser
//
//  Created by Leonardo Larrañaga on 2/12/25.
//

#import "DeveloperFeatures.h"

@implementation DeveloperFeatures

+ (void)toggleWebInspectorForWebView:(WKWebView *)webView {
    _WKInspector *inspector = [webView _inspector];
    if (inspector) {
        if ([inspector isVisible]) {
            [inspector hide];
        } else {
            [inspector show];
        }
    }
}

@end
