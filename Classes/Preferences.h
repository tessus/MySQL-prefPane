//
//  Preferences.h
//  MySQL.prefPane
//
//  Copyright 2011 Iván Valdés Castillo. All rights reserved.
//  Copyright (c) Helmut K. C. Tessarek, 2015
//

@interface MSPPPreferences : NSObject {
	NSBundle *bundle;
}

@property (nonatomic, strong) NSBundle *bundle;

+ (MSPPPreferences *)sharedPreferences;

- (id)objectForUserDefaultsKey:(NSString *)key;
- (void)setObject:(id)value forUserDefaultsKey:(NSString *)key;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *argumentsWithParameters;

@end
