//
//  TSContentViewController.h
//  Notes
//
//  Created by Mac on 13.05.16.
//  Copyright © 2016 Tsvigun Alexandr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSNote.h"

@interface TSContentViewController : UIViewController

@property (strong, nonatomic) NSString *data;
@property (strong, nonatomic) NSString *content;

@property (weak, nonatomic) IBOutlet UILabel *dataLabel;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;

- (void)receiveCell:(TSNote *)note;

@end
