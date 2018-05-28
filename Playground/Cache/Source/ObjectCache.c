//
//  ObjectCache.c
//  Cache
//
//  Created by wangqinghai on 2018/5/23.
//  Copyright © 2018年 wangqinghai. All rights reserved.
//

#include "ObjectCache.h"
#include <limits.h>
#include <stdlib.h>
#include <string.h>

static uint64_t const CObjectCacheSizeOne = 0x100000000LLU;

CObjectCache_t * _Nullable CObjectCacheInit(uint32_t size) {
    if (0 == size) {
        return NULL;
    }
    
    size_t maxSize = (SIZE_MAX - sizeof(CObjectCache_t)) / sizeof(_Atomic(uintptr_t));
    if (maxSize < size) {
        return NULL;
    }
    
    size_t mSize = sizeof(CObjectCache_t) + sizeof(_Atomic(uintptr_t)) * (size_t)size;
    CObjectCache_t * cache = (CObjectCache_t *)malloc(mSize);
    
    if (NULL == cache) {
        return NULL;
    }
    memset(cache, 0, mSize);
    atomic_store(&(cache->bufferSize), size);
    return cache;
}


// add to last
int32_t CObjectCacheAdd(CObjectCache_t * _Nonnull cache, void * _Nonnull object) {
    assert(cache);
    assert(object);
    
    uint32_t bufferSize = atomic_load(&(cache->bufferSize));
    uint64_t infoValue = 0;
    uint64_t newInfoValue = 0;

    do {
        infoValue = atomic_load(&(cache->info));
        uint32_t size = (uint32_t)(infoValue >> 32);
        if (size >= bufferSize) {
            return CObjectCacheErrorFull;
        }
        newInfoValue = infoValue + CObjectCacheSizeOne;
    } while (!atomic_compare_exchange_weak(&(cache->info), &infoValue, newInfoValue));
    
    uint32_t size = (uint32_t)(newInfoValue >> 32);
    uint32_t offset = (uint32_t)newInfoValue;
    
    uint64_t lastIndex = ((uint64_t)size + (uint64_t)offset - 1) % (uint64_t)bufferSize;
    uintptr_t ptr = (uintptr_t)object;
    atomic_store(&(cache->buffer[lastIndex]), ptr);
    return 0;
}


//remove first
void * _Nullable CObjectCacheRemove(CObjectCache_t * _Nonnull cache) {
    assert(cache);
    uint32_t bufferSize = atomic_load(&(cache->bufferSize));
    uint64_t infoValue = 0;
    uint64_t newInfoValue = 0;
    uintptr_t ptr = 0;
    
    do {
        infoValue = atomic_load(&(cache->info));
        uint32_t size = (uint32_t)(infoValue >> 32);
        if (size == 0) {
            return NULL;
        }
        uint32_t offset = (uint32_t)infoValue;
//        uint64_t firstIndex = offset;
        uint64_t firstIndex = offset % (uint64_t)bufferSize;
        ptr = atomic_load(&(cache->buffer[firstIndex]));
        if (ptr == 0) {
            return NULL;
        }
        
        if (offset == bufferSize - 1) {
            offset = 0;
        } else {
            offset += 1;
        }
        size -= 1;
        newInfoValue = ((uint64_t)size << 32) | (uint64_t)offset;
    } while (!atomic_compare_exchange_weak(&(cache->info), &infoValue, newInfoValue));
    
    return (void *)ptr;
}


