## why

开发工程中为什么要用Strong-Weak Dance，明显的retain release操作， 增加了运行时开销，这么做的好处是什么？

## 经典案例
AFNetworkReachabilityManager.m文件中， 这里摘了几个重要函数 做简要分析

```c
- (void)startMonitoring {
    [self stopMonitoring];

    if (!self.networkReachability) {
        return;
    }
   //创建了callback
   __weak __typeof(self)weakSelf = self;
    AFNetworkReachabilityStatusBlock callback = ^(AFNetworkReachabilityStatus status) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;

        strongSelf.networkReachabilityStatus = status;

//这里设想一下， 如果是strongSelf 作为参数去调用别的函数，且函数规定参数必须非空，否则abort(), 这里需要怎么做
        if (strongSelf.networkReachabilityStatusBlock) {//判断非空，既然是对networkReachabilityStatusBlock判空， 同时也对 strongSelf进行了判空
            strongSelf.networkReachabilityStatusBlock(status);
        }

    };*

//SCNetworkReachability 的回调block
    SCNetworkReachabilityContext context = {0, (__bridge void *)callback, AFNetworkReachabilityRetainCallback, AFNetworkReachabilityReleaseCallback, NULL};
    SCNetworkReachabilitySetCallback(self.networkReachability, AFNetworkReachabilityCallback, &context);
    SCNetworkReachabilityScheduleWithRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);

//在global_queue中使用了callback
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(self.networkReachability, &flags)) {
            AFPostReachabilityStatusChange(flags, callback);
        }
    });
}

static void AFNetworkReachabilityCallback(SCNetworkReachabilityRef __unused target, SCNetworkReachabilityFlags flags, void *info) {
    AFPostReachabilityStatusChange(flags, (__bridge AFNetworkReachabilityStatusBlock)info);
}
static void AFPostReachabilityStatusChange(SCNetworkReachabilityFlags flags, AFNetworkReachabilityStatusBlock block) {
    AFNetworkReachabilityStatus status = AFNetworkReachabilityStatusForFlags(flags);
//又异步到主队列，在主队列中使用了callback
    dispatch_async(dispatch_get_main_queue(), ^{
        if (block) {
            block(status);
        }
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        NSDictionary *userInfo = @{ AFNetworkingReachabilityNotificationStatusItem: @(status) };
        [notificationCenter postNotificationName:AFNetworkingReachabilityDidChangeNotification object:nil userInfo:userInfo];
    });
}
```
###代码中的一些需要注意的点
1. self 在多个线程中访问
2.  strongSelf 后有一个判空操作  if (strongSelf.networkReachabilityStatusBlock) 
3. networkReachabilityStatusBlock 执行时必须非空

###weakSelf的意义

1、打破 self self.networkReachability callback 之间的循环引用
2、不影响 self 对象的生命周期

###这里strongSelf 的意义

 如果不用strongSelf强引用， 在多线程环境中，会存在这样的场景： 
 if (strongSelf.networkReachabilityStatusBlock)  执行完成后线程被挂起（且结果为true）， 如果不强引用会有这样的情况发生：挂起前self 引用计数>0；挂起期间， 其他的线程对self 进行了release 操作，导致self 被释放；线程再次处于运行状态后 执行到strongSelf.networkReachabilityStatusBlock(status);  导致crash


## 测试代码
 

## 总结

weak strong dance 的最大作用在于：不影响self的生命周期（weak），保证在使用weakSelf过程中weakSelf不被释放

##失败案例
//只起到弱引用， 需要加上注释掉的部分代码，strongSelf 只是拿到了weakSelf retain 之后的value， 不能确保strongSelf 非空

```c
__weak MyViewController *weakSelf = self;
self.completion= ^() {
    __strong __typeof(weakSelf) strongSelf = weakSelf;
    [property removeObserver: strongSelf forKeyPath:@"pathName"];
};
```
修正后代码：

```c
__weak MyViewController *weakSelf = self;
self.completion= ^() {
    __strong __typeof(weakSelf) strongSelf = weakSelf;
    if (nil == strongSelf) {
        return;
    }
    [property removeObserver: strongSelf forKeyPath:@"pathName"];
};
```