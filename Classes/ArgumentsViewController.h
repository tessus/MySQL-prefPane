//
//  ArgumentsViewController.h
//  MySQL.prefPane
//
//  Copyright 2011 Iván Valdés Castillo. All rights reserved.
//  Copyright (c) Helmut K. C. Tessarek, 2015
//

#import <Cocoa/Cocoa.h>

@interface MSPPArgumentsViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource> {
	NSTableView *tableView;
@private
	NSMutableArray *arguments;
	NSMutableArray *parameters;
}

@property (nonatomic, strong) IBOutlet NSTableView *tableView;

- (IBAction)addRow:(id)sender;

@end
