//
//  ModuleIniter.h
//  Playground
//
//  Created by wangqinghai on 2018/4/26.
//  Copyright © 2018年 wangqinghai. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface ModuleIniter : NSObject

@end



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
