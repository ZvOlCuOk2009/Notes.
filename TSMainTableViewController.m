//
//  MainTableViewController.m
//  Notes
//
//  Created by Mac on 12.05.16.
//  Copyright © 2016 Tsvigun Alexandr. All rights reserved.
//

#import "TSMainTableViewController.h"
#import "TSTableViewCell.h"
#import "TSContentViewController.h"
#import "TSNote.h"
#import "TSDataManager.h"
#import <CoreData/CoreData.h>

@interface TSMainTableViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) TSNote *note;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation TSMainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                             target:self action:@selector(addNote:)];
    
    self.navigationItem.leftBarButtonItem = addItem;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    /*
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Image"]];
    
    UIColor *tintColor = [UIColor colorWithRed:228.0f/255.0f green:171.0f/255.0f blue:31.0f/255.0f alpha:1];
    self.navigationController.navigationBar.tintColor = tintColor;
}

#pragma mark - NSManagedObjectContext

-(NSManagedObjectContext *) managedObjectContext {
    
    if (!_managedObjectContext) {
        _managedObjectContext = [[TSDataManager sharedManager] managedObjectContext];
    }
    return _managedObjectContext;
}

#pragma mark - Actions

- (void)addNote:(UIBarButtonItem *)item
{
    TSContentViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"TSContentViewController"];
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    dateFormater.dateFormat = @"dd.MM.yyyy HH:mm";
    controller.data = [dateFormater stringFromDate:[NSDate date]];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - Configure Cell

- (void)configureCell:(TSTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    TSNote *note = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.dataLabel.text = note.data;
    cell.contentLabel.text = note.content;
}

#pragma mark - UITableviewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TSContentViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"TSContentViewController"];
    self.note = [self.fetchedResultsController objectAtIndexPath:indexPath];
    controller.data = self.note.data;
    controller.content = self.note.content;
    [controller receiveCell:self.note];
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Error deleting item in coredata %@",[error localizedDescription]);
        }
    }
}

#pragma mark - animation cell

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.frame = CGRectMake(0 - CGRectGetWidth(cell.frame), CGRectGetMinY(cell.frame),
                            CGRectGetWidth(cell.frame), CGRectGetHeight(cell.frame));
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         cell.frame = CGRectMake(0, CGRectGetMinY(cell.frame),
                                                 CGRectGetWidth(cell.frame),
                                                 CGRectGetHeight(cell.frame));
                         
                         cell.backgroundColor = [UIColor clearColor];
                         
                     } completion:^(BOOL finished) {
                     }];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TSNote" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sortDescriptorData = [[NSSortDescriptor alloc] initWithKey:@"content" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptorData]];
    NSFetchedResultsController *aFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext
                                          sectionNameKeyPath:nil
                                                   cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        default:
            return;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

@end
