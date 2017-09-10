//
//  HHPickerView.swift
//  HHPickerViewDemo
//
//  Created by wanglh on 2017/9/4.
//  Copyright © 2017年 wanglh. All rights reserved.
//

import UIKit

//选择器类型
enum HHPickerViewType:NSInteger {
    case single = 0   //只能单选
    case mutable = 1  //可多选、单选
    case time = 2     //选择时间
}
//***********全局UI外观控制************
//确认按钮颜色
let confirmTextNormalColor = UIColor.init(red: 77/255, green: 165/255, blue: 249/255, alpha: 1)
let confirmTextSelectedColor = UIColor.init(red: 77/255, green: 165/255, blue: 249/255, alpha: 1)

//取消按钮颜色
let cancelTextNormalColor = UIColor.init(red: 130/255, green: 130/255, blue: 130/255, alpha: 1)
let cancelTextSelectedColor = UIColor.init(red: 130/255, green: 130/255, blue: 130/255, alpha: 1)
let btnMargin:CGFloat = 16.0 //按钮与边界距离
let toolBarH = 40.0 //工具条高度
let pickerViewH = 216.0 //选择器高度

//结果回调
typealias HHPickerViewCallBackClosure = (_ resultStr:NSString?,_ resultArr:NSArray?) -> ()
class HHPickerView: UIView {
    
    var dismissCallBack = {} //取消的回调
    var rowAndComponentCallBack:HHPickerViewCallBackClosure?//选择内容回调
    fileprivate var pickerViewType:HHPickerViewType? //pickerView类型
    fileprivate var blockContent:NSString?// 需要回调的内容
    fileprivate var selectedArr:NSArray?// 需要回调的内容的索引数组，时间模式默认返回nil

    var confirmButton:UIButton? //确定按钮
    var cancelButton:UIButton?  //取消按钮
    var overlayView:UIControl?  //遮罩层view
    var keyWindow : UIWindow?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white;
        
        // 1 获取window
        if (keyWindow == nil) {
            self.keyWindow = UIApplication.shared.keyWindow
        }
        // 2.遮罩view
        overlayView = UIControl.init(frame: UIScreen.main.bounds)
        overlayView?.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        overlayView?.addTarget(self, action: #selector(hide), for: .touchUpInside)
        overlayView?.alpha = 0
        // 3.创建工具条toolView
        let toolView:UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: Int(self.bounds.size.width), height: Int(toolBarH)))
        toolView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        addSubview(toolView)
        
        cancelButton = UIButton.init(frame: CGRect.init(x: btnMargin, y: 0, width: 44, height: toolView.bounds.size.height))
        cancelButton?.setTitle("取消", for: .normal)
        cancelButton?.setTitleColor(cancelTextNormalColor, for: .normal)
        cancelButton?.setTitleColor(cancelTextSelectedColor, for: .selected)
        cancelButton?.titleLabel?.font = UIFont.systemFont(ofSize: 17.5)
        cancelButton?.contentHorizontalAlignment = .left
        cancelButton?.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        toolView.addSubview(cancelButton!)
        
        confirmButton = UIButton.init(frame: CGRect.init(x: (toolView.bounds.size.width - 44.0 - btnMargin), y: 0, width: 44, height: toolView.bounds.size.height))
        confirmButton?.setTitle("确定", for: .normal)
        confirmButton?.setTitleColor(confirmTextNormalColor, for: .normal)
        confirmButton?.setTitleColor(confirmTextSelectedColor, for: .selected)
        confirmButton?.titleLabel?.font = UIFont.systemFont(ofSize: 17.5)
        confirmButton?.contentHorizontalAlignment = .left
        confirmButton?.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        toolView.addSubview(confirmButton!)
    }
    /// 单选/多选便利构造器
    ///
    /// - Parameters:
    ///   - frame: frame
    ///   - pickerType: 选择类型(单选或多选)
    ///   - dataSource: 数据源
    ///   - defaultIntegerArr: 默认选中项的索引数组
    convenience init(frame: CGRect,dataSource:NSArray,defaultIntegerArr:NSArray?,pickerType:HHPickerViewType) {
        self.init(frame: frame)
        pickerViewType = pickerType
        if (dataSource.count != 0) {
            let picker = HHCollectionView.init(frame: CGRect.init(x: (confirmButton?.superview?.frame.minX)!, y: (confirmButton?.superview?.frame.maxY)!, width: UIScreen.main.bounds.size.width, height: CGFloat(pickerViewH)), collectionViewLayout: HHWaterfallLayout(), dataSource: dataSource, defaultIntegerArr: defaultIntegerArr, contentCallBack: { [weak self] (resultStr, selectedArr) in
                self?.blockContent = resultStr
                self?.selectedArr = selectedArr
            })
            picker.rowAndComponentCallBack = {[weak self](resultStr,selectedArr) in
                self?.blockContent = resultStr
                self?.selectedArr = selectedArr
            }
            addSubview(picker)
        }else{
            assert(dataSource.count != 0, "dataSource is not allowed to be nil")
        }
    }
    /// 时间选择便利构造器
    ///
    /// - Parameters:
    ///   - frame: frame
    ///   - dateFormat: 时间格式化字符串,可空
    ///   - datePickerMode: 选择器的时间模式,可空
    ///   - minAndMaxAndCurrentDateArr: 可选最小、最大时间及当前时间，可空
    convenience init(frame: CGRect,dateFormat:NSString?,datePickerMode:UIDatePickerMode?,minAndMaxAndCurrentDateArr:[NSDate]?) {
        self.init(frame: frame)
        pickerViewType = HHPickerViewType.time
        
        let picker = HHDatePicker.init(frame: CGRect.init(x: (confirmButton?.superview?.frame.minX)!, y: (confirmButton?.superview?.frame.maxY)!, width: UIScreen.main.bounds.size.width, height: CGFloat(pickerViewH)), dateFormat: dateFormat,datePickerMode:datePickerMode, minAndMaxAndCurrentDateArr: nil, resultCallBack: {[weak self] (resultStr) in
            self?.blockContent = resultStr
        })
        picker.getSelectedResult({[weak self] (resultStr) in
            self?.blockContent = resultStr
        })
        addSubview(picker)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - ACTIONS
    //显示
    func show(){
        keyWindow?.addSubview(overlayView!)
        keyWindow?.addSubview(self)
        UIView.animate(withDuration: 0.25, animations: {
            self.overlayView?.alpha = 1.0
            var frame = self.frame
            frame.origin.y = UIScreen.main.bounds.size.height - self.bounds.size.height
            self.frame = frame
        }) { (isFinished) in
            //
        }
    }
    
    //隐藏
    func hide() {
        self.dismissCallBack()
        UIView.animate(withDuration: 0.25, animations: {
            self.overlayView?.alpha = 0
            var frame = self.frame
            frame.origin.y = UIScreen.main.bounds.size.height
            self.frame = frame
        }) { (isFinished) in
            self.overlayView?.removeFromSuperview()
            self.removeFromSuperview()
        }
    }
    //取消
    func cancelAction() {
        hide()
    }
    
    //确定选择
    func confirmAction() {
        if blockContent == "" {
            showAlert(withTitle: "提示", message: "未选择任何一项！")
        }else if pickerViewType != HHPickerViewType.time && (selectedArr?.count)! > 1 && pickerViewType == HHPickerViewType.single {
            showAlert(withTitle: "提示", message: "此项仅支持单选！")
        }else{
            self.rowAndComponentCallBack!(blockContent,selectedArr)
        }
        hide()
    }
    
    //异常提示
    @objc private func showAlert(withTitle title: String?, message: String?) {
        let alertVc = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertVc.addAction(UIAlertAction.init(title: "我知道了", style: UIAlertActionStyle.cancel, handler: nil))
        UIApplication.shared.keyWindow?.rootViewController?.present(alertVc, animated: true, completion: nil)
    }
}

typealias HHDatePickerCallBackClosure = (_ resultStr:NSString?) -> ()
class HHDatePicker: UIDatePicker {
    var dateChangeCallBack:HHDatePickerCallBackClosure? //时间改变回调
    var dateFormat:NSString?
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 时间选择器便利构造方法
    ///
    /// - Parameters:
    ///   - frame: frame
    ///   - dateFormat: 时间格式化字符串
    ///   - datePickerMode: 选择器的时间模式
    ///   - minAndMaxAndCurrentDateArr: 可选最小、最大时间及当前时间
    ///   - resultCallBack: 选择结果
    convenience init(frame: CGRect,dateFormat:NSString?,datePickerMode:UIDatePickerMode?,minAndMaxAndCurrentDateArr:[NSDate]?,resultCallBack:((_ resultStr:NSString) -> Void)?) {
        self.init(frame: frame)
        self.backgroundColor = UIColor.white;
        if datePickerMode != nil {
            self.datePickerMode = datePickerMode!
        }else{
            self.datePickerMode = .dateAndTime //默认显示月、日、时间
        }
        if dateFormat?.range(of: "yy").location != NSNotFound {
            self.datePickerMode = .dateAndTime
        }else{
            self.datePickerMode = .date
        }
        //可以设置时间范围
        var minDateTem = NSDate.init()
        var maxDateTem = NSDate.init(timeIntervalSinceNow: 90*365*24*60*60)
        var currentDateTem = NSDate.init()
        if minAndMaxAndCurrentDateArr != nil && minAndMaxAndCurrentDateArr?.count == 2 {
            minDateTem = (minAndMaxAndCurrentDateArr?[0])!
            maxDateTem = (minAndMaxAndCurrentDateArr?[1])!
            currentDateTem = (minAndMaxAndCurrentDateArr?[2])!
        }
        self.minimumDate = minDateTem as Date
        self.maximumDate = maxDateTem as Date
        self.setDate(currentDateTem as Date, animated: false)
        self.locale = Locale.init(identifier: "zh_CN")
        
        self.addTarget(self, action: #selector(dateChange(datePicker:)), for: UIControlEvents.valueChanged)
        
        //默认回调当前时间
        let theDate = self.date
        let dateFormatter = DateFormatter.init()
        if (dateFormat != nil) {
            dateFormatter.dateFormat = dateFormat! as String
            self.dateFormat = dateFormat
        }else{
            dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
            self.dateFormat = dateFormatter.dateFormat! as NSString
        }
        let nowDate = dateFormatter.string(from: theDate)
        resultCallBack!(nowDate as NSString)
    }
    
    //MARK: - ACTIONS
    fileprivate func getSelectedResult(_ callBack: @escaping(HHDatePickerCallBackClosure)) {
        dateChangeCallBack = callBack
    }
    //时间改变监听
    func dateChange(datePicker:UIDatePicker) {
        //
        let theDate = datePicker.date
        print("\(theDate.description(with: Locale.current))")
        
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = self.dateFormat! as String
        let nowDate = dateFormatter.string(from: theDate)

        dateChangeCallBack!(nowDate as NSString)
    }
    
}

fileprivate let HHCollectionViewCellId = "HHCollectionViewCellId"
class HHCollectionView: UICollectionView,UICollectionViewDataSource,UICollectionViewDelegate{
    fileprivate var rowAndComponentCallBack:HHPickerViewCallBackClosure?//选择内容回调
    lazy var dataSourceArr = NSMutableArray() //数据源
    lazy var selectedArr = NSMutableArray() //被选中的数据
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 便利构造器
    ///
    /// - Parameters:
    ///   - frame: frame
    ///   - collectionViewLayout: collectionViewLayout
    ///   - dataSource: 选择项数据源
    ///   - defaultIntegerArr: 默认选中的项索引数组
    ///   - contentCallBack: 选择结果回调
    convenience init(frame:CGRect,collectionViewLayout:UICollectionViewLayout,dataSource:NSArray,defaultIntegerArr:NSArray?,contentCallBack:HHPickerViewCallBackClosure?) {
        self.init(frame: frame, collectionViewLayout: collectionViewLayout)
        self.delegate = self
        self.dataSource = self
        self.backgroundColor = UIColor.white
        self.dataSourceArr = NSMutableArray.init(array: dataSource)
        if (defaultIntegerArr != nil) {
            self.selectedArr = NSMutableArray.init(array: defaultIntegerArr!)
        }
        
        self.register(HHCollectionCell.self, forCellWithReuseIdentifier: HHCollectionViewCellId)
        
        if (contentCallBack != nil) {
            //默认选中数据
            var resultStr = "" //选中的结果的拼接字符串,多选用“;”号隔开（按需要自定义）
            
            if self.selectedArr.count > 0 {
                for (idx,obj) in self.selectedArr.enumerated() {
                    if idx == 0 {
                        resultStr = self.dataSourceArr[(obj as? Int)!] as! String
                    }else{
                        resultStr = "\(resultStr);\(self.dataSourceArr[(obj as? Int)!])"
                    }
                }
            }
            contentCallBack!(resultStr as NSString,selectedArr)
        }
    }
    
    //MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSourceArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:HHCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: HHCollectionViewCellId, for: indexPath) as! HHCollectionCell
        if (self.selectedArr.count>0) {
            var isSelected = false
            for (_,obj) in self.selectedArr.enumerated() {
                if obj as? NSInteger == indexPath.row{
                   cell.isSelected = true
                    isSelected = true
                    break
                }
            }
            if isSelected == false {
                cell.isSelected = false
            }
        }
        cell.titleLab?.text = dataSourceArr[indexPath.row] as? String
        return cell
    }
    
    //MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell:HHCollectionCell = collectionView.cellForItem(at: indexPath) as! HHCollectionCell
        
        if (self.selectedArr.count>0) {
            var isExited = false//是否已经被选中，即存在selectedArr中
            for (_,obj) in self.selectedArr.enumerated() {
                if obj as? NSInteger == indexPath.row{
                    cell.isSelected = false //取消选中
                    isExited = true
                    selectedArr.remove(indexPath.row)
                    break
                }
            }
            if isExited == false {
                selectedArr.add(indexPath.row)
            }
        }else{
            cell.isSelected = true
            selectedArr.add(indexPath.row)
        }
        reloadItems(at: [indexPath])
        
        //组装回调结果***
        //默认选中数据
        var resultStr = "" //选中的结果的拼接字符串,多选用“;”号隔开（按需要自定义）
        
        if self.selectedArr.count > 0 {
            for (idx,obj) in self.selectedArr.enumerated() {
                if idx == 0 {
                    resultStr = self.dataSourceArr[(obj as? Int)!] as! String
                }else{
                    resultStr = "\(resultStr);\(self.dataSourceArr[(obj as? Int)!])"
                }
            }
        }
        self.rowAndComponentCallBack!(resultStr as NSString,selectedArr)
    }
}

let columnCount = 3 //列数
class HHWaterfallLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()//必须写
        collectionView?.backgroundColor = UIColor.white
        self.scrollDirection = .vertical;
        
        self.minimumInteritemSpacing = 10 //cell之间最小间距
        self.minimumLineSpacing = 10 //最小行间距
        self.sectionInset = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
        let contentW = self.collectionViewContentSize.width - self.sectionInset.left - self.sectionInset.right
        let itemW = (contentW - CGFloat(columnCount - 1) * self.minimumInteritemSpacing - 10) / CGFloat(columnCount)
        

        self.itemSize = CGSize.init(width: itemW, height: HHCollectionCellHeight)
    }
}

let cellNormalBorderColor = UIColor.init(red: 180/255, green: 180/255, blue: 180/255, alpha: 1)
let cellSelectedBorderColor = UIColor.init(red: 127/255, green: 201/255, blue: 144/255, alpha: 1)
let cellTextNormalColor = UIColor.init(red: 137/255, green: 137/255, blue: 137/255, alpha: 1)
let cellTextSelectedColor = UIColor.init(red: 174/255, green: 0/255, blue: 21/255, alpha: 1)
let HHCollectionCellHeight:CGFloat = 30.0 // cell高度
class HHCollectionCell: UICollectionViewCell {
    var titleLab:UILabel?
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLab = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: Int(self.contentView.bounds.size.width), height: Int(HHCollectionCellHeight)))
        titleLab?.text = "可选项"
        titleLab?.font = UIFont.systemFont(ofSize: 14)
        titleLab?.textAlignment = .center
        titleLab?.lineBreakMode = .byWordWrapping
        titleLab?.layer.cornerRadius = 6
        titleLab?.layer.masksToBounds = true
        titleLab?.layer.borderWidth = 1
        titleLab?.layer.borderColor = cellNormalBorderColor.cgColor
        titleLab?.textColor = cellTextNormalColor
        self.contentView.addSubview(titleLab!)
    }
    
    override var isSelected: Bool {
        didSet{
            titleLab?.layer.borderColor = isSelected ? cellSelectedBorderColor.cgColor : cellNormalBorderColor.cgColor
            titleLab?.textColor = isSelected ? cellTextSelectedColor : cellTextNormalColor
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
