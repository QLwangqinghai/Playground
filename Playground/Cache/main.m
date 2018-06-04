//
//  main.m
//  Cache
//
//  Created by wangqinghai on 2018/5/23.
//  Copyright © 2018年 wangqinghai. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <stdio.h>
#include <dispatch/dispatch.h>

#include "ObjectCache.h"

#include <limits.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>

static uint32_t const NumberItemCount = 300000;
static uint32_t const ThreadForAddCount = 100;
static uint32_t const CacheSize = 150000;
static uint32 const AddCountSizePerThread = NumberItemCount / ThreadForAddCount;
static uint32_t const ThreadForRemoveCount = 30;

static uint32_t const RemoveTimes = 8000;



@interface Tester : NSObject

@property (nonatomic, strong) NSMutableSet * set;

+ (void)add: (NSArray *)array;
+ (void)remove: (NSArray *)array;
+ (Tester *)share;
+ (void)check;
@end





typedef struct {
    uint32_t value;
} CNumber_t;
typedef struct {
    uint32_t index;
    uint32_t beginIndex;
    uint32_t length;
} ThreadContext;

static CNumber_t * buffer = NULL;
static CObjectCache_t * objectCache = NULL;
static dispatch_queue_t myQueue;


void * threadRun(void * context) {
    ThreadContext * range = (ThreadContext *)context;
    assert(range);
    
    pthread_t tid;
    tid = pthread_self();
    printf("thread: %u \n", (unsigned int) tid);
    
    uint32_t beginIndex = range->beginIndex;
    uint32_t endIndex = beginIndex + range->length;
    
    @autoreleasepool {
        NSMutableArray * successed = [NSMutableArray array];
        NSMutableArray * failured = [NSMutableArray array];
        
        for (uint32_t index=beginIndex; index<endIndex; index++) {
            CNumber_t * item = buffer + index;
            int result = CObjectCacheAdd(objectCache, item);
            if (0 == result) {
                printf("%C", 'A');

                [successed addObject:@(item->value)];
            } else {
                printf("%C", 'a');

                [failured addObject:@(item->value)];
            }
        }
        dispatch_async(myQueue, ^{
            [Tester add:successed];
        });
    }
    return NULL;
}

void * threadRunForRemove(void * context) {
    
    @autoreleasepool {
        NSMutableArray * successed = [NSMutableArray array];
        for (uint32_t index=0; index<RemoveTimes; index++) {
            CNumber_t * item = CObjectCacheRemove(objectCache);
            if (item) {
                printf("%C", 'R');
                [successed addObject:@(item->value)];
            } else {
                printf("%C", 'r');
            }
        }
        dispatch_async(myQueue, ^{
            [Tester remove:successed];
        });
    }
    return NULL;
}

static char * CommondExit = "exit";

void initGlobal() {
    myQueue = dispatch_queue_create("m", 0);
    int count = NumberItemCount;
    size_t size = sizeof(CNumber_t) * count;
    buffer = (CNumber_t *)malloc(size);
    assert(buffer);
    memset(buffer, 0, size);
    for (uint index=0; index<count; index ++) {
        (buffer + index)->value = index;
    }
    objectCache = CObjectCacheInit(CacheSize);
    assert(objectCache);
}

void testAdd(void);
void testRemove(void);


typedef BOOL(^HandleInputString)(NSString * string);
void ReadString(HandleInputString inputHandler);


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        initGlobal();
        sleep(5);
        testAdd();
        
//        dispatch_main();
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
            [Tester check];
        });
        
        
        ReadString(^BOOL(NSString *string) {
            if ([string isEqualToString:@"check"]) {
                dispatch_async(myQueue, ^{
                    [Tester check];
                });
            }
            return true;
        });
        
        
    }
    return 0;
}

void testAdd(void) {
    uint32_t threadCount = 0;

    while (threadCount < ThreadForAddCount) {
        int err;
        pthread_t t;
        ThreadContext * context = (ThreadContext *)malloc(sizeof(ThreadContext));
        assert(context);
        context->index = threadCount;
        context->beginIndex = threadCount * AddCountSizePerThread;
        context->length = AddCountSizePerThread;
        err = pthread_create(&t, NULL, threadRun, context);
        if (err != 0) {
            printf("can't create thread: %s\n", strerror(err));
            free(context);
        } else {
            threadCount ++;
        }
    }
}

void testRemove(void) {
    uint32_t threadCount = 0;
    while (threadCount < ThreadForRemoveCount) {
        int err;
        pthread_t t;
        err = pthread_create(&t, NULL, threadRunForRemove, NULL);
        if (err != 0) {
            printf("can't create thread: %s\n", strerror(err));
        } else {
            threadCount ++;
        }
    }
}

void ReadString(HandleInputString inputHandler) {
    char buffer[4096] = {};

    while (1) {
        scanf("%s", buffer);
        @autoreleasepool {
            NSString * string = [NSString stringWithCString:buffer encoding:(NSUTF8StringEncoding)];
            if (string && inputHandler) {
                if (false == inputHandler(string)) {
                    return;
                }
            }
        }
    }
}



@implementation Tester

- (instancetype)init {
    self = [super init];
    if (self) {
        _set = [NSMutableSet set];
//        _array = [NSMutableArray array];
    }
    return self;
}

+ (Tester *)share {
    static Tester * __share;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __share = [[Tester alloc] init];
    });
    return __share;
}

+ (void)check {
    Tester * share = [Tester share];
    NSLog(@"check begin:");
    NSLog(@"check share.array.count: %ld", share.set.count);

    int count = 0;
    while (count < 3) {
        void * item = CObjectCacheRemove(objectCache);
        CNumber_t * number = (CNumber_t *)item;
        if (number) {
            NSNumber * obj = @(number->value);
            if ([share.set containsObject:obj]) {
                [share.set removeObject:obj];
            } else {
                abort();
            }
        } else {
            count ++;
        }
    }
    
    if (share.set.count == 0) {
        NSLog(@"check success!");
    } else {
        NSLog(@"check error!");
    }
    
    
}

+ (void)add: (NSArray *)array {
    Tester * share = [Tester share];
    
    NSSet * set = [NSSet setWithArray:array];
    if (set.count != array.count) {
        abort();
    }
    NSInteger c0 = share.set.count;
    [share.set addObjectsFromArray:array];
    NSInteger c1 = share.set.count;

    if (c1 - c0 != array.count) {
        abort();
    }
}


+ (void)remove: (NSArray *)array {
    Tester * share = [Tester share];    
    for (id obj in array) {
        if ([share.set containsObject:obj]) {
            [share.set removeObject:obj];
        } else {
            abort();
        }
    }
}


@end


