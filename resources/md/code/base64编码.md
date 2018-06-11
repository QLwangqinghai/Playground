#Base64编码

## 关于Base64
- Base64只是一种编码方式，算不上加密。 
- Base64编码是从二进制到字符的过程，用于在一些不能传输二级制的环境下把二进制转成字符串。如JSON数据中、pem格式秘钥。
- 需要注意的是标准的Base64并不适合直接放在URL里传输，因为URL编码器会把标准Base64中的“/”、“+”、“=”字符进行转义。
- Base64要求把每三个字节的二进制数据转换为四个的ASCIL字符（每6位二进制数据转换成一个字符），也就是说，转换后的字符串理论上至少将要比原来的长1/3

## Base64Encode

> Swift Foundation NSData 中Base64Encode

```
    private static func base64EncodeBytes(_ bytes: [UInt8], options: Base64EncodingOptions = []) -> [UInt8] {
        var result = [UInt8]()
        result.reserveCapacity((bytes.count/3)*4)
        
        let lineOptions : (lineLength : Int, separator : [UInt8])? = {
            let lineLength: Int
            
            if options.contains(.lineLength64Characters) { lineLength = 64 }
            else if options.contains(.lineLength76Characters) { lineLength = 76 }
            else {
                return nil
            }
            
            var separator = [UInt8]()
            if options.contains(.endLineWithCarriageReturn) { separator.append(13) }
            if options.contains(.endLineWithLineFeed) { separator.append(10) }
            
            //if the kind of line ending to insert is not specified, the default line ending is Carriage Return + Line Feed.
            if separator.isEmpty { separator = [13,10] }
            
            return (lineLength,separator)
        }()
        
        var currentLineCount = 0
        let appendByteToResult : (UInt8) -> Void = {
            result.append($0)
            currentLineCount += 1
            if let options = lineOptions, currentLineCount == options.lineLength {
                result.append(contentsOf: options.separator)
                currentLineCount = 0
            }
        }
        
        var currentByte : UInt8 = 0
        
        for (index,value) in bytes.enumerated() {
            switch index%3 {
            case 0:
                currentByte = (value >> 2)
                appendByteToResult(NSData.base64EncodeByte(currentByte))
                currentByte = ((value << 6) >> 2)
            case 1:
                currentByte |= (value >> 4)
                appendByteToResult(NSData.base64EncodeByte(currentByte))
                currentByte = ((value << 4) >> 2)
            case 2:
                currentByte |= (value >> 6)
                appendByteToResult(NSData.base64EncodeByte(currentByte))
                currentByte = ((value << 2) >> 2)
                appendByteToResult(NSData.base64EncodeByte(currentByte))
            default:
                fatalError()
            }
        }
        //add padding
        switch bytes.count%3 {
        case 0: break //no padding needed
        case 1:
            appendByteToResult(NSData.base64EncodeByte(currentByte))
            appendByteToResult(self.base64Padding)
            appendByteToResult(self.base64Padding)
        case 2:
            appendByteToResult(NSData.base64EncodeByte(currentByte))
            appendByteToResult(self.base64Padding)
        default:
            fatalError()
        }
        return result
    }
```

## Base64Decode

> apple CoreFoundation CFURLAccess.c 中Base64Decode

```
static BOOL isBase64Digit(char c)
{
    return (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || (c == '+') || (c == '/');
}

static BOOL isBase64DigitOrEqualSign(char c)
{
    return isBase64Digit(c) || c == '=';
}

static UInt8 base64DigitValue(char c)
{
    if (c >= 'A' && c <= 'Z') {
		return c - 'A';
    } else if (c >= 'a' && c <= 'z') {
		return 26 + c - 'a';
    } else if (c >= '0' && c <= '9') {
		return 52 + c - '0';
    } else if (c == '+') {
		return 62;
    } else if (c == '/') {
		return 63;
    } else {
		return 0;
    }
}

static CFDataRef base64DecodeData(CFAllocatorRef alloc, CFDataRef data)
{
    const UInt8 *srcBuffer = CFDataGetBytePtr(data);
    CFIndex length = CFDataGetLength(data);
    UInt8 *dstBuffer = NULL;
    UInt8 staticDstBuffer[STATIC_BUFFER_SIZE];
	CFDataRef result = NULL;
	
    // base64 encoded data length must be multiple of 4
    if (length % 4 != 0) {
		goto done;
    }
	
    if (length > STATIC_BUFFER_SIZE) {
		dstBuffer = (UInt8*) malloc(length);
    } else {
		dstBuffer = staticDstBuffer;
    }
	
    CFIndex i;
    CFIndex j;
    for (i = 0, j = 0; i < length; i+=4) {
		if (!(isBase64Digit(srcBuffer[i]) &&
			  isBase64Digit(srcBuffer[i+1]) &&
			  isBase64DigitOrEqualSign(srcBuffer[i+2]) &&
			  isBase64DigitOrEqualSign(srcBuffer[i+3]))) {
			if (dstBuffer != staticDstBuffer) {
				free(dstBuffer);
			}
			return NULL;
		}
		
		dstBuffer[j++] = (base64DigitValue(srcBuffer[i]) << 2) + (base64DigitValue(srcBuffer[i+1]) >> 4);
		if (srcBuffer[i+2] != '=') {
			dstBuffer[j++] = ((base64DigitValue(srcBuffer[i+1]) & 0xf) << 4) + (base64DigitValue(srcBuffer[i+2]) >> 2);
		}
		if (srcBuffer[i+3] != '=') {
			dstBuffer[j++] = ((base64DigitValue(srcBuffer[i+2]) & 0x3) << 6) + (base64DigitValue(srcBuffer[i+3]));
		}
    }
    
    result = CFDataCreate(alloc, dstBuffer, j);
	
done:
    if (dstBuffer != staticDstBuffer) {
		free(dstBuffer);
    }
	
    return result;
}

```

