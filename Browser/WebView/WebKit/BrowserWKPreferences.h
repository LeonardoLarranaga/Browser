//
//  BrowserWKPreferenches.h
//  Browser
//
//  Created by Leonardo Larrañaga on 11/1/26.
//

#include <WebKit/WKPreferences.h>

@interface WKPreferences (Private)
@property (nonatomic, setter=_setDeveloperExtrasEnabled:) BOOL _developerExtrasEnabled;

@property (nonatomic, setter=_setApplePayEnabled:) BOOL _applePayEnabled;
@property (nonatomic, setter=_setApplePayCapabilityDisclosureAllowed:) BOOL _applePayCapabilityDisclosureAllowed;

@property (nonatomic, setter=_setAllowsPictureInPictureMediaPlayback:) BOOL _allowsPictureInPictureMediaPlayback;

@end
