//
//  ExperimentalFeatures.m
//  Browser
//
//  Created by Leonardo Larrañaga on 2/12/25.
//

#import "ExperimentalFeatures.h"

@implementation ExperimentalFeatures

+ (NSArray<_WKExperimentalFeature *> *)getExperimentalFeatures {
    return [WKPreferences _experimentalFeatures];
}

+ (void)toggleExperimentalFeature:(NSString *)featureKey enabled:(BOOL)enabled preferences:(WKPreferences *)preferences {
    for (_WKExperimentalFeature *feature in [WKPreferences _experimentalFeatures]) {
        if ([feature.key isEqualToString:featureKey]) {
            [preferences _setEnabled:enabled forFeature:feature];
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:feature.key];
            printf("Feature %s is now %s\n", [feature.key UTF8String], enabled ? "enabled" : "disabled");
            return;
        }
    }
}

@end
