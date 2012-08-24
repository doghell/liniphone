/* BuschJaegerHistoryDetailsView.m
 *
 * Copyright (C) 2012  Belledonne Comunications, Grenoble, France
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#import "BuschJaegerHistoryDetailsView.h"
#import "UIHistoryDetailsCell.h"
#import "BuschJaegerMainView.h"
#import "BuschJaegerUtils.h"
#import "UACellBackgroundView.h"

@implementation BuschJaegerHistoryDetailsView

@synthesize history;
@synthesize tableController;
@synthesize backButton;
@synthesize stationLabel;
@synthesize dateLabel;
@synthesize imageView;

#pragma mark - Lifecycle Functions

- (void)initBuschJaegerHistoryDetailsView {
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSLocale *locale = [NSLocale currentLocale];
    [dateFormatter setLocale:locale];
}

- (id)init {
    self = [super init];
    if(self != nil) {
        [self initBuschJaegerHistoryDetailsView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self != nil) {
        [self initBuschJaegerHistoryDetailsView];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self != nil) {
        [self initBuschJaegerHistoryDetailsView];
    }
    return self;
}

- (void)dealloc {
    [tableController release];
    [history release];
    [backButton release];
    [stationLabel release];
    [dateLabel release];
    
    [imageView release];
    
    [dateFormatter release];
    
    [super dealloc];
}

#pragma mark - ViewController Functions

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [tableController.view setBackgroundColor:[UIColor clearColor]];
    
    /* init gradients */
    {
        UIColor* col1 = BUSCHJAEGER_NORMAL_COLOR;
        UIColor* col2 = BUSCHJAEGER_NORMAL_COLOR2;
        
        [BuschJaegerUtils createGradientForView:backButton withTopColor:col1 bottomColor:col2 cornerRadius:BUSCHJAEGER_DEFAULT_CORNER_RADIUS];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [imageView setHidden:TRUE];
}


#pragma mark - Property Functions

- (void)setHistory:(History *)ahistory {   
    [history release];
    history = [ahistory retain];
    [self update];
}


#pragma mark - 

- (void)update {
    [self view]; // Force view load
    [self.tableController.tableView reloadData];
    
    NSString *stationName = @"Unknown";
    NSSet *set = [[[LinphoneManager instance].configuration outdoorStations] filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"ID == %i", history.stationID]];
    if([set count] == 1) {
        OutdoorStation *station = [[set allObjects] objectAtIndex:0];
        stationName = station.name;
    }
    // Station
    [stationLabel setText:stationName];
    
    // Date
    [dateLabel setText:[dateFormatter stringFromDate:history.date]];
}


#pragma mark - Action Functions

- (IBAction)onBackClick:(id)sender {
    [[BuschJaegerMainView instance].navigationController popViewControllerAnimated:FALSE];
}

- (IBAction)nextImage:(id)sender {
    if([history.images count]) {
        currentIndex = (currentIndex - 1);
        if(currentIndex < 0) currentIndex = [history.images count] - 1;
        [imageView loadImage:[[LinphoneManager instance].configuration getImageUrl:BuschJaegerConfigurationRequestType_Local image:[history.images objectAtIndex:currentIndex]]];
    }
}

- (IBAction)previousImage:(id)sender {
    if([history.images count]) {
        currentIndex = (currentIndex + 1) % [history.images count];
        [imageView loadImage:[[LinphoneManager instance].configuration getImageUrl:BuschJaegerConfigurationRequestType_Local image:[history.images objectAtIndex:currentIndex]]];
    }
}

- (IBAction)hideImage:(id)sender {
    [imageView setHidden:TRUE];
}


#pragma mark - UITableViewDataSource Functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [history.images count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellId = @"UIHistoryCell";
    UIHistoryDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    if (cell == nil) {
        cell = [[[UIHistoryDetailsCell alloc] initWithIdentifier:kCellId] autorelease];
        
        // Background View
        UACellBackgroundView *selectedBackgroundView = [[[UACellBackgroundView alloc] initWithFrame:CGRectZero] autorelease];
        cell.selectedBackgroundView = selectedBackgroundView;
        [selectedBackgroundView setBackgroundColor:BUSCHJAEGER_NORMAL_COLOR];
        [selectedBackgroundView setBorderColor:[UIColor clearColor]];
    }
	
    [cell setImage:[history.images objectAtIndex:[indexPath row]]];
    
    return cell;
}


#pragma mark - UITableViewDelegate Functions

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    currentIndex = [indexPath row];
    [imageView setHidden:FALSE];
    [imageView setImage:nil];
    [imageView loadImage:[[LinphoneManager instance].configuration getImageUrl:BuschJaegerConfigurationRequestType_Local image:[history.images objectAtIndex:currentIndex]]];
}

@end