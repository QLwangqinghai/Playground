# dosomething-before-main
## 背景

在iOS解耦过程中一般会采用一个routor中间件解决跨模块调用、数据跨模块共享等问题。

### 方法一： routor 根据配置动态调用方法

举例：

url: app://Service/User/Login?source=xx&
routor 根据配置文件查到响应的类 LoginManager, 方法 showLoginVC
runtime 加载 LoginManager 类， 调用showLoginVC方法

缺点：1、安全性； 2、应用启动耗时增加（读取文件、数据解析）； 3、传参的复杂性

### 方法二： 引用启动后调用各个模块的方法去注册事件

举例：
应用启动后在Appdelegate 中调用各个模块的注册事件api

url: app://Service/User/Login  
routor 从字典里找出事件对应的响应者， 事件分发到响应者

缺点：1、无法真正热插拔， 需要在Appdelegate中添加各个模块头文件， 调用各个模块的注册事件的方法

## 目的
解决方法二中热插拔的问题, 应用启动后由各个模块自己去注册响应事件，Appdelege中不再引入头文件

## 方法

### +load方法

```c
@interface ModuleIniter : NSObject

@end
@implementation ModuleIniter
+ (void)load {
    // do some thing
}

@end
```

缺陷：此时Objc 运行时未加载完成，调用Objc代码有风险

### clang黑魔法 __attribute__((constructor))

用法 ：c 函数前添加， 函数名无特殊要求

```c
__attribute__((constructor(1001)))
static void OnModuleLoadEnd(void) {
	//do some thing
}
```

constructor 参数为优先级， 数字越小优先级越高， 0-100 编译器预留
调用时机 在 oc class +load 之后，main 函数执行之前

### C++全局对象


```c++
typedef void(^MuduleBlock)();

namespace Mudule {
    
    class MuduleManager {
    public:
        MuduleManager(MuduleBlock block) {
            if (block) {
                block();
            }
        }
        ~MuduleManager() {
            
        }
    };
};

static Mudule::MuduleManager module = Mudule::MuduleManager(^{
   //do some thing
});
```

