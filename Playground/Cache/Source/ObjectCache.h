//
//  ObjectCache.h
//  Cache
//
//  Created by wangqinghai on 2018/5/23.
//  Copyright © 2018年 wangqinghai. All rights reserved.
//

#ifndef ObjectCache_h
#define ObjectCache_h

#include <stdio.h>
#include <stdatomic.h>
#include <assert.h>

static int32_t const CObjectCacheErrorFull = -1;
static int32_t const CObjectCacheErrorBusy = -2;
static int32_t const CObjectCacheErrorEmpty = -3;


typedef struct _CObjectCache {
    _Atomic(uint_fast32_t) bufferSize;
    _Atomic(uint_fast64_t) info;
    void * _Nonnull content;
    _Atomic(uintptr_t) buffer[0];
} CObjectCache_t;

CObjectCache_t * _Nullable CObjectCacheInit(uint32_t size);

//return 0 for success
int32_t CObjectCacheAdd(CObjectCache_t * _Nonnull cache, void * _Nonnull object);

void * _Nullable CObjectCacheRemove(CObjectCache_t * _Nonnull cache);

void CObjectCacheLog(CObjectCache_t * _Nonnull cache);


#endif /* ObjectCache_h */
