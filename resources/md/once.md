# Once

## 题外话
OC 、C++、C、Swift 全局变量初始化时机。


##纯C环境下
### pthread_once

```c
static void * shareApplicationInfo;

//初始化函数
void initApplicationInfo() {
    shareApplicationInfo = malloc(sizeof(1));
}

void * getApplicationInfo() {
    static pthread_once_t token = PTHREAD_ONCE_INIT;
    pthread_once(&token,&initApplicationInfo);
    return shareApplicationInfo;
}
```

### dispatch_once 需要引libdispatch库

- block写法

```Objective-C
NSObject * getOCApplicationInfo() {
    static NSObject * __shareOCApplicationInfo;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __shareOCApplicationInfo = [[NSObject alloc] init];
    });
    return __shareOCApplicationInfo;
}
```

- dispatch 函数指针写法 跟pthread_once用法相似

```Objective-C
static NSObject * __shareOCApplicationInfo2;
void initOC2ApplicationInfo(void * context) {
    __shareOCApplicationInfo2 = [[NSObject alloc] init];
}
NSObject * getOC2ApplicationInfo() {
    static dispatch_once_t onceToken;
    dispatch_once_f(&onceToken, NULL, initOC2ApplicationInfo);
    return __shareOCApplicationInfo2;
}
```

## OC

```
@interface FileManager
- (instancetype)init NS_UNAVAILABLE;
@end
@implementation FileManager

- (instancetype)init {
    return nil;
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
    }
    return self;
}

+ (instancetype)share {
    static FileManager * ___share;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ___share = [[[self class] alloc] initPrivate];
    });
    return ___share;
}
@end

```

## swift
- 最常用写法

```swift
public final class MySwiftManager {
    var some: String? = ""
    
    fileprivate init() {}
}

public let mySwiftManager: MySwiftManager = MySwiftManager()
```
- 兼容OC的写法

```swift
public final class MySwiftManager2: NSObject {
    var some: String? = ""
    
    fileprivate override init() {
        super.init()
    }
    @objc public static let share: MySwiftManager2 = MySwiftManager2()
}

```
- 可以在初始化完成后做一些事的写法

```swift
public final class MySwiftManager {
    var some: String? = ""
    
    fileprivate init() {}
}

public let mySwiftManager: MySwiftManager = {
    let value = MySwiftManager()
    value.some = "mySwiftManager"
    return value
}()
```

## Tips
1、 尽量让单例的init方法私有， 不要暴露出去，除非你确定需要这么做

2、 单例尽量不允许继承， 用final 修饰类

3、 关于命名：单例用share(我们一般是用的这种模式)，  default 默认的实例， 我们可以自已再初始化实例。（比如：UIApplication.shared , NotificationCenter.default）