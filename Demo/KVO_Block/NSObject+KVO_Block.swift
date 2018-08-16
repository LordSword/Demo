//
//  NSObject+KVO_Block.swift
//  Demo
//
//  Created by sword on 2018/8/16.
//  Copyright © 2018年 Sword. All rights reserved.
//

import Foundation

func setterForGetter(getter: String) -> String {
    
    return "set" + getter.capitalized + ":"
}

class ObserverInfo: NSObject {
    
    weak var observer:AnyObject?
    var key:String
    var block:((String, Any?, Any?) -> Void)
    
    init(_ observer:AnyObject, key:String, block:@escaping (String, Any?, Any?) -> Void) {
        
        self.observer = observer
        self.key = key
        self.block = block
        
        super.init()
    }
    
}

extension NSObject {
    
    public func sAddObserver(observer:AnyObject, forKey key:String, _ block:@escaping (String, Any?, Any?) -> Void) {
        
        //判断是否有set 并获取set实现
        let setSEL = Selector( setterForGetter(getter: key))
        let setMethod = class_getInstanceMethod(type(of: self), setSEL)
        
        //判断是否生成过中间类
        var observedClass = object_getClass(self)
        let className = NSStringFromClass(observedClass!)
        
        if !className.hasPrefix("SObserver_") {
            observedClass = createKVOClass(className:"SObserver_" + className)
            object_setClass(self, observedClass);
        }
        
        //判断是否更换过方法
        if !self.hasSelector(selector: setSEL) {
            
            let newIMP = method(for: #selector(KVO_setter(tself:cmd:newValue:)))
            class_addMethod(observedClass, setSEL, newIMP, method_getTypeEncoding(setMethod));
        }

        //添加观察者
        var observers = objc_getAssociatedObject(self, "SAssociatedObservers")  as? [ObserverInfo]
        if nil == observers {
            observers = [ObserverInfo]();
            objc_setAssociatedObject(self, "SAssociatedObservers", observers, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        let observerInfo = ObserverInfo( observer, key: key, block: block)
        observers?.append(observerInfo)
    }
    
    func createKVOClass(className: String) -> AnyClass? {
        
        if let observedClass = NSClassFromString(className) {
            return observedClass
        }

        if let originClass = object_getClass(self), let kvoClass = objc_allocateClassPair(originClass, className, 0)  {
            objc_registerClassPair(kvoClass);
            
            return kvoClass;
        }


        return nil
    }
    
    func hasSelector(selector : Selector) -> Bool {
        
        var outCount:UInt32
        outCount = 0
        let methods:UnsafeMutablePointer<Method?>! =  class_copyMethodList( object_getClass(self), &outCount)
        
        let count:Int = Int(outCount);
        for i in 0..<count {
            
            let thisSelector = method_getName(methods[i]);
            if (thisSelector == selector) {
                return true
            }
        }
        return false
    }
    
    func KVO_setter( tself:AnyObject, cmd:Selector, newValue:Any) -> Void {
        
        let getterName = cmd.description
        let oldValue = tself.value(forKey: getterName)
        
        tself.willChangeValue(forKey: getterName)
        
        self.setValue(newValue, forKey: getterName)
        
        tself.didChangeValue(forKey: getterName)
        
        let observers = objc_getAssociatedObject(tself, "SAssociatedObservers")  as? [ObserverInfo]
        for info in observers! {
            if (info.key == getterName) {
                
                DispatchQueue.global(qos: .default).async {
                    info.block(getterName, oldValue, newValue)
                }
            }
        }
    }
}




