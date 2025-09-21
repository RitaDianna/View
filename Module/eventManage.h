//
//  eventManage.h
//  View
//
//  Created by Kianna on 2025/9/21.
//

#ifndef eventManage_h
#define eventManage_h

#import <Foundation/Foundation.h>
#import <EventKit/EKEventStore.h>
#import <EventKit/EKEvent.h>
#import <EventKit/EventKit.h>



NS_ASSUME_NONNULL_BEGIN

@class EKEventStore;

typedef struct Event {
    NSString *title;
    NSString *location;
    NSString *teacher;
    NSString *starDate;
    NSString *endDate;
}CourseEvent;


typedef enum EventManageSatus {
    EVENT_SUCCESS,    // 事件完全导出到日历
    EVENT_FAILE,      // 事件导出日历失败-全部未导出
    EVENT_INCOMPLETE  // 事件只有部分导出失败
}EventStatus;


@interface EventManage : NSObject

@property (nonatomic, assign) CourseEvent event;    // 事件的标题
@property (nonatomic, strong) EKEventStore *store;  // 日历存储事件

- (instancetype)initWithCenter:(CourseEvent)event;

// 询问用户授权访问
- (BOOL)GetPermissionCalender;    // 获得的是完整访问权限，方便同步时进行对比

- (NSMutableDictionary*)GetScheduleFormWebService:(NSString*)URL;

- (NSMutableDictionary*)GetScheduleFormJsonFie:(NSString*)Path;

- (NSMutableDictionary*)performExpor:(NSMutableArray*)Item;  // 将事件导入系统日历

- (NSMutableArray*)GetScheduleFormSystemCandle;

- (BOOL)ExportEvent;





@end

NS_ASSUME_NONNULL_END

#endif /* eventManage_h */
