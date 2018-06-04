#C11标准 原子操作

## C11标准简介

```
C11标准是 ISO/IEC 9899:2011 - Information technology -- Programming languages -- C 的简称 [1]  ，曾用名为C1X。

C11标准是C语言标准的第三版，前一个标准版本是C99标准。2011年12月8日，国际标准化组织（ISO）和国际电工委员会（IEC） 旗下的C语言标准委员会（ISO/IEC JTC1/SC22/WG14）正式发布了C11标准 。
C11标准的最终定稿的草案是免费开放的，为N1570，但是正式标准文件需要198瑞士法郎。

当前，支持此标准的主流C++语言编译器有：GCC、Clang、Intel C++ Compiler等。

```

```
C11引入 原子操作
```

以上内容选自于百度百科 [C11](https://baike.baidu.com/item/C11)



## 头文件

```c
#include <stdatomic.h>
```

## 数据类型

```c
#ifdef __cplusplus
typedef _Atomic(bool)               atomic_bool;
#else
typedef _Atomic(_Bool)              atomic_bool;
#endif
typedef _Atomic(char)               atomic_char;
typedef _Atomic(signed char)        atomic_schar;
typedef _Atomic(unsigned char)      atomic_uchar;
typedef _Atomic(short)              atomic_short;
typedef _Atomic(unsigned short)     atomic_ushort;
typedef _Atomic(int)                atomic_int;
typedef _Atomic(unsigned int)       atomic_uint;
typedef _Atomic(long)               atomic_long;
typedef _Atomic(unsigned long)      atomic_ulong;
typedef _Atomic(long long)          atomic_llong;
typedef _Atomic(unsigned long long) atomic_ullong;
typedef _Atomic(uint_least16_t)     atomic_char16_t;
typedef _Atomic(uint_least32_t)     atomic_char32_t;
typedef _Atomic(wchar_t)            atomic_wchar_t;
typedef _Atomic(int_least8_t)       atomic_int_least8_t;
typedef _Atomic(uint_least8_t)      atomic_uint_least8_t;
typedef _Atomic(int_least16_t)      atomic_int_least16_t;
typedef _Atomic(uint_least16_t)     atomic_uint_least16_t;
typedef _Atomic(int_least32_t)      atomic_int_least32_t;
typedef _Atomic(uint_least32_t)     atomic_uint_least32_t;
typedef _Atomic(int_least64_t)      atomic_int_least64_t;
typedef _Atomic(uint_least64_t)     atomic_uint_least64_t;
typedef _Atomic(int_fast8_t)        atomic_int_fast8_t;
typedef _Atomic(uint_fast8_t)       atomic_uint_fast8_t;
typedef _Atomic(int_fast16_t)       atomic_int_fast16_t;
typedef _Atomic(uint_fast16_t)      atomic_uint_fast16_t;
typedef _Atomic(int_fast32_t)       atomic_int_fast32_t;
typedef _Atomic(uint_fast32_t)      atomic_uint_fast32_t;
typedef _Atomic(int_fast64_t)       atomic_int_fast64_t;
typedef _Atomic(uint_fast64_t)      atomic_uint_fast64_t;
typedef _Atomic(intptr_t)           atomic_intptr_t;
typedef _Atomic(uintptr_t)          atomic_uintptr_t;
typedef _Atomic(size_t)             atomic_size_t;
typedef _Atomic(ptrdiff_t)          atomic_ptrdiff_t;
typedef _Atomic(intmax_t)           atomic_intmax_t;
typedef _Atomic(uintmax_t)          atomic_uintmax_t;
```

## API

```c
#define atomic_store(object, desired) __c11_atomic_store(object, desired, __ATOMIC_SEQ_CST)
#define atomic_store_explicit __c11_atomic_store

#define atomic_load(object) __c11_atomic_load(object, __ATOMIC_SEQ_CST)
#define atomic_load_explicit __c11_atomic_load

#define atomic_exchange(object, desired) __c11_atomic_exchange(object, desired, __ATOMIC_SEQ_CST)
#define atomic_exchange_explicit __c11_atomic_exchange

#define atomic_compare_exchange_strong(object, expected, desired) __c11_atomic_compare_exchange_strong(object, expected, desired, __ATOMIC_SEQ_CST, __ATOMIC_SEQ_CST)
#define atomic_compare_exchange_strong_explicit __c11_atomic_compare_exchange_strong

#define atomic_compare_exchange_weak(object, expected, desired) __c11_atomic_compare_exchange_weak(object, expected, desired, __ATOMIC_SEQ_CST, __ATOMIC_SEQ_CST)
#define atomic_compare_exchange_weak_explicit __c11_atomic_compare_exchange_weak

#define atomic_fetch_add(object, operand) __c11_atomic_fetch_add(object, operand, __ATOMIC_SEQ_CST)
#define atomic_fetch_add_explicit __c11_atomic_fetch_add

#define atomic_fetch_sub(object, operand) __c11_atomic_fetch_sub(object, operand, __ATOMIC_SEQ_CST)
#define atomic_fetch_sub_explicit __c11_atomic_fetch_sub

#define atomic_fetch_or(object, operand) __c11_atomic_fetch_or(object, operand, __ATOMIC_SEQ_CST)
#define atomic_fetch_or_explicit __c11_atomic_fetch_or

#define atomic_fetch_xor(object, operand) __c11_atomic_fetch_xor(object, operand, __ATOMIC_SEQ_CST)
#define atomic_fetch_xor_explicit __c11_atomic_fetch_xor

#define atomic_fetch_and(object, operand) __c11_atomic_fetch_and(object, operand, __ATOMIC_SEQ_CST)
#define atomic_fetch_and_explicit __c11_atomic_fetch_and

```

## 经典应用

CoreFoundation retain release

```C
// For "tryR==true", a return of NULL means "failed".
static CFTypeRef _CFRetain(CFTypeRef cf, Boolean tryR) {
#if DEPLOYMENT_RUNTIME_SWIFT
    // We always call through to swift_retain, since all CFTypeRefs are at least _NSCFType objects
    swift_retain((void *)cf);
    return cf;
#else
    // It's important to load a 64-bit value from cfinfo when running in 64 bit - if we only fetch 32 bits then it's possible we did not atomically fetch the deallocating/deallocated flag and the retain count together (19256102). Therefore it is after this load that we check the deallocating/deallocated flag and the const-ness.
    __CFInfoType info = atomic_load(&(((CFRuntimeBase *)cf)->_cfinfoa));
    if (info & RC_CUSTOM_RC_BIT) {
        if (tryR) return NULL;
        CFTypeID typeID = __CFTypeIDFromInfo(info);
        CFRuntimeClass *cfClass = __CFRuntimeClassTable[typeID];
        uint32_t (*refcount)(intptr_t, CFTypeRef) = cfClass->refcount;
        if (!refcount || !(cfClass->version & _kCFRuntimeCustomRefCount) || __CFLowRCFromInfo(info) != 0xFF) {
            CRSetCrashLogMessage("Detected bogus CFTypeRef");
            HALT; // bogus object
        }
#if __LP64__
        // Custom RC always has high bits all set
        if (__CFHighRCFromInfo(info) != 0xFFFFFFFFU) {
            CRSetCrashLogMessage("Detected bogus CFTypeRef");
            HALT; // bogus object
        }
#endif
        refcount(+1, cf);
    } else {
#if __LP64__
        __CFInfoType newInfo;
        do {
            if (__builtin_expect(tryR && (info & (RC_DEALLOCATING_BIT | RC_DEALLOCATED_BIT)), false)) {
                // This object is marked for deallocation
                return NULL;
            }
            
            if (__CFHighRCFromInfo(info) == 0) {
                // Constant CFTypeRef
                return cf;
            }
            
            if (__builtin_expect(__CFHighRCFromInfo(info) == ~0U, false)) {
                // Overflow will occur upon add. Turn into constant CFTypeRef (rc == 0). Retain will do nothing, but neither will release.
                __CFBitfield64SetValue(newInfo, HIGH_RC_END, HIGH_RC_START, 0);
            }
            
            // Increment the retain count and swap into place
            newInfo = info + RC_INCREMENT;
        } while (!atomic_compare_exchange_strong(&(((CFRuntimeBase *)cf)->_cfinfoa), &info, newInfo));
#else
        CFIndex rc = __CFLowRCFromInfo(info);
        if (__builtin_expect(0 == rc, 0)) return cf;    // Constant CFTypeRef
        bool success = 0;
        do {
            // if already deallocating, don't allow new retain
            if (tryR && (info & RC_DEALLOCATING_BIT)) return NULL;
            __CFInfoType newInfo = info;
            newInfo += (1 << LOW_RC_START);
            rc = __CFLowRCFromInfo(newInfo);
            if (__builtin_expect((rc & 0x7f) == 0, 0)) {
                /* Roll over another bit to the external ref count
                 Real ref count = low 7 bits of retain count in info  + external ref count << 6
                 Bit 8 of low bits indicates that external ref count is in use.
                 External ref count is shifted by 6 rather than 7 so that we can set the low
                 bits to to 1100 0000 rather than 1000 0000.
                 This prevents needing to access the external ref count for successive retains and releases
                 when the composite retain count is right around a multiple of 1 << 7.
                 */
                newInfo = info;
                __CFBitfieldSetValue(newInfo, LOW_RC_END, LOW_RC_START, ((1 << 7) | (1 << 6)));
                __CFLock(&__CFRuntimeExternRefCountTableLock);
                success = atomic_compare_exchange_strong(&(((CFRuntimeBase *)cf)->_cfinfoa), &info, newInfo);
                if (__builtin_expect(success, 1)) {
                    __CFDoExternRefOperation(350, (id)cf);
                }
                __CFUnlock(&__CFRuntimeExternRefCountTableLock);
            } else {
                success = atomic_compare_exchange_strong(&(((CFRuntimeBase *)cf)->_cfinfoa), &info, newInfo);
            }
        } while (__builtin_expect(!success, 0));
#endif
    }
    if (__builtin_expect(__CFOASafe, 0)) {
	__CFRecordAllocationEvent(__kCFRetainEvent, (void *)cf, 0, CFGetRetainCount(cf), NULL);
    }
    return cf;
#endif
}
```

### 玩转_Atomic系列

- [引用计数](https://github.com/QLwangqinghai/Playground/Playground/RefrenceCountRuntime/Source)

```C
Playground:
CObject.h、CObject.c
```

- [无锁缓存池](https://github.com/QLwangqinghai/Playground/Playground/Cache/Source)

```C
Playground:
ObjectCache.h、ObjectCache.c
```







