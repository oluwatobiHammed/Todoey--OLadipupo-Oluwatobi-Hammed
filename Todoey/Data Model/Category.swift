//
//  Category.swift
//  Todoey
//
//  Created by Philipp Muellauer on 29/11/2019.
//  Copyright © 2019 Philipp Muellauer. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String? = ""
    @objc dynamic var colour: String? = ""
    @objc dynamic var time: Date? = nil
    
    let items = List<Item>()
    
    enum CodingKeys: String, CodingKey{
        case name, colour, time
    }
    
    public convenience required init(name: String, colour: String, time: Date) {
         self.init()
         self.name = name
         self.colour = colour
         self.time = time
   
     }
     
    
    public required convenience init(decoder: Decoder) throws {
        self.init()
        
        //Get the root of our object
        let container = try decoder.container(keyedBy: CodingKeys.self)
        //Decode id from container(the root)
        
        colour = try container.decodeIfPresent(String.self, forKey: .colour)
        time = try container.decodeIfPresent(Date.self, forKey: .time)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        
        
    }

}
