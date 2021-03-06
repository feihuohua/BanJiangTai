//
//  ZGEventBinding.m
//  HelloZhuge
//
//  Created by Amanda Canyon on 7/22/14.
//  Copyright (c) 2014 Zhuge. All rights reserved.
//

#import "Zhuge.h"
#import "ZGEventBinding.h"
#import "ZGUIControlBinding.h"
#import "ZGUITableViewBinding.h"
#import "ZGLog.h"
@implementation ZGEventBinding

+ (ZGEventBinding *)bindingWithJSONObject:(NSDictionary *)object
{
    if (object == nil) {
        ZhugeDebug(@"must supply an JSON object to initialize from");
        return nil;
    }
    NSString *bindingType = object[@"event_type"];
    Class klass = [self subclassFromString:bindingType];
    return [klass bindingWithJSONObject:object];
}

+ (ZGEventBinding *)bindngWithJSONObject:(NSDictionary *)object
{
    return [self bindingWithJSONObject:object];
}

+ (Class)subclassFromString:(NSString *)bindingType
{
    NSDictionary *classTypeMap = @{
                                   [ZGUIControlBinding typeName] : [ZGUIControlBinding class],
                                   [ZGUITableViewBinding typeName] : [ZGUITableViewBinding class]
                                   };
    return[classTypeMap valueForKey:bindingType] ?: [ZGUIControlBinding class];
}

+ (void)track:(NSString *)event properties:(NSDictionary *)properties
{
    NSMutableDictionary *bindingProperties = [[NSMutableDictionary alloc] initWithObjectsAndKeys: @YES, @"$from_binding", nil];
    [bindingProperties addEntriesFromDictionary:properties];
    [[Zhuge sharedInstance] track:event properties:bindingProperties];
}

- (instancetype)initWithEventName:(NSString *)eventName onPath:(NSString *)path
{
    if (self = [super init]) {
        self.eventName = eventName;
        self.path = [[ZGObjectSelector alloc] initWithString:path];
        self.name = [[NSUUID UUID] UUIDString];
        self.running = NO;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Event Binding base class: '%@' for '%@'", [self eventName], [self path]];
}

#pragma mark -- Method stubs

+ (NSString *)typeName
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)execute
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)stop
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark -- NSCoder

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSString *path = [aDecoder decodeObjectForKey:@"path"];
    NSString *eventName = [aDecoder decodeObjectForKey:@"eventName"];
    if (self = [self initWithEventName:eventName onPath:path]) {
        self.ID = [[aDecoder decodeObjectForKey:@"ID"] unsignedLongValue];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.swizzleClass = NSClassFromString([aDecoder decodeObjectForKey:@"swizzleClass"]);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:@(_ID) forKey:@"ID"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_path.string forKey:@"path"];
    [aCoder encodeObject:_eventName forKey:@"eventName"];
    [aCoder encodeObject:NSStringFromClass(_swizzleClass) forKey:@"swizzleClass"];
}

@end
