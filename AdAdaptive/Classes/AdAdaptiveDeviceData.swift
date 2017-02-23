//
//  AdAdaptiveDeviceData.swift
//  AdAdaptiveFramework
//
/**************************************************************************************************************************
 *
 * SystemicsCode Nordic AB
 *
 **************************************************************************************************************************/

import Foundation
import CoreLocation
import AdSupport
import CoreTelephony
import SystemConfiguration
import UIKit

class AdAdaptiveDeviceData {
    
    // device[geo]
    fileprivate var lat:        CLLocationDegrees!      // Latitude from -90.0 to +90.0, where negative is south.
    fileprivate var lon:        CLLocationDegrees!      // Longitude from -180.0 to +180.0, where negative is west.
    fileprivate var ttype:      Int = 1                 // Source of location data; recommended when passing lat/lon
                                                        // 1 = GPS/Location Services
                                                        // 2 = IP Address
                                                        // 3 = User provided (e.g., registration data)
                                                        // 4 = Cell-ID Location Service (e.g Combain) - not standard(added for skylab)
                                                        // 5 = Indoor positioning system - not standard(added for skylab)
    fileprivate var country:    String? = nil           // Country code using ISO-3166-1-alpha-3.
    fileprivate var region:     String? = nil           // Region code using ISO-3166-2; 2-letter state code if USA
    fileprivate var city:       String? = nil           // City Name
    fileprivate var zip:        String? = nil           // Zip or postal code
    fileprivate var street:     String? = nil           // Street name
    fileprivate var streetno:   String? = nil           // Sub Adress or street number: eg. 94-102
    
    // device
    fileprivate var lmt:        Int = 0                 // Limit Ad Tracking” signal commercially endorsed (e.g., iOS, Android), where
                                                        // 0 = tracking is unrestricted, 1 = tracking must be limited per commercial guidelines.
    fileprivate var idfa:       String? = nil           // Unique device identifier Advertiser ID
    fileprivate var devicetype: Int?    = nil           // Device type (e.g. 1=Mobile/Tablet, 2=Personal computer, 3=Connected TV, 4=Phone, 5=Tablet, 6=Connected Device, 7=Set Top Box
    fileprivate let make:       String  = "Apple"       // Device make
    fileprivate var model:      String? = nil           // Device model (e.g., “iPhone”)
    fileprivate var os:        	String? = "iPhone OS"   // Device operating system (e.g., “iOS”)
    fileprivate var osv:        String? = nil           // Device operating system version (e.g., “9.3.2”).
    fileprivate var hwv:      	String? = nil           // Hardware version of the device (e.g., “5S” for iPhone 5S, "qcom" for Android).
    fileprivate var h:          CGFloat = 0.0           // Physical height of the screen in pixels
    fileprivate var w:          CGFloat = 0.0           // Physical width of the screen in pixels.
    fileprivate var ppi:        CGFloat? = nil          // Screen size as pixels per linear inch.
    fileprivate var pxratio:    CGFloat? = nil          // The ratio of physical pixels to device independent pixels. For all devices that do not have Retina Displays this will return a 1.0f,
                                                        // while Retina Display devices will give a 2.0f and the iPhone 6 Plus (Retina HD) will give a 3.0f.
    fileprivate var language:   String? = nil           // Display Language ISO-639-1-alpha-2
    fileprivate var carrier:    String? = nil           // Carrier or ISP (e.g., “VERIZON”)
    fileprivate var connectiontype: Int = 0             // Network connection type: 
                                                        //0=Unknown; 1=Ethernet; 2=WIFI; 3=Cellular Network – Unknown Generation; 4=Cellular Network – 2G; 5=Cellular Network – 3G; 6=Cellular Network – 4G
    
    fileprivate var publisher_id: String? = nil
    fileprivate var app_id:       String? = nil
    
   
    // micello
    // Mocello Indoor Map related data
    fileprivate var level_id: Int? = nil                 // The Micello map level id
    
    // user
    // user data is stored persistently using the NSUserDaults
    fileprivate let userData = UserDefaults.standard
    
    fileprivate let DEFAULT_TIMER: UInt64 = 10           // 10 sec default time for timed ad delivery
    
    //***********************************************************************************************************************************/
    // Init functions
    //***********************************************************************************************************************************/
    init(){
        
        
        let screenBounds: CGRect = UIScreen.main.bounds
        h = screenBounds.height
        w = screenBounds.width
        
        let pxratio: CGFloat = UIScreen.main.scale
        ppi = pxratio * 160
        
        
        // country = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as! String
        // print("Country = \(country)")
        
        
        // Check if Advertising Tracking is Enabled
        if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
            idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            lmt = 0
            //debugPrint("IDFA = \(idfa)")
        } else {
            lmt = 1
            idfa = nil
        }
        
        model = UIDevice.current.model
        if (model == "iPad") {
            devicetype = 5
        }
        if (model == "iPhone"){
            devicetype = 4
        }
        
        os = UIDevice.current.systemName
        osv = UIDevice.current.systemVersion
        hwv = getDeviceHardwareVersion()
        
        language = Locale.preferredLanguages[0]
        
        carrier = CTTelephonyNetworkInfo().subscriberCellularProvider?.carrierName
        
        
        if (!isConnectedToNetwork()){
            debugPrint("AdADaptive Info: Not Connected to the Network")
        }
        
    }
    
    //***********************************************************************************************************************************/
    // User Data Set functions
    //***********************************************************************************************************************************/
    func setUserDataYob(_ yob: Int){  // Year of birth as a 4-digit integer
        userData.set(yob, forKey: "yob")
        userData.synchronize()
    }
    func setUserDataGender(_ gender: String){  // Gender, where “M” = male, “F” = female, “O” = known to be other
        userData.setValue(gender, forKey: "gender")
        userData.synchronize()
    }
    func setADTimer(_ time: UInt64){
        // Wrap the UInt64 in an NSNumber as store the NSNumber in NSUserDefaults
        // NSNumber.init(unsignedLongLong: time)
        userData.set(NSNumber(value: time as UInt64), forKey: "adtimer")
        userData.synchronize()
    }
    func getADTimer() -> UInt64{
        if userData.object(forKey: "adtimer") != nil {
            
            let time_sec: NSNumber! = userData.value(forKey: "adtimer") as! NSNumber
            //cast the returned value to an UInt64
            
            guard let return_time = time_sec else {
                return DEFAULT_TIMER // deafualt 60.0 sec
            }
            
            return return_time.uint64Value
        }
        else{
            return DEFAULT_TIMER // default 60.0 sec
        }
    }
    func setIndoorMapLevelID(_ level_id: Int){
        self.level_id = level_id
    }
    
    func setPublisherID(publisherID: String){
        self.publisher_id = publisherID
    }
    
    func setAppID(appID: String){
        self.app_id = appID
    }
    
    //***********************************************************************************************************************************/
    // Utility functions
    //***********************************************************************************************************************************/
    fileprivate func getDeviceHardwareVersion() -> String {
        
        var modelName: String {
            var systemInfo = utsname()
            uname(&systemInfo)
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            let identifier = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8 , value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
            
            switch identifier {
            case "iPod5,1":                                 return "iPod Touch 5"
            case "iPod7,1":                                 return "iPod Touch 6"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
            case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return "iPad Pro"
            case "AppleTV5,3":                              return "Apple TV"
            case "i386", "x86_64":                          return "Simulator"
            default:                                        return identifier
            }
        }//String
        return modelName
    }
    //----------------------------------------------------------------------------------------------------------------------------------//
    fileprivate func isConnectedToNetwork() -> Bool {
        // Network connection type: 0=Unknown; 1=Ethernet; 2=WIFI; 3=Cellular Network – Unknown Generation; 4=Cellular Network – 2G; 5=Cellular Network – 3G; 6=Cellular Network – 4G
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }) else {
            return false
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        let isNetworkReachable = (isReachable && !needsConnection)
        
        
        if (isNetworkReachable) {
            if (flags.contains(SCNetworkReachabilityFlags.isWWAN)) {
            let carrierType = CTTelephonyNetworkInfo().currentRadioAccessTechnology
            switch carrierType{
                case CTRadioAccessTechnologyGPRS?,CTRadioAccessTechnologyEdge?,CTRadioAccessTechnologyCDMA1x?:
                    debugPrint("AdADaptive Info: Connection Type: = 2G")
                    connectiontype = 4
                case CTRadioAccessTechnologyWCDMA?,CTRadioAccessTechnologyHSDPA?,CTRadioAccessTechnologyHSUPA?,CTRadioAccessTechnologyCDMAEVDORev0?,CTRadioAccessTechnologyCDMAEVDORevA?,CTRadioAccessTechnologyCDMAEVDORevB?,CTRadioAccessTechnologyeHRPD?:
                    debugPrint("AdADaptive Info: Connection Type: = 3G")
                    connectiontype = 5
                case CTRadioAccessTechnologyLTE?:
                    debugPrint("AdADaptive Info: Connection Type: = 4G")
                    connectiontype = 6
                default:
                    debugPrint("AdADaptive Info: Connection Type: = Unknown Generation")
                    connectiontype = 3
            }//switch
            } else {
                debugPrint("AdADaptive Info: Connection Type: WIFI")
                connectiontype = 2
            }
        }//if
        return isNetworkReachable
    }//connectedToNetwork()
    
    //***********************************************************************************************************************************/
    // Get functions
    //***********************************************************************************************************************************/
    func getDeviceParameters(_ location: CLLocation, completion:@escaping (_ result: [String: AnyObject])->Void){
        var device_parameters: [String: AnyObject] = [:]
        lat    = location.coordinate.latitude
        lon    = location.coordinate.longitude
        
        //finding the user adress by using reverse geocodding
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error)->Void in
            var placemark:CLPlacemark!
            
            if error == nil && placemarks!.count > 0 {
                placemark = placemarks![0] as CLPlacemark
            
                self.streetno   = placemark.subThoroughfare
                self.street     = placemark.thoroughfare
                self.zip        = placemark.postalCode
                self.city       = placemark.locality
                self.region     = placemark.administrativeArea
                self.country    = placemark.country
            } //if
            device_parameters = self.getDeviceParametersFormat()
            completion(device_parameters)
        }) // geocoder.reverseGeocodeLocation
    }
    //----------------------------------------------------------------------------------------------------------------------------------//
    func getDeviceParameters(completion:@escaping (_ result: [String: AnyObject])->Void){
        var device_parameters: [String: AnyObject] = [:]
        device_parameters = self.getDeviceParametersFormat()
        completion(device_parameters)
    }

    //----------------------------------------------------------------------------------------------------------------------------------//
    func getDeviceWidth()->CGFloat{
        return w
    }
    //----------------------------------------------------------------------------------------------------------------------------------//
    // format the device parametrs that it can be passed as parameter to an Alamofire call
    func getDeviceParametersFormat()->[String: AnyObject]{
        var parameters: [String: AnyObject] = [:]
        
        if self.publisher_id != nil  { parameters["publisher[pid]"]      = self.publisher_id as AnyObject? }
        if self.app_id != nil        { parameters["publisher[appid]"]    = self.app_id as AnyObject?   }
        
        if self.lat != nil       { parameters["device[geo][lat]"]        = self.lat as AnyObject?      }
        if self.lon != nil       { parameters["device[geo][lon]"]        = self.lon as AnyObject?      }
        if self.country != nil   { parameters["device[geo][country]"]    = self.country as AnyObject?  }
        if self.region != nil    { parameters["device[geo][region]"]     = self.region as AnyObject?   }
        if self.city != nil      { parameters["device[geo][city]"]       = self.city as AnyObject?     }
        if self.zip != nil       { parameters["device[geo][zip]"]        = self.zip as AnyObject?      }
        if self.streetno != nil  { parameters["device[geo][streetno]"]   = self.streetno as AnyObject?  }
        if self.street != nil    { parameters["device[geo][street]"]     = self.street as AnyObject?  }
                                   parameters["device[lmt]"]             = self.lmt as AnyObject?
        if lmt == 0 {
            if self.idfa != nil  { parameters["device[idfa]"]            = self.idfa as AnyObject?     }
        }
        if self.model != nil     { parameters["device[model]"]           = self.model as AnyObject?    }
        if self.os != nil        { parameters["device[os]"]              = self.os as AnyObject?       }
        if self.osv != nil       { parameters["device[osv]"]             = self.osv as AnyObject?      }
        if self.hwv != nil       { parameters["device[hwv]"]             = self.hwv as AnyObject?      }
                                   parameters["device[h]"]               = self.h as AnyObject?
                                   parameters["device[w]"]               = self.w as AnyObject?
        if self.ppi != nil       { parameters["device[ppi]"]             = self.ppi as AnyObject?      }
        if self.pxratio != nil   { parameters["device[pxratio]"]         = self.pxratio as AnyObject?  }
        if self.language != nil  { parameters["device[language]"]        = self.language as AnyObject? }
        if self.carrier != nil   { parameters["device[carrier]"]         = self.carrier as AnyObject?  }
                                   parameters["device[connectiontype]"]  = self.connectiontype as AnyObject?
        
        if userData.object(forKey: "yob") != nil {
            parameters["user[yob]"]  = userData.integer(forKey: "yob") as AnyObject?
        }
        if userData.object(forKey: "gender") != nil {
            parameters["user[gender]"]  = userData.string(forKey: "gender") as AnyObject?
        }
        
        if self.level_id != nil  {
            parameters["micello[level_id]"]       = self.level_id as AnyObject?
            level_id = nil
        }

        return parameters
    }
}
