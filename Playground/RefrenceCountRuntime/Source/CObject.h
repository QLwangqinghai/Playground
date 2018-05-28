//
//  CObject.h
//  Playground
//
//  Created by wangqinghai on 2018/4/26.
//  Copyright © 2018年 wangqinghai. All rights reserved.
//


#ifdef __cplusplus
extern "C" {
#endif


#ifndef CObject_h
#define CObject_h

#include <stdio.h>
#include <assert.h>
#include <limits.h>
#include <stdlib.h>
#include <string.h>
#include <stdatomic.h>

typedef struct {
    _Atomic(uint_fast32_t) refrenceCount;
    uint8_t content[0];
} MRCMemory_t;

MRCMemory_t * _Nullable MRCMemoryAlloc(size_t contentSize);
MRCMemory_t * _Nullable MRCMemoryRetain(MRCMemory_t * _Nonnull obj);
void MRCMemoryRelease(MRCMemory_t * _Nonnull obj);

void MRCMemoryTest(void);
    
    
#endif /* CObject_h */
    
#ifdef __cplusplus
}
#endif


