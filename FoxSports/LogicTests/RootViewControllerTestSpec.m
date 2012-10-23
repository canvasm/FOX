#import "Kiwi.h"
#import "FSPRootViewController.h"
#import "FSPEventsViewController.h"
#import "CoreDataTestingHelper.h"
#import "FSPEvent.h"
#import "FSPEventDetailViewController.h"
#import "FSPNBADetailViewController.h"

SPEC_BEGIN(RootViewController)

describe(@"RootViewController", ^{
    __block FSPRootViewController *rootViewController;
    __block UIWindow *window;
    
    beforeEach(^{
        rootViewController = [[FSPRootViewController alloc] init];
        window = [[UIWindow alloc] init];
    });
    
    afterEach(^{
        [window resignKeyWindow];
        window = nil;
        rootViewController = nil;
    });

    it(@"should not be nil", ^{
        [rootViewController shouldNotBeNil];
    });
    
    it(@"should have all of its container views hooked up", ^{
        [rootViewController view];
        
        [rootViewController.channelsView shouldNotBeNil];
        [rootViewController.eventView shouldNotBeNil];
        [rootViewController.eventDetailView shouldNotBeNil];
    });
    
    
    //////////////////////////////////////////////////////////////
    //    Channel View Controller
    //////////////////////////////////////////////////////////////
    context(@"when setting the channel view controller", ^{
        __block UIViewController *channelViewController;
        
        beforeEach(^{
            channelViewController = [[UIViewController alloc] init];
            rootViewController.channelViewController = channelViewController;
        });
        
        afterEach(^{
            channelViewController = nil;
        });
        
        context(@"by adding a channel view controller", ^{
            
            it(@"should set its channelViewController property if it is a valid object being passed in.", ^{
                [rootViewController.channelViewController shouldNotBeNil];
            });
            
            it(@"should add the view controller's view after the root's view is loaded", ^{    
                [[theValue(rootViewController.isViewLoaded) should] beNo];
                [[theValue(channelViewController.isViewLoaded) should] beNo];
                
                [rootViewController view];
                
                [[theValue(channelViewController.isViewLoaded) should] beYes];
            });
            
            
            
            it(@"should add the channelsViewController's view to the appropriate container view", ^{
                rootViewController.channelViewController = channelViewController;
                
                [rootViewController view];
                
                UIView *channelViewParent = [channelViewController.view superview];
                [[rootViewController.channelsView should] beNonNil];
                [[channelViewParent should] equal:rootViewController.channelsView];
            });
            
            it(@"should call the appropriate sequence of view loading methods when adding the view", ^{
                [[[channelViewController should] receive] viewDidLoad];                
                [[theValue(channelViewController.isViewLoaded) should] beNo];
                
                window.rootViewController = rootViewController;
                [window makeKeyAndVisible];
                
                [[theValue(channelViewController.isViewLoaded) should] beYes];
                [[theValue(rootViewController.isViewLoaded) should] beYes];
            });
            
            context(@"it should allow you to switch view controllers after it has been added", ^{
                
                beforeEach(^{
                    window.rootViewController = rootViewController;
                    [window makeKeyAndVisible];
                });
                
                it(@"should return nil after being set to nil", ^{
                    rootViewController.channelViewController = nil;
                    [rootViewController.channelViewController shouldBeNil];
                });
                
                it(@"should remove the channel's view from its container view", ^{
                    UIView *view = channelViewController.view;
                    UIView *parent = [view superview];
                    [view shouldNotBeNil];
                    [parent shouldNotBeNil];
                    
                    rootViewController.channelViewController = nil;
                    
                    [view shouldNotBeNil];
                    UIView *newParent = [view superview];
                    [newParent shouldBeNil];
                });
                
                it(@"should call the appropriate sequence of methods when removing", ^{
                    [[channelViewController should] receive:@selector(viewWillDisappear:)];
                    [[channelViewController shouldEventually] receive:@selector(viewDidDisappear:)];
                    
                    rootViewController.channelViewController = nil;
                });
                
                it(@"should issue the correct loading sequence on the newly added view controller", ^{
                    UIViewController *newVC = [[UIViewController alloc] init];
                    [[[newVC should] receive] viewDidLoad];                
                    [[theValue(newVC.isViewLoaded) should] beNo];
                    [[theValue(rootViewController.isViewLoaded) should] beYes];
                    
                    rootViewController.channelViewController = newVC;
                    
                    [[theValue(channelViewController.isViewLoaded) should] beYes];
                    [[newVC.view superview] shouldNotBeNil];
                });
            });
        });
    });
    
    
    //////////////////////////////////////////////////////////////
    //    Event View Controller
    //////////////////////////////////////////////////////////////
    context(@"when setting the event view controller", ^{
        __block UIViewController *eventViewController;
        
        beforeEach(^{
            eventViewController = [[UIViewController alloc] init];
            rootViewController.eventViewController = eventViewController;
        });
        
        afterEach(^{
            eventViewController = nil;
        });
        
        context(@"by adding a event view controller", ^{
            
            it(@"should set its eventViewController property if it is a valid object being passed in.", ^{
                [rootViewController.eventViewController shouldNotBeNil];
            });
            
            it(@"should add the event controller's view after the root's view is loaded", ^{    
                [[theValue(rootViewController.isViewLoaded) should] beNo];
                [[theValue(eventViewController.isViewLoaded) should] beNo];
                
                [rootViewController view];
                
                [[theValue(eventViewController.isViewLoaded) should] beYes];
            });
            
            
            
            it(@"should add the eventViewController's view to the appropriate container view", ^{
                rootViewController.eventViewController = eventViewController;
                
                [rootViewController view];
                
                UIView *eventViewParent = [eventViewController.view superview];
                [[rootViewController.eventView should] beNonNil];
                [[eventViewParent should] equal:rootViewController.eventView];
            });
            
            it(@"should call the appropriate sequence of view loading methods when adding the view", ^{
                [[[eventViewController should] receive] viewDidLoad];                
                [[theValue(eventViewController.isViewLoaded) should] beNo];
                
                window.rootViewController = rootViewController;
                [window makeKeyAndVisible];
                
                [[theValue(eventViewController.isViewLoaded) should] beYes];
                [[theValue(rootViewController.isViewLoaded) should] beYes];
            });
            
            context(@"it should allow you to switch view controllers after it has been added", ^{
                
                beforeEach(^{
                    window.rootViewController = rootViewController;
                    [window makeKeyAndVisible];
                });
                
                it(@"should return nil after being set to nil", ^{
                    rootViewController.eventViewController = nil;
                    [rootViewController.eventViewController shouldBeNil];
                });
                
                it(@"should remove the event's view from its container view", ^{
                    UIView *view = eventViewController.view;
                    UIView *parent = [view superview];
                    [view shouldNotBeNil];
                    [parent shouldNotBeNil];
                    
                    rootViewController.eventViewController = nil;
                    
                    [view shouldNotBeNil];
                    UIView *newParent = [view superview];
                    [newParent shouldBeNil];
                });
                
                it(@"should call the appropriate sequence of methods when removing", ^{
                    [[eventViewController should] receive:@selector(viewWillDisappear:)];
                    [[eventViewController shouldEventually] receive:@selector(viewDidDisappear:)];
                    
                    rootViewController.eventViewController = nil;
                });
                
                it(@"should issue the correct loading sequence on the newly added view controller", ^{
                    UIViewController *newVC = [[UIViewController alloc] init];
                    [[[newVC should] receive] viewDidLoad];                
                    [[theValue(newVC.isViewLoaded) should] beNo];
                    [[theValue(rootViewController.isViewLoaded) should] beYes];
                    
                    rootViewController.eventViewController = newVC;
                    
                    [[theValue(eventViewController.isViewLoaded) should] beYes];
                    [[newVC.view superview] shouldNotBeNil];
                });
            });
        });
    });
    
    
    //////////////////////////////////////////////////////////////
    //    Detail View Controller
    //////////////////////////////////////////////////////////////
    context(@"when setting the detail view controller", ^{
        __block FSPEventDetailViewController *detailViewController;
        beforeEach(^{
            detailViewController = [[FSPEventDetailViewController alloc] init];
            rootViewController.detailViewController = detailViewController;
        });
        
        afterEach(^{
            detailViewController = nil;
        });
        
        context(@"by adding a detail view controller", ^{
            
            it(@"should set its detailViewController property if it is a valid object being passed in.", ^{
                [rootViewController.detailViewController shouldNotBeNil];
            });
            
            it(@"should add the detail controller's view after the root's view is loaded", ^{    
                [[theValue(rootViewController.isViewLoaded) should] beNo];
                [[theValue(detailViewController.isViewLoaded) should] beNo];
                
                [rootViewController view];
                
                [[theValue(detailViewController.isViewLoaded) should] beYes];
            });
            
            
            
            it(@"should add the eventViewController's view to the appropriate container view", ^{
                rootViewController.detailViewController = detailViewController;
                
                [rootViewController view];
                
                UIView *detailViewParent = [detailViewController.view superview];
                [[rootViewController.eventDetailView should] beNonNil];
                [[detailViewParent should] equal:rootViewController.eventDetailView];
            });
            
            it(@"should call the appropriate sequence of view loading methods when adding the view", ^{
                [[[detailViewController should] receive] viewDidLoad];                
                [[theValue(detailViewController.isViewLoaded) should] beNo];
                
                window.rootViewController = rootViewController;
                [window makeKeyAndVisible];
                
                [[theValue(detailViewController.isViewLoaded) should] beYes];
                [[theValue(rootViewController.isViewLoaded) should] beYes];
            });
            
            context(@"it should allow you to switch view controllers after it has been added", ^{
                
                beforeEach(^{
                    window.rootViewController = rootViewController;
                    [window makeKeyAndVisible];
                });
                
                it(@"should return nil after being set to nil", ^{
                    rootViewController.detailViewController = nil;
                    [rootViewController.detailViewController shouldBeNil];
                });
                
                it(@"should remove the details's view from its container view", ^{
                    UIView *view = detailViewController.view;
                    UIView *parent = [view superview];
                    [view shouldNotBeNil];
                    [parent shouldNotBeNil];
                    
                    rootViewController.detailViewController = nil;
                    
                    [view shouldNotBeNil];
                    UIView *newParent = [view superview];
                    [newParent shouldBeNil];
                });
                
                it(@"should call the appropriate sequence of methods when removing", ^{
                    [[detailViewController should] receive:@selector(viewWillDisappear:)];
                    [[detailViewController shouldEventually] receive:@selector(viewDidDisappear:)];
                    
                    rootViewController.detailViewController = nil;
                });
                
                it(@"should issue the correct loading sequence on the newly added view controller", ^{
                    FSPEventDetailViewController *newVC = [[FSPEventDetailViewController alloc] init];
                    [[[newVC should] receive] viewDidLoad];                
                    [[theValue(newVC.isViewLoaded) should] beNo];
                    [[theValue(rootViewController.isViewLoaded) should] beYes];
                    
                    rootViewController.detailViewController = newVC;
                    
                    [[theValue(detailViewController.isViewLoaded) should] beYes];
                    [[newVC.view superview] shouldNotBeNil];
                });
            });
        });
    });
    
    context(@"when responding to the event view controller's delegate methods", ^{
        __block CoreDataTestingHelper *coreDataHelper = nil;
        __block FSPEvent *unknownEvent;
        __block FSPEvent *NBAEvent;
    
        beforeAll(^{
            coreDataHelper = [[CoreDataTestingHelper alloc] init];
            unknownEvent = [NSEntityDescription insertNewObjectForEntityForName:@"FSPEvent" inManagedObjectContext:[coreDataHelper context]];
            unknownEvent.chipType = @"Unknown";
            
            NBAEvent = [NSEntityDescription insertNewObjectForEntityForName:@"FSPEvent" inManagedObjectContext:[coreDataHelper context]];
            NBAEvent.chipType = FSPNBAEventChipType;
        });
        
        it(@"should conform to the correct protocols", ^{
            [[rootViewController should] conformToProtocol:@protocol(FSPEventsViewControllerDelegate)];
        });
        
        it(@"should only swap out view controllers if the class of the view controller changes.", ^{
            FSPEventDetailViewController *basicEventDetailViewController = [[FSPEventDetailViewController alloc] init];
            rootViewController.detailViewController = basicEventDetailViewController;
            FSPEvent *thisEvent = [NSEntityDescription insertNewObjectForEntityForName:@"FSPEvent" inManagedObjectContext:[coreDataHelper context]];
            thisEvent.chipType = unknownEvent.chipType;
            
            [rootViewController eventsViewController:nil didSelectEvent:unknownEvent];
            [[rootViewController.detailViewController should] equal:basicEventDetailViewController];
        });
       
        it(@"should load the base event detail view controller for unknown chips", ^{
            [rootViewController eventsViewController:nil didSelectEvent:unknownEvent];
            [rootViewController.detailViewController shouldNotBeNil];
            [[rootViewController.detailViewController should] beKindOfClass:[FSPEventDetailViewController class]];
        });
        
        it(@"should load the NBA Detail View controller for nba chips", ^{
            [rootViewController eventsViewController:nil didSelectEvent:NBAEvent];
            [rootViewController.detailViewController shouldNotBeNil];
            [[rootViewController.detailViewController should] beKindOfClass:[FSPNBADetailViewController class]];
        });
        
        it(@"should remove the detail view controller if the event is nil", ^{
            [rootViewController eventsViewController:nil didSelectEvent:nil];
            [rootViewController.detailViewController shouldBeNil];
        });
    });
});

SPEC_END