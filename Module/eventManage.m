//
//  eventManage.m
//  View
//
//  Created by Kianna on 2025/9/21.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import "eventManage.h"


@implementation EventManage

- (instancetype)initWithCenter:(CourseEvent)event {
    self = [super init];
    if (self) {
        _event = event;
        _store = [[EKEventStore alloc] init];
    }
    return self;
}



// 获取用户的权限
- (BOOL)GetPermissionCalender {
    __block BOOL authorizationStatus = NO;
    if (@available(macOS 14.0, *)) {
        [self.store requestFullAccessToEventsWithCompletion: ^(BOOL granted, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        authorizationStatus = YES;
                    } else {
                        authorizationStatus = NO;
                    }
                });
        }];
    }

    return authorizationStatus;
}



// 这里会传入所有课程数据
- (NSMutableDictionary*)performExpor:(NSMutableArray*)Item {
    NSUInteger All = [Item count];
    NSUInteger count = 0;
    NSMutableDictionary *exportStatus = [@{@"Success" : @0, @"Fail" : @0} mutableCopy];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    EKEvent *event = [EKEvent eventWithEventStore:self.store];
    
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    for (NSValue * exportEvent in Item) {
        CourseEvent getEvent = {nil};
        [exportEvent getValue:&getEvent];
        NSString* displayTitle = [@[getEvent.title, getEvent.location, getEvent.teacher] componentsJoinedByString:@"/"];
        event.title = displayTitle;
        event.notes = getEvent.teacher;
        event.startDate = [formatter dateFromString:getEvent.starDate];
        event.endDate = [formatter dateFromString:getEvent.endDate];
        
        while(event.startDate <= event.endDate) {
            event.endDate = [event.endDate dateByAddingTimeInterval:60 * 45]; // 如果小于不报错，但是给你加45分钟
        }
        
        [event setCalendar:[self.store defaultCalendarForNewEvents]];
        NSError *saveError = nil;
        [self.store saveEvent:event span:EKSpanThisEvent commit:YES error:&saveError];
        
        if (saveError) {
            continue;
        }
        count += 1;
    }
    
    exportStatus[@"Success"] = @(count);
    exportStatus[@"Fail"] = @(All - count);
    
    return exportStatus;
}




- (NSMutableArray*)GetScheduleFormSystemCandle {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSMutableArray *schedule = [NSMutableArray array];
    NSArray<EKCalendar *> *calendars = [self.store calendarsForEntityType:EKEntityTypeEvent];  // 获取系统默认日历
    NSDate *startDate = [NSDate date];  // 从今天开始
    NSDate *endDate = [NSDate dateWithTimeIntervalSinceNow:60*60*24*30];
    NSPredicate *predicate = [self.store predicateForEventsWithStartDate:startDate endDate:endDate calendars:calendars];
    NSArray<EKEvent *> *events = [self.store eventsMatchingPredicate:predicate];
    
    for (EKEvent *event in events) {
        CourseEvent courseInfo = {nil};
        courseInfo.title = event.title;
        courseInfo.location = event.location;
        courseInfo.starDate = [formatter stringFromDate:event.startDate];
        courseInfo.endDate = [formatter stringFromDate:event.endDate];
        courseInfo.teacher = event.notes;
    }
    return schedule;
}

@end

