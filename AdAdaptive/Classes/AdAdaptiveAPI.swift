//
//  AdAdaptiveAPI.swift
//  AdAdaptive
//
/**************************************************************************************************************************
 *
 * SystemicsCode Nordic AB
 *
 **************************************************************************************************************************/
// API functions for rerieving ads based on other criteria then location-based
// The following API call retrieves a number of 5 ads belonging to a Campaign with a given ID
// GET "http://www.advertisement.cloud/api/v1.0/ads/campaign?ad[campaign_id]=581c9a6c9162970003bb3b02&search[max_ads]=5"


import Foundation
import CoreLocation
import Alamofire
import AlamofireImage

open class AdAdaptiveAPI {
    
    var MY_AD_PLATFORM = AD_PLATFORM()
    
    fileprivate let deviceData = AdAdaptiveDeviceData()
    
    var adImages:   [UIImage]   = []    // array of the ad images
    var adActions:   [URL?]     = []   // array of ad cal to action urls
    
    //***********************************************************************************************************************************/
    // Initialize
    //***********************************************************************************************************************************/
    init(API: String?=nil, publisherID: String, appID: String){
        //debugPrint("Initializing the AMolnAPI")
        deviceData.setPublisherID(publisherID: publisherID)
        deviceData.setAppID(appID: appID)
        if let api = API {
            MY_AD_PLATFORM = AD_PLATFORM(BASE: api)
        }
    }
    //***********************************************************************************************************************************/
    // Load AD series belonging to a campaign
    // Eg call: www.advertisement.cloud/api/v1.0/ads/campaign?ad[campaign_id]=581c9a6c9162970003bb3b02&search[max_ads]=5
    //***********************************************************************************************************************************/
    open func loadADsFromCampaigns(_ location: CLLocation, campaign_id: String, max_no_ads: Int, completion: ((_ result: Bool) -> Void)?) {
        
        // Obs: the completion closure is made optional by being wrapped inside a paranthesis and marked as optional
        // completion: ((_ result: Bool) -> Void)?
        // if you want to load an add without a completion closure myADView.loadAD(adLocation, completion: nil)
        
        deviceData.getDeviceParameters(location){
            (result: [String: AnyObject]) in
            
            // ad the campaingn id and the maximum no of ads to the the parameter list
            var api_call_parameters                 = result
            api_call_parameters["ad[campaign_id]"]  = campaign_id as AnyObject?
            api_call_parameters["search[max_ads]"]  = max_no_ads as AnyObject?
            
            //debugPrint("Device Data Parameters = \(result)")
            //debugPrint("API Call Parameters = \(api_call_parameters)")

            Alamofire.request(self.MY_AD_PLATFORM.CAMPAIGN, parameters: api_call_parameters).responseJSON {
                response in switch response.result {
                case .success(let ad_response_JSON):
                    debugPrint("AdAdaptive Info: AD found: \(ad_response_JSON)")
                    
                    //status code 204 is returned if the ad query is valid but no ad that fulfills the criteria has been found
                    if (response.response?.statusCode)! == 204{
                        //debugPrint("No AD has ben found")
                        completion?(false)
                        break
                    }
                    if let responseArray = ad_response_JSON as? NSArray {
                          //debugPrint("ADS from Campaign found !!!!")
                        for object in responseArray as! [NSDictionary] {
                            let ad_url = object["ad_url"] as? String
                            //debugPrint("AD URL: \(ad_url)")
                            self.loadADImage(ad_url!)
                            //self.loadADImageWithAlamofireImage(ad_url!)
                            
                            if let ad_call_to_action = object["click_through_url"] as? String {
                                //debugPrint("Ad Call to Action \(ad_call_to_action)")
                                let ad_action = URL(string: ad_call_to_action)
                                self.adActions.append(ad_action!)
                            }else{
                                //debugPrint("NO Ad Call to Action: added nil!!!")
                                self.adActions.append(nil)
                            }
                        } //for
                        completion?(true)
                    }else{
                        completion?(false)
                    }
                    
                case .failure(let error):
                    print("AdAdaptive Error: Request failed with error: \(error)")
                    completion?(false)
                }
            }//Alamofire.request
        }//deviceData.getDeviceParameters
    }
    
    //***********************************************************************************************************************************/
    // Load ADs series belonging to a tag category
    // Eg call: http://localhost:3040/api/v1.0/ads?device[geo][lat]=41.8758264&device[geo][lon]=-87.618951&tags[text]=chicago&tags[text]=blabla&adfilter[max_ads]=3
    //***********************************************************************************************************************************/
    open func loadADsCategory(_ location: CLLocation, tag: String, max_no_ads: Int, completion: ((_ result: Bool) -> Void)?) {
        
        //Obs: the completion closure is made optional by being wrapped inside a paranthesis and marked as optional
        //     completion: ((_ result: Bool) -> Void)?
        //     if you want to load an add without a completion closure myADView.loadAD(adLocation, completion: nil)
        
        deviceData.getDeviceParameters(location){
            (result: [String: AnyObject]) in
            
            // ad the campaingn id and the maximum no of ads to the the parameter list
            var api_call_parameters                     = result
            api_call_parameters["tags[text]"]           = tag as AnyObject?
            api_call_parameters["search[max_ads]"]      = max_no_ads as AnyObject?
            
            //debugPrint("Device Data Parameters = \(result)")
            //debugPrint("API Call Parameters = \(api_call_parameters)")
            
            Alamofire.request(self.MY_AD_PLATFORM.AD, parameters: api_call_parameters).responseJSON {
                response in switch response.result {
                case .success(let ad_response_JSON):
                    debugPrint("AdAdaptive Info: AD found: \(ad_response_JSON)")
                    
                    //status code 204 is returned if the ad query is valid but no ad that fulfills the criteria has been found
                    if (response.response?.statusCode)! == 204{
                        //debugPrint("No AD has ben found")
                        completion?(false)
                        break
                    }
                    if let responseArray = ad_response_JSON as? NSArray {
                        //debugPrint("ADS from Campaign found !!!!")
                        for object in responseArray as! [NSDictionary] {
                            let ad_url = object["ad_url"] as? String
                            //debugPrint("AD URL: \(ad_url)")
                            self.loadADImage(ad_url!)
                            //self.loadADImageWithAlamofireImage(ad_url!)
                            
                            if let ad_call_to_action = object["click_through_url"] as? String {
                                //debugPrint("Ad Call to Action \(ad_call_to_action)")
                                let ad_action = URL(string: ad_call_to_action)
                                self.adActions.append(ad_action!)
                            }else{
                                //debugPrint("NO Ad Call to Action: added nil!!!")
                                self.adActions.append(nil)
                            }
                        } //for
                        completion?(true)
                    }else{
                        completion?(false)
                    }
                    
                case .failure(let error):
                    print("AdAdaptive Error: Request failed with error: \(error)")
                    completion?(false)
                }

            }//Alamofire.request
            
        }//deviceData.getDeviceParameters
    }

    //-------------------------------------------------------------------------------------------------------------------------------------//
    fileprivate func loadADImage(_ ad_image_url: String){
        if let url =  URL(string: ad_image_url){
            //debugPrint("Retrieve AD from \(url)")
            if let data = try? Data(contentsOf: url) {
                //debugPrint("Retrieve data")
                let adImage = UIImage(data: data)
                adImages.append(adImage!)
            }
        }
    }
    //-------------------------------------------------------------------------------------------------------------------------------------//
    // download the ad image using the AlamofireImage library
    fileprivate func loadADImageWithAlamofireImage(_ ad_image_url: String){
        Alamofire.request(ad_image_url).responseImage { response in
            if let image = response.result.value {
                self.adImages.append(image as UIImage)
            }
        }//alamofire
    }

}
