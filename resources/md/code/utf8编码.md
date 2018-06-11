# UTF8编码

## 背景
> 1. NSString -[NSString length] API局限性，官方文档是这么描述的：“The number of UTF-16 code units in the receiver.”, 显然不是字符个数。
> 2. iOS开发过程中经常会遇到字符串长度限制，字符串字节限制等需求，往往做的不尽如人意。这里简单介绍下utf8编码规则。
> 3. 有不少开发遇到了字符串截取crash的问题。
> 4. Swift语言中引入了unicode字符支持，详见 String.UnicodeScalarView

## 简介
> UTF-8（8-bit Unicode Transformation Format）是一种针对Unicode的可变长度字符编码，又称万国码，由Ken Thompson于1992年创建。现在已经标准化为RFC 3629。UTF-8用1到6个字节编码Unicode字符。用在网页上可以统一页面显示中文简体繁体及其它语言（如英文，日文，韩文）。(节选自百度百科)

## 编码规则
>
     1字节 0xxxxxxx
     2字节 110xxxxx 10xxxxxx
     3字节 1110xxxx 10xxxxxx 10xxxxxx
     4字节 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
     5字节 111110xx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
     6字节 1111110x 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
    
## 实例代码
- 字符串校验、字符个数

```c
_Bool CStringScalarInit(CStringScalar * _Nonnull scalar, uint32_t code) {
    uint32_t flag = 0x80000000;
    if ((code & flag) == flag) {
        return 0;
    } else {
        scalar->bigchar = code;
        return 1;
    }
}

//返回 CStringScalar 个数
_Bool CStringCheckUtf8Byte(const uint8_t * _Nonnull utf8StringByte, size_t length, size_t * _Nullable scalarCountRef, size_t * _Nullable validByteCountRef) {
    size_t index = 0;
    size_t scalarCount = 0;
    uint8_t charByte = 0;
    int64_t lastValidByteIndex = -1;
    
    while (index < length) {
        charByte = *(utf8StringByte + index);
        
        if ((charByte & 0x80) == 0) {//单字节
            scalarCount += 1;
            index++;
            if (charByte != 0) {
                lastValidByteIndex = index;
            }
        } else {//多字节
            uint32_t uchar = 0;
            int scalarByteCount = 0;//字节个数
            while ((charByte & 0x80) != 0) {//获取字节个数
                charByte <<= 1;
                scalarByteCount++;
            }
            if ((scalarByteCount < 2) || (scalarByteCount > 6)) {//字节字数合法性校验
                if (scalarCountRef) {
                    *scalarCountRef = 0;
                }
                
                return 0;
            }
            scalarByteCount -= 1; //减去自身占的一个字节
            index++;
            
            if (length - index < scalarByteCount) {
                if (scalarCountRef) {
                    *scalarCountRef = 0;
                }
                if (validByteCountRef) {
                    *validByteCountRef = 0;
                }
                return 0;
            }
            if (scalarByteCount == 2) {
                uchar += (uint32_t)(charByte & 0x3F);
            } else if (scalarByteCount == 3) {
                uchar += (uint32_t)(charByte & 0x1F);
            } else if (scalarByteCount == 4) {
                uchar += (uint32_t)(charByte & 0xF);
            } else if (scalarByteCount == 5) {
                uchar += (uint32_t)(charByte & 0x7);
            } else if (scalarByteCount == 6) {
                uchar += (uint32_t)(charByte & 0x3);
            }
            
            int64_t tmpValidByteIndex = -1;
            while (scalarByteCount > 0) {
                charByte = *(utf8StringByte + index);
                if ((charByte & 0xC0) != 0x80) {
                    if (scalarCountRef) {
                        *scalarCountRef = 0;
                    }
                    if (validByteCountRef) {
                        *validByteCountRef = 0;
                    }
                    return 0;
                }
                scalarByteCount--;
                uchar = uchar << 6;
                uchar += (charByte & 0x3F);
                if (uchar != 0) {
                    tmpValidByteIndex = index;
                }
                index++;
            }
            if (tmpValidByteIndex >= 0) {
                lastValidByteIndex = tmpValidByteIndex;
            }
            scalarCount += 1;
        }
    }
    if (scalarCountRef) {
        *scalarCountRef = scalarCount;
    }
    if (validByteCountRef) {
        *validByteCountRef = lastValidByteIndex + 1;
    }
    return 1;
}
_Bool CStringCheckUtf8String(const char * _Nonnull utf8String, size_t * _Nullable scalarCount, size_t * _Nullable validByteCountRef) {
    size_t length = strlen(utf8String);
    return CStringCheckUtf8StringWithLength(utf8String, length, scalarCount, validByteCountRef);
}
_Bool CStringCheckUtf8StringWithLength(const char * _Nonnull utf8String, size_t length, size_t * _Nullable scalarCount, size_t * _Nullable validByteCountRef) {
    return CStringCheckUtf8Byte((const uint8_t *)utf8String, length, scalarCount, validByteCountRef);
}
```

- Swift OC 对比

```
let str0: NSString = "😂"
let str1: NSString = "h"
let str2: NSString = "人"

print("str0.length", str0.length)
print("str1.length", str1.length)
print("str2.length", str2.length)

let swiftString = "😂"
print("swiftString.unicodeScalars.count", swiftString.unicodeScalars.count)
print("swiftString.utf8.count", swiftString.utf8.count)
print("swiftString.utf16.count", swiftString.utf16.count)
```
输出结果 
>
str0.length 2
str1.length 1
str2.length 1
swiftString.unicodeScalars.count 1
swiftString.utf8.count 4
swiftString.utf16.count 2

## 疑问为什么不用每个字节最高位标识字节的连续性? 这个没闹明白！