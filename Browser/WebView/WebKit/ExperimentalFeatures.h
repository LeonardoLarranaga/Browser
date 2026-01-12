//
//  ExperimentalFeatures.h
//  Browser
//
//  Created by Leonardo Larrañaga on 2/12/25.
//

#ifndef ExperimentalFeatures_h
#define ExperimentalFeatures_h

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

// Forward declare the class
@class _WKExperimentalFeature;

// Declare the private _WKExperimentalFeature class
@interface _WKExperimentalFeature : NSObject
@property (nonatomic, readonly, copy) NSString *key;
@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly, copy) NSString *details;
@property (nonatomic, readonly) BOOL defaultValue;
@property (nonatomic, readonly) BOOL hidden;
@end

// Declare the private WKPreferences methods
@interface WKPreferences (Private)
+ (NSArray<_WKExperimentalFeature *> *)_experimentalFeatures;
- (BOOL)_isEnabledForFeature:(_WKExperimentalFeature *)feature;
- (void)_setEnabled:(BOOL)enabled forFeature:(_WKExperimentalFeature *)feature;
@end

@interface ExperimentalFeatures : NSObject

+ (NSArray<_WKExperimentalFeature *> *)getExperimentalFeatures;
+ (void)toggleExperimentalFeature:(NSString *)featureKey enabled:(BOOL)enabled preferences:(WKPreferences *)preferences;

@end

#endif /* ExperimentalFeatures_h */
