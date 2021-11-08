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
    }
    
    
    
    
    
    /// BleCallBack
    open func onConnecting() {
        if(callBack != nil){
            callBack?.responseValue.removeAll()
            callBack!.responseValue["function"]="onConnecting"
            callBack!.callback()
        }
    }
    
    open func onConnectFalse() {
        if(callBack != nil){
            callBack?.responseValue.removeAll()
            callBack!.responseValue["function"]="onConnectFalse"
            callBack!.callback()
        }
    }
    
    open func onConnectSuccess() {
        if(callBack != nil){
            callBack?.responseValue.removeAll()
            callBack!.responseValue["function"]="onConnectSuccess"
            callBack!.callback()
        }
    }
    
    open func rx(_ a: BleBinary) {
        let advermap:BleAdvertise = BleAdvertise ()
        advermap.readHEX=a.readHEX()
        advermap.readBytes=a.readBytes()
        if(callBack != nil){
            callBack?.responseValue.removeAll()
            callBack!.responseValue["function"]="rx"
            callBack!.responseValue["data"]=advermap
            callBack!.callback()
        }
    }
    
    open func tx(_ b: BleBinary) {
        let advermap:BleAdvertise = BleAdvertise ()
        advermap.readHEX=b.readHEX()
        advermap.readBytes=b.readBytes()
        if(callBack != nil){
            callBack?.responseValue.removeAll()
            callBack!.responseValue["function"]="tx"
            callBack!.responseValue["data"]=advermap
            callBack!.callback()
        }
    }
    
    open func scanBack(_ device: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if(!deviceList.contains(device)){
            deviceList.append(device)
        }
        var itmap:Dictionary<String,String> = Dictionary<String,String> ()
        
        itmap["name"]=device.name
        itmap["rssi"]="\(RSSI)"
        itmap["address"]="\(deviceList.firstIndex(of: device) ?? -1)"
        if(advertisementData["kCBAdvDataLocalName"] != nil){
            itmap["name"]="\(advertisementData["kCBAdvDataLocalName"] ?? "")"
        }
        //        itmap["address"]=deviceList.index
        let encoder: JSONEncoder = JSONEncoder()
        let encoded = String(data: try!  encoder.encode(itmap) , encoding: .utf8)!
        let data=advertisementData["kCBAdvDataManufacturerData"]
        let advermap:BleAdvertise = BleAdvertise ()
        if(data is Data){
            var tempstring = ""
            for i in (data as! Data){
                tempstring = tempstring+String(format:"%02X",i)
            }
            advermap.readHEX=tempstring
            advermap.readBytes=[UInt8](data as! Data)
        }
        if(callBack != nil){
            callBack!.responseValue.removeAll()
            callBack!.responseValue["function"]="scanBack"
            callBack!.responseValue["device"]=itmap
            callBack!.responseValue["advertise"]=advermap
            callBack!.callback()
        }
    }
    open func needOpen() { }
}
//資料封包
class BleAdvertise:Encodable {
    var readUTF=""
    var readBytes:[UInt8]=[UInt8]()
    var readHEX=""
}
