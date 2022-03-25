import JzOsBleHelper
import CoreBluetooth
import Glitter_IOS
public class Glitter_BLE:BleCallBack{
    public static var instance:Glitter_BLE? = nil
    public static var debugMode=false
    public static func getInstance() -> Glitter_BLE{
        if(instance==nil){instance=Glitter_BLE()}
        return instance!
    }
    let act=GlitterActivity.getInstance()
    var callBack: RequestFunction? = nil
    //儲存的藍芽陣列
    var deviceList=[CBPeripheral]()
    public func create() {
        let bleUtil=BleHelper(self)
        let glitterName="Glitter_BLE_"
        //Start
        act.addJavacScriptInterFace(interface: JavaScriptInterFace(functionName: "\(glitterName)Start", function: {
            request in
            request.responseValue["result"]=true
            request.finish()
        }))
        //StartScan
        act.addJavacScriptInterFace(interface: JavaScriptInterFace(functionName: "\(glitterName)StartScan", function: {
            request in
            bleUtil.startScan()
            request.responseValue["result"]=true
            request.finish()
        }))
        //StopScan
        act.addJavacScriptInterFace(interface: JavaScriptInterFace(functionName: "\(glitterName)StopScan", function: {
            request in
            bleUtil.stopScan()
            request.responseValue["result"]=true
            request.finish()
        }))
        //WriteHex
        act.addJavacScriptInterFace(interface: JavaScriptInterFace(functionName: "\(glitterName)WriteHex", function: {
            request in
            bleUtil.writeHex("\(request.receiveValue["data"]!)", "\(request.receiveValue["txChannel"]!)", "\(request.receiveValue["rxChannel"]!)")
            request.responseValue["result"]=true
            request.finish()
        }))
        //WriteUtf
        act.addJavacScriptInterFace(interface: JavaScriptInterFace(functionName: "\(glitterName)WriteUtf", function: {
            request in
            bleUtil.writeUtf("\(request.receiveValue["data"]!)", "\(request.receiveValue["txChannel"]!)", "\(request.receiveValue["rxChannel"]!)")
            request.responseValue["result"]=true
            request.finish()
        }))
        //WriteBytes
        act.addJavacScriptInterFace(interface: JavaScriptInterFace(functionName: "\(glitterName)WriteBytes", function: {
            request in
            bleUtil.writeBytes(request.receiveValue["data"] as! [UInt8], "\(request.receiveValue["txChannel"]!)", "\(request.receiveValue["rxChannel"]!)")
            request.responseValue["result"]=true
            request.finish()
        }))
        //IsOpen
        act.addJavacScriptInterFace(interface: JavaScriptInterFace(functionName: "\(glitterName)IsOpen", function: {
            request in
            request.responseValue["result"]=bleUtil.isOpen()
            request.finish()
        }))
        //IsDiscovering
        act.addJavacScriptInterFace(interface: JavaScriptInterFace(functionName: "\(glitterName)IsDiscovering", function: {
            request in
            request.responseValue["result"]=bleUtil.isScanning()
            request.finish()
        }))
        //Connect
        act.addJavacScriptInterFace(interface: JavaScriptInterFace(functionName: "\(glitterName)Connect", function: {
            request in
            DispatchQueue.global().async {
                let timeOut=request.receiveValue["timeOut"]! as! Int
                bleUtil.connect(self.deviceList[Int("\(request.receiveValue["address"]!)")!],timeOut)
                var time=0
                while(!(bleUtil.IsConnect)&&time<timeOut){
                    sleep(1)
                    time+=1
                }
                if(self.callBack != nil && (!bleUtil.IsConnect)){
                    self.callBack?.responseValue.removeAll()
                    self.callBack!.responseValue["function"]="onConnectFalse"
                    self.callBack!.callback()
                }
                request.responseValue["result"]=bleUtil.IsConnect
                request.finish()
            }
        }))
        //DisConnect
        act.addJavacScriptInterFace(interface: JavaScriptInterFace(functionName: "\(glitterName)DisConnect", function: {
            request in
            bleUtil.disconnect()
            request.responseValue["result"]=true
            request.finish()
        }))
        //IsConnect
        act.addJavacScriptInterFace(interface: JavaScriptInterFace(functionName: "\(glitterName)IsConnect", function: {
            request in
            request.responseValue["result"]=bleUtil.IsConnect
            request.finish()
        }))
        //SetCallBack
        act.addJavacScriptInterFace(interface: JavaScriptInterFace(functionName: "\(glitterName)SetCallBack", function: {
            request in
            request.responseValue["result"]=bleUtil.IsConnect
            self.callBack=request
        }))
        //SetNotify
        act.addJavacScriptInterFace(interface: JavaScriptInterFace(functionName: "\(glitterName)SetNotify", function: {
            request in
            let rxChannel=request.receiveValue["rxChannel"] as! String
            guard let rx = bleUtil.charDictionary[rxChannel] else {
                print("設定回覆通道:\(rxChannel)")
                request.responseValue["result"]=false
                return
            }
            bleUtil.connectPeripheral.setNotifyValue(true, for: rx)
            request.responseValue["result"]=true
            request.finish()
        }))
    }
    
    
    
    
    var debugText="JzBleMessage"
    /// BleCallBack
    open func onConnecting() {
        if(callBack != nil){
            callBack?.responseValue.removeAll()
            callBack!.responseValue["function"]="onConnecting"
            callBack!.callback()
        }
        if(Glitter_BLE.debugMode){
            print("\(debugText):onConnecting")
        }
    }
    
    open func onConnectFalse() {
        if(callBack != nil){
            callBack?.responseValue.removeAll()
            callBack!.responseValue["function"]="onDisconnect"
            callBack!.callback()
            if(Glitter_BLE.debugMode){
                print("\(debugText):onDisconnect")
            }
        }
    }
    
    open func onConnectSuccess() {
        if(callBack != nil){
            callBack?.responseValue.removeAll()
            callBack!.responseValue["function"]="onConnectSuccess"
            callBack!.callback()
            if(Glitter_BLE.debugMode){
                print("\(debugText):onConnectSuccess")
            }
         
        }
    }
    
    open func rx(_ a: BleBinary) {
        var advermap:Dictionary<String,AnyObject> = [:]
        advermap["readHEX"]=a.readHEX() as AnyObject
        advermap["readBytes"]=a.readBytes() as AnyObject
        if(callBack != nil){
            callBack?.responseValue.removeAll()
            callBack!.responseValue["function"]="rx"
            callBack!.responseValue["data"]=advermap
            callBack!.callback()
            if(Glitter_BLE.debugMode){
                print("\(debugText):rx->\(a.readHEX())")
            }
     
        }
    }
    
    open func tx(_ b: BleBinary) {
        var advermap:Dictionary<String,AnyObject> = [:]
        advermap["readHEX"]=b.readHEX() as AnyObject
        advermap["readBytes"]=b.readBytes() as AnyObject
        if(callBack != nil){
            callBack?.responseValue.removeAll()
            callBack!.responseValue["function"]="tx"
            callBack!.responseValue["data"]=advermap
            callBack!.callback()
            if(Glitter_BLE.debugMode){
            print("\(debugText):tx->\(b.readHEX())")
            }
        }
    }
    
    var pastime = Date().timeIntervalSince1970
    var scanList:[Dictionary<String,Any>] = []
    open func scanBack(_ device: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if(!deviceList.contains(device)){
            deviceList.append(device)
        }
        var itmap:Dictionary<String,Any> = Dictionary<String,Any> ()
        itmap["rssi"]="\(RSSI)"
        itmap["address"]="\(deviceList.firstIndex(of: device) ?? -1)"
        if(advertisementData["kCBAdvDataLocalName"] != nil){
        itmap["name"]="\(advertisementData["kCBAdvDataLocalName"] ?? "")"
        }
        let data=advertisementData["kCBAdvDataManufacturerData"]
        if(data is Data){
            var tempstring = ""
            for i in (data as! Data){
                tempstring = tempstring+String(format:"%02X",i)
            }
            itmap["readHEX"]=tempstring as AnyObject
            itmap["readBytes"]=[UInt8](data as! Data) as AnyObject
        }
        scanList.append(itmap)
        if(GetTime(pastime)>1){
            pastime=Date().timeIntervalSince1970
            if(callBack != nil){
                callBack!.responseValue.removeAll()
                callBack!.responseValue["device"]=scanList
                callBack!.responseValue["function"]="scanBack"
                callBack!.callback()
                if(Glitter_BLE.debugMode){
                print("\(debugText):scanList->\(scanList)")
                }
                scanList.removeAll()
            }
        }
    }
    
    open func needOpen() { }
    
    func GetTime(_ timeStamp: Double)-> Double{
        let currentTime = Date().timeIntervalSince1970
        let reduceTime : TimeInterval = currentTime - timeStamp
        return reduceTime
    }
}
