//
//  _WKFeature.h
//  Browser
//
//  Created by Leonardo Larrañaga on 25/1/26.
//

#import <WebKit/WebKit.h>

/*!
 @enum WebFeatureStatus
 @abstract Field indicating the purpose and level of completeness of a web feature. Used to determine which UI (if any) should reveal a feature.
 */
typedef NS_ENUM(NSUInteger, WebFeatureStatus) {
    /// For customizing WebKit behavior in embedding applications.
    WebFeatureStatusEmbedder,
    /// Feature in active development. Unfinished, no promise it is usable or safe.
    WebFeatureStatusUnstable,
    /// Tools for debugging the WebKit engine. Not generally useful to web developers.
    WebFeatureStatusInternal,
    /// Tools for web developers.
    WebFeatureStatusDeveloper,
    /// Enabled by default in test infrastructure, but not ready to ship yet.
    WebFeatureStatusTestable,
    /// Enabled by default in Safari Technology Preview, but not considered ready to ship yet.
    WebFeatureStatusPreview,
    /// Enabled by default and ready for general use.
    WebFeatureStatusStable,
    /// Enabled by default and in general use for more than a year.
    WebFeatureStatusMature
};

/*!
 @enum WebFeatureCategory
 @abstract Field indicating the category of a web feature. Used to determine how a feature should be sorted or grouped in the UI.
 */
typedef NS_ENUM(NSUInteger, WebFeatureCategory) {
    WebFeatureCategoryNone = 0,
    WebFeatureCategoryAnimation = 1,
    WebFeatureCategoryCSS = 2,
    WebFeatureCategoryDOM = 3,
    WebFeatureCategoryJavascript = 4,
    WebFeatureCategoryMedia = 5,
    WebFeatureCategoryNetworking = 6,
    WebFeatureCategoryPrivacy = 7,
    WebFeatureCategorySecurity = 8,
    WebFeatureCategoryHTML = 9,
    WebFeatureCategoryExtensions = 10,
};

@interface _WKFeature : NSObject

@property (nonatomic, readonly, copy) NSString *key;
@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly) WebFeatureStatus status;
@property (nonatomic, readonly) WebFeatureCategory category;
@property (nonatomic, readonly, copy) NSString *details;
@property (nonatomic, readonly) BOOL defaultValue;
@property (nonatomic, readonly, getter=isHidden) BOOL hidden;

@end

@interface WKPreferences (PrivateFeatureFlags)
+ (NSArray<_WKFeature *> *)_experimentalFeatures;
- (void)_setEnabled:(BOOL)enabled forFeature:(_WKFeature *)feature;
- (BOOL)_isEnabledForFeature:(_WKFeature *)feature;
@end
