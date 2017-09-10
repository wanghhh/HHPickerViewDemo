# HHPickerViewDemo
自定义一个简单的选择器：时间选择、单选、多选（暂未添加多级联动选择模式，后续添加），其中时间选择支持设置时间范围和默认时间。
先看下效果图：

![Image text](https://github.com/wanghhh/HHPickerViewDemo/blob/master/gitHubImage/pickerView_gif.gif)

调用示例：

比如选择时间：

       let pickerView = HHPickerView.init(frame: CGRect.init(x: marginTop, y: self.view.bounds.size.height, width: self.view.bounds.size.width, height: CGFloat(toolBarH + pickerViewH)), dateFormat: nil,datePickerMode:.dateAndTime, minAndMaxAndCurrentDateArr: nil)
    
        pickerView.rowAndComponentCallBack = {(resultStr,selectedArr) in
            print("str--->\(String(describing: resultStr))")
            btn.setTitle(resultStr! as String, for: .normal)
       
       }
        
    pickerView.show()
    
//多选

      let pickerView = HHPickerView.init(frame: CGRect.init(x: marginTop, y: self.view.bounds.size.height, width: self.view.bounds.size.width, height: CGFloat(toolBarH + pickerViewH)), dataSource: data as NSArray, defaultIntegerArr: [1,3,6], pickerType: .mutable)
        
       pickerView.rowAndComponentCallBack = {(resultStr,selectedArr) in
            print("str--->\(String(describing: resultStr))")
            btn.setTitle(resultStr! as String, for: .normal)
       
       }
        
     pickerView.show()
 
 
 //详细介绍：http://www.jianshu.com/p/5dd86af25356
