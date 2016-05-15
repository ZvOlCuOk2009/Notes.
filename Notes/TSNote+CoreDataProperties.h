//
//  TSNote+CoreDataProperties.h
//  Notes
//
//  Created by Mac on 12.05.16.
//  Copyright © 2016 Tsvigun Alexandr. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "TSNote.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSNote (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *data;
@property (nullable, nonatomic, retain) NSString *content;

@end

NS_ASSUME_NONNULL_END
