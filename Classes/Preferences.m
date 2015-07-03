//
//  Preferences.m
//  MySQL.prefPane
//
//  Copyright 2011 Iván Valdés Castillo. All rights reserved.
//  Copyright (c) Helmut K. C. Tessarek, 2015
//

#import "Preferences.h"

@implementation MSPPPreferences
@synthesize bundle;

static MSPPPreferences *sharedPreferences = nil;

+ (MSPPPreferences *)sharedPreferences {

	@synchronized(self) {
		if (!sharedPreferences)
			sharedPreferences = [[self alloc] init];
	}

	return sharedPreferences;
}

+ (id)allocWithZone:(NSZone *)zone {

	@synchronized(self) {
		if (!sharedPreferences) {
			sharedPreferences = [super allocWithZone:zone];
			return sharedPreferences;
		}
	}

	return nil;
}

- (id)copyWithZone:(NSZone *)zone {
	return self;
}

- (id)objectForUserDefaultsKey:(NSString *)key {
	CFPropertyListRef obj = CFPreferencesCopyAppValue((CFStringRef)key, (CFStringRef)[bundle bundleIdentifier]);
	return (__bridge id)obj;
}

- (void)setObject:(id)value forUserDefaultsKey:(NSString *)key {
	CFPreferencesSetValue((CFStringRef)key, (__bridge CFPropertyListRef)(value), (CFStringRef)[bundle bundleIdentifier], kCFPreferencesCurrentUser,  kCFPreferencesAnyHost);
	CFPreferencesSynchronize((CFStringRef)[bundle bundleIdentifier], kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
}

- (NSArray *)argumentsWithParameters {
	NSMutableArray *theArgumentsWithParameters = [NSMutableArray array];
	NSArray *parameters = [self objectForUserDefaultsKey:@"parameters"];
	
	[[self objectForUserDefaultsKey:@"arguments"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSString *argument  = obj;
		NSString *parameter = [parameters[idx] stringByExpandingTildeInPath];
		
		if ([argument length] && [argument characterAtIndex:0] == '-') {
			[theArgumentsWithParameters addObject:argument];
			if ([parameter length])
				[theArgumentsWithParameters addObject:parameter];
		}
	}];
	
	return (NSArray *)theArgumentsWithParameters;
}

- (void)setBundle:(NSBundle *)aBundle
{
	if (bundle != aBundle)
	{
		bundle = aBundle;

		if (bundle)
		{
			if (![self objectForUserDefaultsKey:@"arguments"])
				[self setObject:@[] forUserDefaultsKey:@"arguments"];
			if (![self objectForUserDefaultsKey:@"parameters"])
				[self setObject:@[] forUserDefaultsKey:@"parameters"];
			if (![self objectForUserDefaultsKey:@"launchPath"] || [[self objectForUserDefaultsKey:@"launchPath"] isEqualToString:@""])
			{
				NSFileManager *fileManager = [NSFileManager defaultManager];
				NSString *location = @"";
				
				if([fileManager fileExistsAtPath:@"/usr/local/mysql/bin/mysqld"])
					location = @"/usr/local/mysql/bin/";
				/*
				else if ([fileManager fileExistsAtPath:@"/usr/bin/mysqld"])
					location = @"/usr/bin/";
				else if ([fileManager fileExistsAtPath:@"/bin/mysqld"])
					location = @"/bin/";
				else if ([fileManager fileExistsAtPath:@"/sbin/mysqld"])
					location = @"/sbin/";
				else if ([fileManager fileExistsAtPath:@"/opt/bin/mysqld"])
					location = @"/opt/bin/";
				else if ([fileManager fileExistsAtPath:@"/opt/local/bin/mysqld"])
					location = @"/opt/local/bin/";
				 */
				
				[self setObject:location forUserDefaultsKey:@"launchPath"];
			}
		}
	}
}

@end
