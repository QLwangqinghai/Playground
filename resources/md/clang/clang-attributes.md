#clang-attributes

## 文档

http://releases.llvm.org/3.8.0/tools/clang/docs/

## 常用的一些attributes

### final

```c
__attribute__((objc_subclassing_restricted))
@interface FinalClass : NSObject//此类将不能再被继承
@end
```

### objc\_requires\_super

```c
@interface ViewController : NSObject

- (void)viewDidLoad __attribute__((objc_requires_super));
@end
@implementation ViewController
- (void) viewDidLoad {
NSLog(@"viewDidLoad!");
}
@end

@interface MyViewController : ViewController
@end
@implementation MyViewController
- (void) viewDidLoad {
// Warning missing [super viewDidLoad]
} 
@end
```

### objc\_runtime\_name

用于 @interface 或 @protocol，将类或协议的名字在编译时指定成另一个：

```c
__attribute__((objc_runtime_name("SSObject")))
@interface Object : NSObject
@end
NSLog(@"%@", NSStringFromClass([Object class]));//SSObject
```

### ns\_returns\_retained


### ns\_returns\_not\_retained


### objc\_designated\_initializer

```c
NS_DESIGNATED_INITIALIZER

@interface NSString : NSObject <NSCopying, NSMutableCopying, NSSecureCoding>

#pragma mark *** String funnel methods ***

/* NSString primitives. A minimal subclass of NSString just needs to implement these two, along with an init method appropriate for that subclass. We also recommend overriding getCharacters:range: for performance.
 */
@property (readonly) NSUInteger length;
- (unichar)characterAtIndex:(NSUInteger)index;

/* The initializers available to subclasses. See further below for additional init methods.
*/
- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end

//怎样避免使用NS_DESIGNATED_INITIALIZER产生的警告
如果子类指定了新的初始化器，那么在这个初始化器内部必须调用父类的Designated Initializer。并且需要重写父类的Designated Initializer，将其指向子类新的初始化器。

@interface User: NSObject
- (instancetype)initWithName:(NSString *)name NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
@end

@implementation User
- (instancetype)init {
    return [self initWithName:@""];
}
- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        // do something
    }
    return self;
}
@end

```

### API_AVAILABLE

```c
@interface NSString (NSStringDeprecated)

- (BOOL)containsString:(NSString *)str API_AVAILABLE(macos(10.10), ios(8.0), watchos(2.0), tvos(9.0));

@end
```

### API_DEPRECATED

```c
@interface NSString (NSStringDeprecated)

- (nullable const char *)cString NS_RETURNS_INNER_POINTER API_DEPRECATED("Use -cStringUsingEncoding: instead", macos(10.0,10.4), ios(2.0,2.0), watchos(2.0,2.0), tvos(9.0,9.0));

@end
```

