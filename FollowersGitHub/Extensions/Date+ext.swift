//
//  Date+ext.swift
//  FollowersGitHub
//
//  Created by Alan Modesto on 31/10/24.
//

import Foundation

extension Date{
    
    
    func convertToMonthYearFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        
        return dateFormatter.string(from: self)
    }
    
    
    
}
