//
//  AdAdaptiveInterstitial.swift
//  AdAdaptive
//
/**************************************************************************************************************************
 *
 * SystemicsCode Nordic AB
 *
 **************************************************************************************************************************/

import UIKit
import Alamofire
import AlamofireImage
import CoreLocation

protocol AdAdaptiveInterstitialDelegate: class {
    func interstitialAdDidFinishLoad(controller:AdAdaptiveInterstitial)
    func interstitialAdDismissed(controller: AdAdaptiveInterstitial)
}


class AdAdaptiveInterstitial: UIViewController {
    
    var MY_AD_PLATFORM = AD_PLATFORM()
    
    var delegate:AdAdaptiveInterstitialDelegate?
    
    //fileprivate let ad_request_url_str = MY_AD_PLATFORM.AD
    fileprivate let deviceData = AdAdaptiveDeviceData()
    fileprivate var ad_action: URL? = nil
    var isReady: Bool = false

    @IBOutlet weak var adImage:     UIImageView!
    @IBOutlet weak var closeBtn:    UIButton!
    @IBAction func functionDismissAd(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        self.delegate?.interstitialAdDismissed(controller: self)
        debugPrint("AdAdaptive Info: Interstitial AD dismissed")
    }
    
    //----------------------------------------------------------------------------------------------------------------------------------//
    fileprivate func configure_tap_gestures(){
        //let tapGesture = UITapGestureRecognizer(target:self, action:#selector(UIImageView.respondToTapGesture(_:)))
        let tapGesture = UITapGestureRecognizer(target:self, action: #selector(self.respondToTapGesture(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    //----------------------------------------------------------------------------------------------------------------------------------//
    @objc fileprivate func respondToTapGesture(_ gesture: UIGestureRecognizer){
        debugPrint("AdAdaptive Info: Tapped on the AD")
        //UIApplication.sharedApplication().openURL(NSURL(string: "http://www.AdAdaptive.se")!)
        if self.ad_action != nil {
            let options = [UIApplicationOpenURLOptionUniversalLinksOnly : false]
            UIApplication.shared.open(ad_action!, options: options, completionHandler: nil)
        }
    }
    //***********************************************************************************************************************************/
    // Init functions
    //***********************************************************************************************************************************/
    convenience init(publisherID: String, appID: String){
        debugPrint("AdAdaptive Info: Called init")
        self.init(nibName: "AdAdaptiveInterstitial", bundle: nil)
        self.modalTransitionStyle = UIModalTransitionStyle.partialCurl
        deviceData.setPublisherID(publisherID: publisherID)
        deviceData.setAppID(appID: appID)
        configure_tap_gestures()
    }
    
    //***********************************************************************************************************************************/
    // Transition style
    //***********************************************************************************************************************************/
    open func setAdTransitionStyle(transitionStyle: UIModalTransitionStyle){
        self.modalTransitionStyle = transitionStyle
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // create a rounded dismiss button at the right upper corner of the interstitial ad
        closeBtn.backgroundColor = UIColor.black
        closeBtn.layer.cornerRadius = closeBtn.frame.size.width/2
        closeBtn.layer.borderWidth = 2
        closeBtn.layer.borderColor = UIColor.white.cgColor

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //***********************************************************************************************************************************/
    // Load Interstitial AD
    //***********************************************************************************************************************************/
    //  Obs: the completion closure is made optional by being wrapped inside a paranthesis and marked as optional
    //  completion: ((_ result: Bool) -> Void)?
    //  if you want to load an add without a completion closure myADView.loadAD(adLocation, completion: nil)
    //  Example API call: https://www.advertisement.cloud/api/v1.0/ads?device[geo][lat]=40.780676&device[geo][lon]=-73.976396
    //----------------------------------------------------------------------------------------------------------------------------------//
    
    open func loadInterstitialAD(_ location: CLLocation, completion: ((_ result: Bool) -> Void)?){
        //let adLocation =  CLLocation(latitude: 59.327730, longitude: 18.068114)  //59.327730, 18.068114
        deviceData.getDeviceParameters(location){
            (result: [String: AnyObject]) in
            debugPrint("AdAdaptive Info: Device Parameters = \(result)")
            let api_call_parameters = result
            Alamofire.request(self.MY_AD_PLATFORM.AD, parameters: api_call_parameters).responseJSON {
                response in switch response.result {
                case .success(let ad_response_JSON):
                    debugPrint("AdADaptive Info: Interstitial AD found: \(ad_response_JSON)")
                    
                    //status code 204 is returned if the ad query is valid but no ad that fulfills the criteria has been found
                    if (response.response?.statusCode)! == 204{
                        debugPrint("AdADaptive Info: No Interstitial AD has been found!")
                        completion?(false)
                        break
                    }
                    if let responseArray = ad_response_JSON as? NSArray {
                        if let firstAD = responseArray[0] as? NSDictionary {
                            if let ad_url = firstAD["ad_url"] as? String {
                                
                                //let new_scaled_ad_url = self.scaleAdImage(ad_url)
                                //self.loadADImage(new_scaled_ad_url)
                                debugPrint("AdAdaptive Info: Inetrstitial AD URL: \(ad_url)")
                                
                                //self.loadADImage(ad_url, completion:nil)
                                self.loadADImageWithAlamofireImage(ad_url)

                                if let ad_call_to_action = firstAD["click_through_url"] as? String {
                                    debugPrint("AdADaptive Info: Ad Call to Action \(ad_call_to_action)")
                                    self.ad_action = URL(string: ad_call_to_action)
                                }
                            }
                        }
                        completion?(true)
                        self.delegate?.interstitialAdDidFinishLoad(controller: self)
                    }else{
                        completion?(false)
                    }
                    
                case .failure(let error):
                    print("AdADaptive Error: Request failed with error: \(error)")
                    completion?(false)
                }
            }// Alamofire.request
        }// getDeviceParameters
    }// loadInterstitialAD
    
    //***********************************************************************************************************************************/
    // Helper functions
    //***********************************************************************************************************************************/
    //----------------------------------------------------------------------------------------------------------------------------------//
    private func loadADImage(_ ad_image_url: String, completion: ((_ result: Bool) -> Void)?){
        if let url =  URL(string: ad_image_url){
            debugPrint("AdADaptive Info: Retrieve Interstitial AD from \(url)")
            if let data = try? Data(contentsOf: url) {
                adImage?.image = UIImage(data: data)
                adImage?.setNeedsDisplay()
            }
        }
        completion?(true)
    }
    
    // download the ad image using the AlamofireImage library
    //----------------------------------------------------------------------------------------------------------------------------------//
    fileprivate func loadADImageWithAlamofireImage(_ ad_image_url: String){
        if let url =  URL(string: ad_image_url){
            adImage.af_setImage(withURL: url as URL)
            adImage?.setNeedsDisplay()
        }
    }

}
