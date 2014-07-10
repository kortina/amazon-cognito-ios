/**
 * Copyright 2014 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 */

#import <Foundation/Foundation.h>
#import "AWSCognitoHandlers.h"

@class AWSCognitoRecord;
@class BFTask;

@interface AWSCognitoDatasetMetadata : NSObject

/**
 * The name of this dataset
 */
@property (nonatomic, readonly) NSString *name;
/**
 * The last sync count known on the client device.
 */
@property (nonatomic, readonly) NSNumber *lastSyncCount;
/**
 * The creation date of the dataset on the remote store.
 */
@property (nonatomic, readonly) NSDate *creationDate;
/**
 * The amount of storage on the remote store this dataset uses.
 */
@property (nonatomic, readonly) NSNumber *dataStorage;
/**
 * The id of the last device to modify this dataset.
 */
@property (nonatomic, readonly) NSString *lastModifiedBy;
/**
 * The date this dataset was last modified
 */
@property (nonatomic, readonly) NSDate *lastModifiedDate;
/**
 * The number of records in this dataset on the remote store.
 */
@property (nonatomic, readonly) NSNumber *numRecords;

@end

@interface AWSCognitoDataset : AWSCognitoDatasetMetadata

/**
 * A conflict resolution handler that will receive calls when there is a
 * conflict during a sync operation.  A conflict will occur when both remote and
 * local data have been updated since the last sync time.
 * When not explicitly set, we will use the default conflict resolution of
 * 'last writer wins', where the data most recently updated will be persisted.
 */
@property (nonatomic, copy) AWSCognitoRecordConflictHandler conflictHandler;

/**
 * A deleted dataset handler. This handler will be called during a synchronization
 * when the remote service indicates that a dataset has been deleted.
 * Returning YES from the handler will cause the service to recreate the dataset
 * on the remote on the next synchronization. Returning NO or leaving this property
 * nil will cause the client to delete the dataset locally.
 */
@property (nonatomic, copy) AWSCognitoDatasetDeletedHandler datasetDeletedHandler;

/**
 * A merged dataset handler. This handler will be called during a synchronization
 * when the remote service indicates that other datasets should be merged with this one.
 * Merged datasets should be fetched, their data overlayed locally and then removed.
 * Failing to implement this handler will result in merged datasets remaining on the
 * service indefinitely.
 */
@property (nonatomic, copy) AWSCognitoDatasetMergedHandler datasetMergedHandler;

/**
 * The number of times to attempt a synchronization before failing. Defaults to 
 * to the value on the AWSCognito client that opened this dataset.
 */
@property (nonatomic, assign) int synchronizeRetries;

/**
 * Sets a string object for the specified key in the dataset.
 */
- (void)setString:(NSString *) aString forKey:(NSString *) aKey;

/**
  * Returns the string associated with the specified key.
  */
- (NSString *)stringForKey:(NSString *) aKey;

/**
 * Synchronize local changes with remote changes on the service.  First it pulls down changes from the service
 * and attempts to overlay them on the local store.  Then it pushes any local updates to the service.  If at any
 * point there is a conflict, conflict resolution is invoked.  No changes are pushed to the service until
 * all conflicts are resolved.
 */
- (BFTask *)synchronize;

/**
 * Returns all of the records in the dataset. Will return deleted records.
 */
- (NSArray *)getAllRecords;

/**
 * Returns all the key value pairs in the dataset, ignore any deleted data.
 */
- (NSDictionary *)getAll;

/**
 * Remove a record from the dataset.
 */
- (void)removeObjectForKey:(NSString *) aKey;

/**
 * Returns the record associated with the specified key.
 */
- (AWSCognitoRecord *)recordForKey:(NSString *) aKey;

/**
 * Clear this dataset locally.  Dataset will not be removed from the service until the next synchronize call.
 */
- (void) clear;

/**
 * Returns the size in bytes for this dataset.
 */
- (long) size;

/**
 * Returns the size in bytes for the specified key.
 */
- (long) sizeForKey:(NSString *) aKey;

@end