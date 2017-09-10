//
//  ViewController.swift
//  HHPickerViewDemo
//
//  Created by wanglh on 2017/9/4.
//  Copyright © 2017年 wanglh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //选择时间
        let setTimeButton = UIButton.init(frame: CGRect.init(x: 30, y: 100, width: self.view.bounds.size.width - 60, height: 36))
        setTimeButton.setTitle("选择时间", for: .normal)
        setTimeButton.tag = HHPickerViewType.time.rawValue
        setTimeButton.backgroundColor = UIColor.orange
        setTimeButton.addTarget(self, action: #selector(selectBtnClick(btn:)), for: .touchUpInside)
        view.addSubview(setTimeButton)
        
        //单项选择
        let radioSelectButton = UIButton.init(frame: CGRect.init(x: 30, y: 100+60, width: self.view.bounds.size.width - 60, height: 36))
        radioSelectButton.setTitle("单选", for: .normal)
        radioSelectButton.tag = HHPickerViewType.single.rawValue
        radioSelectButton.backgroundColor = UIColor.init(red: 206/255, green: 86/255, blue: 125/255, alpha: 1)
        radioSelectButton.addTarget(self, action: #selector(selectBtnClick(btn:)), for: .touchUpInside)
        view.addSubview(radioSelectButton)
        
        //多选,例如默认选中的索引[1,3,6]
        let mutableSelectButton = UIButton.init(frame: CGRect.init(x: 30, y: 100+120, width: self.view.bounds.size.width - 60, height: 36))
        mutableSelectButton.setTitle("多选", for: .normal)
        mutableSelectButton.backgroundColor = UIColor.init(red: 77/255, green: 165/255, blue: 249/255, alpha: 1)
        mutableSelectButton.tag = HHPickerViewType.mutable.rawValue
        mutableSelectButton.addTarget(self, action: #selector(selectBtnClick(btn:)), for: .touchUpInside)
        view.addSubview(mutableSelectButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
//        UIDatePicker
//        UIPickerView
        // Dispose of any resources that can be recreated.
    }


    //MARK: - ACTIONS
    @objc func selectBtnClick(btn:UIButton){
        let marginTop:CGFloat = 0
        let data = ["红豆","绿豆","扁豆","黄豆","豇豆","灰豆","大红豆","糖豆","巴豆","小豆","兰豆","番茄","白豆","扁豆"]
        if btn.tag == HHPickerViewType.time.rawValue {
            let pickerView = HHPickerView.init(frame: CGRect.init(x: marginTop, y: self.view.bounds.size.height, width: self.view.bounds.size.width, height: CGFloat(toolBarH + pickerViewH)), dateFormat: nil,datePickerMode:.dateAndTime, minAndMaxAndCurrentDateArr: nil)
            pickerView.rowAndComponentCallBack = {(resultStr,selectedArr) in
                print("str--->\(String(describing: resultStr))")
                btn.setTitle(resultStr! as String, for: .normal)
            }
            pickerView.show()
        }else if btn.tag == HHPickerViewType.single.rawValue{
            let pickerView = HHPickerView.init(frame: CGRect.init(x: marginTop, y: self.view.bounds.size.height, width: self.view.bounds.size.width, height: CGFloat(toolBarH + pickerViewH)), dataSource: data as NSArray, defaultIntegerArr: nil, pickerType: .single)
            
            pickerView.rowAndComponentCallBack = {(resultStr,selectedArr) in
                print("str--->\(String(describing: resultStr))")
                btn.setTitle(resultStr! as String, for: .normal)
            }
            pickerView.show()
        }else if btn.tag == HHPickerViewType.mutable.rawValue {
            let pickerView = HHPickerView.init(frame: CGRect.init(x: marginTop, y: self.view.bounds.size.height, width: self.view.bounds.size.width, height: CGFloat(toolBarH + pickerViewH)), dataSource: data as NSArray, defaultIntegerArr: [1,3,6], pickerType: .mutable)
            
            pickerView.rowAndComponentCallBack = {(resultStr,selectedArr) in
                print("str--->\(String(describing: resultStr))")
                btn.setTitle(resultStr! as String, for: .normal)
            }
            pickerView.show()
        }
    }
}

