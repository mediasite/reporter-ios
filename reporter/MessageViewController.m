//
//  MessageViewController.m
//  reporter
//
//  Created by Andrey Putilov on 12/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MessageViewController.h"

//todo: implement https://github.com/AlanQuatermain/AQGridView

@implementation MessageViewController
@synthesize textCell, message;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Репортаж";
        
        UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:@"Отправить" style:UIBarButtonItemStylePlain target:self action:@selector(sendMessage)];
        self.navigationItem.rightBarButtonItem = sendButton;
        [sendButton release];
    }
    return self;
}

- (id)initWithMessage:(Message *)aMessage {
    self = [self initWithStyle:UITableViewStylePlain];
    if (self) {
        self.message = aMessage;
        
        [message addObserver:self forKeyPath:@"text" options:0 context:nil];
        [message addObserver:self forKeyPath:@"photos" options:0 context:nil];
    }
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self.tableView reloadData];
}

- (void)sendMessage {
    TransportManager *transportManager = [[[TransportManager alloc] init] autorelease];
    [transportManager sendMessage:message];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)dealloc {
    [photoController release];
    [message release];
    [textCell release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setTextCell:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (message != nil) {
        return message.photos.count + 2;
    }
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 180;
    } else {
        return 44;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        TextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextCell"];
        if (cell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"TextCell" owner:self options:nil];
            cell = textCell;
            self.textCell = nil;
        }
        if (![message.text isEqualToString:@""]) {
            cell.customTextLabel.text = message.text;
            cell.customTextLabel.textColor = [UIColor blackColor];
        } else {
            cell.customTextLabel.text = @"Введите текст...";
            cell.customTextLabel.textColor = [UIColor darkGrayColor];
        }
        
        return cell;
    } else if (indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section]-1) {
        static NSString *CellIdentifier = @"AddMedia";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        cell.textLabel.text = @"Добавить фото";
        
        return cell;
    } else {
        static NSString *CellIdentifier = @"PictureCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        UIImprovedImage *image = [message.photos objectAtIndex:(NSUInteger)(indexPath.row-1)];
        cell.imageView.image = image;
        cell.textLabel.text = [NSString stringWithFormat:@"%d",indexPath.row];
        
        return cell;
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    int rowsInSection = [tableView.dataSource tableView:tableView numberOfRowsInSection:indexPath.section];
    if (indexPath.row !=0 && indexPath.row != rowsInSection-1) {
        return YES;
    }
    
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [message.photos removeObjectAtIndex:(NSUInteger)(indexPath.row-1)];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];

    if(indexPath.section == 0 && indexPath.row == 0) {
        MessageTextEditController *messageTextEditController = [[[MessageTextEditController alloc] initWithMessage:message] autorelease];
        [self.navigationController pushViewController:messageTextEditController animated:YES];
    }
    if (indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section]-1) {
        photoController = [[PhotoController alloc] initWithParentController:self message:message];
        [photoController showAddPhotoDialog];
    }
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
