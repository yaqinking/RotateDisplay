//
//  AppDelegate.m
//  RotateDisplay
//
//  Created by 小笠原やきん on 15/12/2.
//  Copyright © 2015年 yaqinking. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (strong, nonatomic) NSStatusItem *statusItem;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.title = @"RD";
    self.statusItem.highlightMode = YES;
    
    NSMenu *menu = [[NSMenu alloc] init];
    [menu addItemWithTitle:@"Rotate 90°"
                    action:@selector(rotateToRight:)
             keyEquivalent:@"r"];
    [menu addItemWithTitle:@"Rotate standard"
                    action:@selector(rotateToNormal:)
             keyEquivalent:@"s"];
    [menu addItemWithTitle:@"Quit Rotate Display"
                    action:@selector(terminate:)
             keyEquivalent:@"q"];
    
    self.statusItem.menu = menu;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)rotateToRight:(id)sender {
    IOOptionBits options = (0x00000400 | (kIOScaleRotate90)  << 16);
    [self rotateToAngelWithOptions:options];
}

- (void)rotateToNormal:(id)sender {
    IOOptionBits options = (0x00000400 | (kIOScaleRotate0)  << 16);
    [self rotateToAngelWithOptions:options];
}

- (void)rotateToAngelWithOptions:(IOOptionBits)options {
    CGDirectDisplayID display = CGMainDisplayID();
    io_service_t service = CGDisplayIOServicePort(display);
    IOServiceRequestProbe(service, options);
}

@end
