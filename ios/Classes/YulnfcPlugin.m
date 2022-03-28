#import "YulnfcPlugin.h"
#if __has_include(<yulnfc/yulnfc-Swift.h>)
#import <yulnfc/yulnfc-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "yulnfc-Swift.h"
#endif

@implementation YulnfcPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftYulnfcPlugin registerWithRegistrar:registrar];
}
@end
