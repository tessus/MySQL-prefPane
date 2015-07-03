//
//  mysqlPref.m
//  MySQL.prefPane
//
//  Copyright (c) 2010 Iván Valdés Castillo, released under the MIT license
//  Copyright (c) Helmut K. C. Tessarek, 2015
//

#import "mysqlPref.h"
#import "MBSliderButton.h"
#import "DaemonController.h"
#import "Preferences.h"

@interface mysqlPref(/* Hidden Methods */)
- (void)binaryLocationChanged:(NSNotification *)notification;

@property (nonatomic, strong) MSPPDaemonController *daemonController;
@end

@implementation mysqlPref
@synthesize theSlider;
@synthesize daemonController;
@synthesize launchPathTextField;
@synthesize pidtext;

- (instancetype)initWithBundle:(NSBundle *)bundle {
	if ((self = [super initWithBundle:bundle])) {
		[[MSPPPreferences sharedPreferences] setBundle:bundle];
	}

	numClicked = 0;
	NSDictionary* infoDict = [[NSBundle bundleForClass:[self class]] infoDictionary];
	version = [[NSString alloc] initWithFormat:@"%@ (%@)", infoDict[@"CFBundleShortVersionString"], infoDict[@"CFBundleVersion"]];
	githash = [[NSString alloc] initWithFormat:@"%@", infoDict[@"GitHash"]];
	[versionText setTitle:version];
	
	return self;
}

- (void)mainViewDidLoad {
	MSPPDaemonController *dC = [[MSPPDaemonController alloc] init];
	self.daemonController = dC;
	
	NSMutableArray *arguments = (NSMutableArray *)[[MSPPPreferences sharedPreferences] argumentsWithParameters];
	//NSLog(@"arguments (MySQL): %@", arguments);

	NSString *lp = [[MSPPPreferences sharedPreferences] objectForUserDefaultsKey:@"launchPath"];

	daemonController.launchPathStart = [lp stringByAppendingString:@"mysqld_safe"];
	daemonController.launchPath      = [lp stringByAppendingString:@"mysqld"];
	daemonController.startArguments  = arguments;

	[versionText setTitle:version];

	__weak typeof(theSlider) weakSlider = theSlider;
	__weak typeof(pidtext) weakPidtext = pidtext;
	
	daemonController.daemonStartedCallback = ^(NSNumber *pid) {
		[weakPidtext setStringValue:[[NSString alloc] initWithFormat:@"PID: %@", pid ]];
		[weakSlider setState:NSOnState animate:YES];
	};
	
	daemonController.daemonFailedToStartCallback = ^(NSString *reason) {
		NSLog(@"start error (MySQL): %@", reason);
		[weakPidtext setStringValue:@""];
		[weakSlider setState:NSOffState animate:YES];
	};

	daemonController.daemonStoppedCallback = ^(void) {
		[weakPidtext setStringValue:@""];
		[weakSlider setState:NSOffState animate:YES];
	};

	daemonController.daemonFailedToStopCallback = ^(NSString *reason) {
		[weakSlider setState:NSOnState animate:YES];
	};

	[theSlider setState:daemonController.isRunning ? NSOnState : NSOffState];
	[launchPathTextField setStringValue:lp];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(binaryLocationChanged:) name:NSControlTextDidChangeNotification object:launchPathTextField];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)clickVersion:(id)sender {
	numClicked++;

	if ((numClicked % 2) == 1) {
		[versionText setTitle:githash];
	}
	else
	{
		[versionText setTitle:version];
		numClicked = 0;
	}
}

- (IBAction)openWebsite:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: @"https://github.com/tessus/MySQL-prefPane"]];
}

- (IBAction)startStopDaemon:(id)sender {
	NSMutableArray *arguments = (NSMutableArray *)[[MSPPPreferences sharedPreferences] argumentsWithParameters];
	
	NSString *lp = [[MSPPPreferences sharedPreferences] objectForUserDefaultsKey:@"launchPath"];
	daemonController.launchPath     = [lp stringByAppendingString:@"mysqld"];
	daemonController.startArguments = arguments;

	if (theSlider.state == NSOffState)
	{
		[daemonController stop];
		[pidtext setStringValue:@""];
	}
	else
		[daemonController start];
}

- (IBAction)clickOnOff:(id)sender {
	NSMutableArray *arguments = (NSMutableArray *)[[MSPPPreferences sharedPreferences] argumentsWithParameters];

	NSString *lp = [[MSPPPreferences sharedPreferences] objectForUserDefaultsKey:@"launchPath"];
	daemonController.launchPath     = [lp stringByAppendingString:@"mysqld"];
	daemonController.startArguments = arguments;

	int tag = (int)[sender tag];

	if (tag == 0 && daemonController.isRunning)
	{
		[daemonController stop];
		[pidtext setStringValue:@""];
		[theSlider setState:NSOffState animate:YES];
	}
	if (tag == 1 && !daemonController.isRunning)
	{
		[daemonController start];
	}
}

- (IBAction)locateBinary:(id)sender {
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setCanChooseFiles:NO];
	[openPanel setShowsHiddenFiles:YES];
	[openPanel setResolvesAliases:NO];
	
	if (![[launchPathTextField stringValue] isEqualToString:@""])
		[openPanel setDirectoryURL:[NSURL fileURLWithPath:[[launchPathTextField stringValue] stringByDeletingLastPathComponent]]];
	
	if ([openPanel runModal] == NSOKButton) {
		[launchPathTextField setStringValue:[openPanel.URL path]];
		[[MSPPPreferences sharedPreferences] setObject:[launchPathTextField stringValue] forUserDefaultsKey:@"launchPath"];
		daemonController.launchPath = [[MSPPPreferences sharedPreferences] objectForUserDefaultsKey:@"launchPath"];
	}
}

- (void)binaryLocationChanged:(NSNotification *)notification {
	[[MSPPPreferences sharedPreferences] setObject:[launchPathTextField stringValue] forUserDefaultsKey:@"launchPath"];
	daemonController.launchPath = [[MSPPPreferences sharedPreferences] objectForUserDefaultsKey:@"launchPath"];
}

@end
