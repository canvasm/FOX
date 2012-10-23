//
//  FPSStoryProcessingOperation.m
//  FoxSports
//
//  Created by Laura Savino on 3/28/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPStoryProcessingOperation.h"
#import "FSPEvent.h"
#import "FSPNewsStory.h"
#import "FSPStoryValidator.h"
#import "FSPCoreDataManager.h"
#import "FSPCoreDataManager.h"

@interface FSPStoryProcessingOperation () {}

@property (nonatomic, strong) NSManagedObjectID *eventMOID;
@property (nonatomic, strong) NSDictionary *storyDictionary;
@property (nonatomic, assign) FSPStoryType storyType;


@end

@implementation FSPStoryProcessingOperation
@synthesize eventMOID = _eventMOID;
@synthesize storyDictionary = _storyDictionary;
@synthesize storyType = _storyType;

- (id)initWithEventId:(NSManagedObjectID *)eventId storyDictionary:(NSDictionary *)storyDictionary storyType:(FSPStoryType)storyType
              context:(NSManagedObjectContext *)context
{
    self = [super init];
    if(!self) return nil;

    self.storyType = storyType;
    self.eventMOID = eventId;
    self.storyDictionary = storyDictionary; 
    return self;
}

- (void)main
{
    if (self.isCancelled)
        return;
    
#ifdef DEBUG
    NSLog(@"This is no longer used as we don't make FSPStory objects in CoreData. We just make FSPNewsStory that live transiently");
    return;
#endif
    
    if (self.storyDictionary) {
        [FSPCoreDataManager.sharedManager.GUIObjectContext/*self.managedObjectContext*/ performBlockAndWait:^{
            FSPEvent *event = (FSPEvent *)[FSPCoreDataManager.sharedManager.GUIObjectContext existingObjectWithID:self.eventMOID error:nil];
            FSPStory *story = nil;
            
            if (!event)
                return;
            
            if(self.storyType == FSPStoryTypeRecap)
                story = event.recapStory;
            else if(self.storyType == FSPStoryTypePreview)
                story = event.previewStory;
            
            FSPStoryValidator *storyValidator = [[FSPStoryValidator alloc] init];
            NSDictionary *validatedDictionary = [storyValidator validateDictionary:self.storyDictionary error:nil];
            
            if(!story)
            {
                //Only insert new object if the object can be populated with a valid dictionary
                if(validatedDictionary)
                {
                    story = [NSEntityDescription insertNewObjectForEntityForName:@"FSPStory"
                                                          inManagedObjectContext:FSPCoreDataManager.sharedManager.GUIObjectContext];
                    story.eventId = event.uniqueIdentifier;
                }
                if(self.storyType == FSPStoryTypeRecap)
                    event.recapStory = story;
                else if(self.storyType == FSPStoryTypePreview)
                    event.previewStory = story;
            }
            
            [story populateWithDictionary:validatedDictionary];
        }];
    }
}

@end
