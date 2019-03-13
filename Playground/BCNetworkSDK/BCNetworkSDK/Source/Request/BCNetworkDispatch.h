//
//  BCNetworkDispatch.h
//  BCNetworkSDK
//
//  Created by 王青海 on 2018/7/26.
//  Copyright © 2018年 王青海. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
 * AFNetworking 回调队列，做数据的校验、解密，JSON转Model等耗时操作
 */
@interface BCNetworkDispatch : NSObject

@property (nonatomic, strong) dispatch_queue_t serializationQueue;


+ (dispatch_queue_t)serializationQueue;

@end
