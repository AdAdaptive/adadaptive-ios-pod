//
//  AdAdaptiveBanner.swift
//  AdMolnFramework
//
/**************************************************************************************************************************
 *
 * SystemicsCode Nordic AB
 *
 **************************************************************************************************************************/

import Foundation
import CoreLocation
import Alamofire
import AlamofireImage

open class AdAdaptiveBannerView: UIView {
    
    var MY_AD_PLATFORM = AD_PLATFORM()
    
    fileprivate let deviceData = AdAdaptiveDeviceData()
    fileprivate var ad_action: URL? = nil
    
    var timer: DispatchSource!
    var TIMER_SEC: UInt64 = 10
    
    fileprivate let adImageView = UIImageView()

    //***********************************************************************************************************************************/
    // Init functions
    //***********************************************************************************************************************************/
    
    override public init(frame: CGRect){
        //debugPrint("called the frame init")
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        //debugPrint("called the coder init")
        super.init(coder: aDecoder)
        setup()
    }
    
    convenience public init(location: CLLocation) {
        //debugPrint("called convenience init")
        self.init(frame: CGRect.zero)
        setup()
    }
    
    func setup(){
        configure_swipe_gestures()
        configure_tap_gestures()
        self.isHidden = true
        self.addSubview(adImageView)
    }
    
    //***********************************************************************************************************************************/
    // User & Device Data Set Delegate functions
    //***********************************************************************************************************************************/
    open func setUserDataYob(_ yob: Int){  // Year of birth as a 4-digit integer
       deviceData.setUserDataYob(yob)
    }
    open func setUserDataGender(_ gender: String){  // Gender, where “M” = male, “F” = female, “O” = known to be other
        deviceData.setUserDataGender(gender)
    }
    open func setADTimer(_ time:UInt64){
        deviceData.setADTimer(time)
    }
    open func authorizeAPI(API: String?=nil, publisherID: String, appID: String){
        deviceData.setPublisherID(publisherID: publisherID)
        deviceData.setAppID(appID: appID)
        if let api = API {
            MY_AD_PLATFORM = AD_PLATFORM(BASE: api)
        }
    }
    
    //***********************************************************************************************************************************/
    // Swipe Gestures
    //***********************************************************************************************************************************/
    // TO DO: Refractor to pan gestures, swipe gestures are to sensitive
    fileprivate func configure_swipe_gestures(){
        let swipeLeft   = UISwipeGestureRecognizer(target: self, action: #selector(AdAdaptiveBannerView.respondToSwipeGesture(_:)))
        let swipeRight  = UISwipeGestureRecognizer(target: self, action: #selector(AdAdaptiveBannerView.respondToSwipeGesture(_:)))
        
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.addGestureRecognizer(swipeRight)
        
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.addGestureRecognizer(swipeLeft)

    }//configure_swipe_gestures
    //----------------------------------------------------------------------------------------------------------------------------------//
    func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                debugPrint("AdADaptive Info: Swiped right")
                self.isHidden = true
            case UISwipeGestureRecognizerDirection.down:
                debugPrint("AdADaptive Info: Swiped down")
            case UISwipeGestureRecognizerDirection.left:
                debugPrint("AdADaptive Info: Swiped left")
                self.isHidden = true
            case UISwipeGestureRecognizerDirection.up:
                debugPrint("AdADaptive Info: Swiped up")
            default:
                break
            }
        }
    }//respondToSwipeGesture
    //----------------------------------------------------------------------------------------------------------------------------------//
    fileprivate func configure_tap_gestures(){
        let tapGesture = UITapGestureRecognizer(target:self, action:#selector(AdAdaptiveBannerView.respondToTapGesture(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    //----------------------------------------------------------------------------------------------------------------------------------//
    func respondToTapGesture(_ gesture: UIGestureRecognizer){
        debugPrint("AdADaptive Info: Tapped on the AD")
        if self.ad_action != nil {
            let options = [UIApplicationOpenURLOptionUniversalLinksOnly : false]
            UIApplication.shared.open(ad_action!, options: options, completionHandler: nil)
        }
    }
    
    //***********************************************************************************************************************************/
    // AD related functions
    //***********************************************************************************************************************************/
    //***********************************************************************************************************************************/
    // Load a location-based ad
    //***********************************************************************************************************************************/
    open func loadAD(_ location: CLLocation, level_id: Int? = nil, completion: ((_ result: Bool) -> Void)?) {
        
        // Obs: the completion closure is made optional by being wrapped inside a paranthesis and marked as optional
        //      completion: ((_ result: Bool) -> Void)?
        //      if you want to load an add without a completion closure myADView.loadAD(adLocation, completion: nil)
        
        self.ad_action = nil

        if (level_id != nil) {
            deviceData.setIndoorMapLevelID(level_id!)
            //TO DO:  Refractoring deviceData.setIndoorMapLevelID(level_id!) call can be eliminated by introducing an optional paremer 
            // level:id into the main function getDeviceParameters (level_id: String? = nil)
        }
        deviceData.getDeviceParameters(location){
            (result: [String: AnyObject]) in
            //debugPrint("AdAdaptive Info: Device Parameters = \(result)")
            
            debugPrint("AdAdaptive Info: API = \(self.MY_AD_PLATFORM.AD)")
            Alamofire.request(self.MY_AD_PLATFORM.AD, parameters: result).responseJSON {
            //Alamofire.request(self.ad_request_url_str, parameters: result).responseJSON {
                response in switch response.result {
                case .success(let ad_response_JSON):
                    //debugPrint("AdADaptive Info: AD found: \(ad_response_JSON)")
                    debugPrint("AdADaptive Info: AD found")
                    
                    //status code 204 is returned if the ad query is valid but no ad that fulfills the criteria has been found
                    if (response.response?.statusCode)! == 204{
                        debugPrint("AdADaptive Info: No AD has been found!")
                        self.isHidden = true
                        completion?(false)
                        break
                    }
                    if let responseArray = ad_response_JSON as? NSArray {
                        if let firstAD = responseArray[0] as? NSDictionary {
                            if let ad_url = firstAD["ad_url"] as? String {

                                let new_scaled_ad_url = self.scaleAdImage(ad_url)
                                //self.loadADImage(new_scaled_ad_url)
                                self.loadADImageWithAlamofireImage(new_scaled_ad_url)
                                self.isHidden = false
                                
                                if let ad_call_to_action = firstAD["click_through_url"] as? String {
                                    //debugPrint("AdADaptive Info: Ad Call to Action \(ad_call_to_action)")
                                    self.ad_action = URL(string: ad_call_to_action)
                                }
                            }
                        }
                        completion?(true)
                    }else{
                        completion?(false)
                    }
                    
                case .failure(let error):
                    print("AdADaptive Error: Request failed with error: \(error)")
                    completion?(false)
                }
            }//Alamofire.request
        }//deviceData.getDeviceParameters
        self.layer.setNeedsDisplay()
    }
    //***********************************************************************************************************************************/
    // Load and AD associated to an iBeacon
    // iBeacon identified by uuid, major and minor
    // API call: GET http://www.advertisement.cloud/api/v1.0/beacons?beacon[uuid]=B9407F30-F5F8-466E-AFF9-25556B57FE6D&beacon[major]=9949&beacon[minor]=12609
    //***********************************************************************************************************************************/
    open func iBeaconLoadAD(_ uuid: UUID, major: Int? = nil, minor: Int? = nil,  completion: ((_ result: Bool) -> Void)?) {
       
        self.ad_action = nil
        deviceData.getDeviceParameters(){
            (result: [String: AnyObject]) in
            // ad the beacon uuid, major and minor and the maximum no of ads to the the parameter list
            var api_call_parameters               = result
            api_call_parameters["beacon[uuid]"]   = uuid as AnyObject?
            if major != nil {api_call_parameters["beacon[major]"]  = major as AnyObject?}
            if major != nil {api_call_parameters["beacon[minor]"]  = minor as AnyObject?}
            
            Alamofire.request(self.MY_AD_PLATFORM.BEACON, parameters: api_call_parameters).responseJSON {
                response in switch response.result {
                case .success(let ad_response_JSON):
                    //debugPrint("AdAdaptive Info: AD found: \(ad_response_JSON)")
                    debugPrint("AdADaptive Info: AD found")
                    
                    //status code 204 is returned if the ad query is valid but no ad that fulfills the criteria has been found
                    if (response.response?.statusCode)! == 204{
                        debugPrint("AdADaptive Info: No AD has been found!")
                        self.isHidden = true
                        completion?(false)
                        break
                    }
                    if let responseArray = ad_response_JSON as? NSArray {
                        if let firstAD = responseArray[0] as? NSDictionary {
                            if let ad_url = firstAD["ad_url"] as? String {
                                let new_scaled_ad_url = self.scaleAdImage(ad_url)
                                //self.loadADImage(new_scaled_ad_url)
                                self.loadADImageWithAlamofireImage(new_scaled_ad_url)
                                self.isHidden = false
                                if let ad_call_to_action = firstAD["click_through_url"] as? String {
                                    //debugPrint("AdADaptive Info: Ad Call to Action \(ad_call_to_action)")
                                    self.ad_action = URL(string: ad_call_to_action)
                                }
                            }
                        }
                        completion?(true)
                    }else{
                        completion?(false)
                    }
                    
                case .failure(let error):
                    print("AdADaptive Error: Request failed with error: \(error)")
                    completion?(false)
                }
            }//Alamofire.request
        }// getDeviceParamaters
    }
    
    //***********************************************************************************************************************************/
    // Load Timed ads
    //***********************************************************************************************************************************/
    open func loadADTimer(_ location: CLLocation){
        print("Load Timed AD")
        let queue = DispatchQueue(label: "Timer Queue", attributes: [])
        timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: UInt(0)), queue: queue) /*Migrator FIXME: Use DispatchSourceTimer to avoid the cast*/ as! DispatchSource
        TIMER_SEC = deviceData.getADTimer()
        //timer.setTimer(start: DispatchTime.now(), interval: TIMER_SEC * NSEC_PER_SEC, leeway: 1 * NSEC_PER_SEC) // every (TIMER_SEC)60 seconds, with leeway of 1 second
        timer.scheduleRepeating(deadline: DispatchTime.init(uptimeNanoseconds: UInt64(100000)), interval: DispatchTimeInterval.seconds(1), leeway: DispatchTimeInterval.seconds(0))
        timer.setEventHandler {
            // do whatever you want here
            // self.loadAD(location)
        }
        timer.resume()
    }
    open func stopLoadADTimer(){
        print("Stop Timed AD")
        timer.cancel()
        timer = nil
    }
    //***********************************************************************************************************************************/
    // Helper functions
    //***********************************************************************************************************************************/
    //----------------------------------------------------------------------------------------------------------------------------------//
    fileprivate func scaleAdImage(_ ad_url: String) -> String{
        
        // Cloudinary has the posibility of scaling an image to a width of 150 pixels (maintains the aspect ratio by default)
        // w_150,c_scale need to be added to the original ad_url retrieved by the query
        // http://res.cloudinary.com/demo/image/upload/w_150,c_scale/sample.jpg
        
        var scaled_ad_url = ad_url
        let width:Int = Int(deviceData.getDeviceWidth())
        let scale_string = "/w_\(width),c_scale"
        let range = ad_url.range(of: "upload")
        scaled_ad_url.insert(contentsOf: scale_string.characters, at: range!.upperBound)

        //return scaled_ad_url
        return ad_url //uncomment this if he unscaled image need to be returened
    }
    //----------------------------------------------------------------------------------------------------------------------------------//
    // Use this function is AlamofireImage is not available
    fileprivate func loadADImage(_ ad_image_url: String){
        if let url =  URL(string: ad_image_url){
            if let data = try? Data(contentsOf: url) {
                let adImage = UIImage(data: data)
                self.layer.contentsScale = (adImage?.scale)!
                self.layer.contents = adImage?.cgImage
            }
        }
    }
    //----------------------------------------------------------------------------------------------------------------------------------//
    // download the ad image using the AlamofireImage library
    fileprivate func loadADImageWithAlamofireImage(_ ad_image_url: String){
        if let url =  URL(string: ad_image_url){
            adImageView.af_setImage(withURL: url as URL){
                (result: DataResponse<UIImage>) -> Void in
                self.layer.contents = result.result.value?.cgImage
            }
        }
    }
    //***********************************************************************************************************************************/
    // Test  functions
    //***********************************************************************************************************************************/
    open func getAdAdaptiveSDKVersion() -> String{
        return MY_AD_PLATFORM.SDK_VER
    }

}
