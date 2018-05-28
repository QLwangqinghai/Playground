//
//  CObject.c
//  Playground
//
//  Created by wangqinghai on 2018/4/26.
//  Copyright © 2018年 wangqinghai. All rights reserved.
//

#import "CObject.h"
#import <dispatch/dispatch.h>


MRCMemory_t * _Nullable MRCMemoryAlloc(size_t contentSize) {
    assert(contentSize < SIZE_T_MAX - sizeof(MRCMemory_t));
    size_t size = contentSize + sizeof(MRCMemory_t);
    MRCMemory_t * obj = (MRCMemory_t *)malloc(size);
    memset(obj, 0, size);
    
    atomic_store(&(obj->refrenceCount), 1);
    return obj;
}
    
    
MRCMemory_t * _Nullable MRCMemoryRetain(MRCMemory_t * _Nonnull obj) {
    assert(obj);
    uint32_t refrenceCount = 0;
    uint32_t newRefrenceCount = 0;

    do {
        refrenceCount = atomic_load(&(obj->refrenceCount));
        newRefrenceCount = refrenceCount + 1;
    } while (!atomic_compare_exchange_weak(&(obj->refrenceCount), &refrenceCount, newRefrenceCount));
    printf("%p refrenceCount: %u\n", obj, refrenceCount + 1);
    return obj;
}

void MRCMemoryRelease(MRCMemory_t * _Nonnull obj) {
    assert(obj);
    uint32_t refrenceCount = 0;
    uint32_t newRefrenceCount = 0;

    do {
        refrenceCount = atomic_load(&(obj->refrenceCount));
        newRefrenceCount = refrenceCount - 1;
        if (refrenceCount == 0) {//dealloc obj
            printf("%p obj error\n", obj);
            abort();
        }
        if (refrenceCount == 1) {//dealloc obj
            printf("%p obj will dealloc\n", obj);
        }
    } while (!atomic_compare_exchange_weak(&(obj->refrenceCount), &refrenceCount, newRefrenceCount));
    
    if (newRefrenceCount == 0) {//dealloc obj
        printf("%p free\n", obj);
        free(obj);
        return;
    } else {
        printf("%p refrenceCount: %u\n", obj, refrenceCount - 1);
    }
}

void MRCMemoryTest(void) {
    printf("MRCMemoryTest \n\n\n\n");

    MRCMemory_t * obj = MRCMemoryAlloc(20);//引用次数1
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (int i=0; i<5; i++) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                for (int i=0; i<10000; i++) {
                    MRCMemoryRetain(obj);//引用次数+
                    MRCMemoryRelease(obj);//引用次数-
                }
            });
        }

        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            for (int i=0; i<10000; i++) {
                MRCMemoryRetain(obj);//引用次数+
            }

            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                for (int i=0; i<10000; i++) {
                    MRCMemoryRelease(obj);//引用次数-
                }
            });
        });


        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            MRCMemoryRelease(obj);
        });
    });

    
    
    MRCMemoryRetain(obj);//引用次数2
    MRCMemoryRelease(obj);//引用次数1

    MRCMemoryRetain(obj);//引用次数2
    MRCMemoryRelease(obj);//引用次数1

}



