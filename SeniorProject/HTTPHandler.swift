//
//  HTTPHandler.swift
//  SeniorProject
//
//  Created by Baris Yagan on 5/25/17.
//  Copyright © 2017 Baris Yagan. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class HTTPHandler {
    
    var url = URL(string: "http://localhost:3000/posts/")
    
    func getScoreTable() -> [String: String] {
        
        var scoreTable: [String : String] = [:]
        
        Alamofire.request(url!, method: .get).validate().responseJSON { response in
            switch response.result {
            
            case .success(let value):
                    
                let json = JSON(value)
                for (_,subJson):(String, JSON) in json {
                    for (key,subJson):(String, JSON) in subJson {
                            
                        if (key != "id") {
                                
                            scoreTable[key] = subJson.stringValue
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
        
        return scoreTable
    }
}
