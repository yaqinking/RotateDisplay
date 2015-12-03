//
//  AppDelegate.m
//  RotateDisplay
//
//  Created by 小笠原やきん on 15/12/2.
//  Copyright © 2015年 yaqinking. All rights reserved.
//

#import "AppDelegate.h"
#import "Shortcut.h"

static NSString *const MASCustomShortcutEnabledKey = @"customShortcutEnabled";
static NSString *const RotateRightShortcutKey = @"rotateRightShortcut";
static NSString *const RotateStandardShortcutKey = @"rotateStandardShortcut";

static void *MASObservingContext = &MASObservingContext;

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (strong, nonatomic) NSStatusItem *statusItem;

@property (strong) IBOutlet MASShortcutView *rotateRightShortcutView;
@property (strong) IBOutlet MASShortcutView *rotateStandardShortcutView;

@end

@implementation AppDelegate

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults registerDefaults:@{
                                 MASCustomShortcutEnabledKey : @YES,
                                 }];
    
    [_rotateRightShortcutView setAssociatedUserDefaultsKey:RotateRightShortcutKey];
    [_rotateStandardShortcutView setAssociatedUserDefaultsKey:RotateStandardShortcutKey];

    [_rotateRightShortcutView bind:@"enabled"
                          toObject:defaults
                  withKeyPath:MASCustomShortcutEnabledKey
                           options:nil];
    [_rotateStandardShortcutView bind:@"enabled"
                             toObject:defaults
                          withKeyPath:MASCustomShortcutEnabledKey
                              options:nil];
    
    [defaults addObserver:self
               forKeyPath:MASCustomShortcutEnabledKey
                  options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew
                  context:MASObservingContext];

}

- (void) observeValueForKeyPath:(NSString*) keyPath
                       ofObject:(id) object
                         change:(NSDictionary*) change
                        context:(void*) context {
    if (context != MASObservingContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    BOOL newValue = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
    if ([keyPath isEqualToString:MASCustomShortcutEnabledKey]) {
        [self setCustomShortcutEnabled:newValue];
    }
}

- (void) setCustomShortcutEnabled:(BOOL) enabled
{
    if (enabled) {
        [[MASShortcutBinder sharedBinder] bindShortcutWithDefaultsKey:RotateRightShortcutKey toAction:^{
            [self rotateToRight];
        }];
        [[MASShortcutBinder sharedBinder] bindShortcutWithDefaultsKey:RotateStandardShortcutKey toAction:^{
            [self rotateToNormal];
        }];
    } else {
        [[MASShortcutBinder sharedBinder] breakBindingWithDefaultsKey:RotateRightShortcutKey];
        [[MASShortcutBinder sharedBinder] breakBindingWithDefaultsKey:RotateStandardShortcutKey];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.title = @"RD";
    self.statusItem.highlightMode = YES;
    
    NSMenu *menu = [[NSMenu alloc] init];
    [menu addItemWithTitle:@"Rotate 90°"
                    action:@selector(rotateToRight)
             keyEquivalent:@"r"];
    [menu addItemWithTitle:@"Rotate standard"
                    action:@selector(rotateToNormal)
             keyEquivalent:@"s"];
    [menu addItemWithTitle:@"Quit RotateDisplay"
                    action:@selector(terminate:)
             keyEquivalent:@"q"];
    
    self.statusItem.menu = menu;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)rotateToRight {
    [self playPingSound];
    IOOptionBits options = (0x00000400 | (kIOScaleRotate90)  << 16);
    [self rotateToAngelWithOptions:options];
}

- (void)rotateToNormal {
    [self playPingSound];
    IOOptionBits options = (0x00000400 | (kIOScaleRotate0)  << 16);
    [self rotateToAngelWithOptions:options];
}

- (void)rotateToAngelWithOptions:(IOOptionBits)options {
    CGDirectDisplayID display = CGMainDisplayID();
    io_service_t service = CGDisplayIOServicePort(display);
    IOServiceRequestProbe(service, options);
}

- (void)playPingSound {
    [[NSSound soundNamed:@"Ping"] play];
}

@end
