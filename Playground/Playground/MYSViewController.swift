//
//  MYSViewController.swift
//  Playground
//
//  Created by wangqinghai on 2018/4/26.
//  Copyright © 2018年 wangqinghai. All rights reserved.
//

import UIKit

class MYSViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func doSomethingOnBackgroundThreadWeak() {
        DispatchQueue.global().async {[weak self] ()-> Void in
            if self?.data != nil {
                Thread.sleep(forTimeInterval: 3)
                var string = "data: "
                print("before sleep， 模仿线程-挂起状态")
                Thread.sleep(forTimeInterval: 5)
                print("after sleep， 模仿线程-运行状态")
                string.append(self!.data)
                print(string)
            }
        }
    }
    override func doSomethingOnBackgroundThreadStrong() {
        DispatchQueue.global().async {[weak self] ()-> Void in
            guard let `self` = self else {
                return;
            }
            Thread.sleep(forTimeInterval: 3)
            var string = "data: "
            print("before sleep， 模仿线程-挂起状态")
            Thread.sleep(forTimeInterval: 5)
            print("after sleep， 模仿线程-运行状态")
            string.append(self.data)
            print(string)
            
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
