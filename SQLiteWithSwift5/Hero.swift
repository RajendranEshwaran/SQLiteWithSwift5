//
//  Hero.swift
//  SQLiteWithSwift5
//
//  Created by gomathi saminathan on 1/16/20.
//  Copyright © 2020 Rajendran Eshwaran. All rights reserved.
//

import Foundation
class Hero
{
    var id: Int
    var name: String?
    var powerRanking: Int
    
    init(id: Int, name: String?, powerRanking: Int){
        self.id = id
        self.name = name
        self.powerRanking = powerRanking
    }
}
