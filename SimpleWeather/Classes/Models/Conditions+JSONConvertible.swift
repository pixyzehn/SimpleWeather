//
//  Conditions+JSONConvertible.swift
//  SimpleWeather
//
//  Created by Ryan Nystrom on 11/16/16.
//  Copyright © 2016 Ryan Nystrom. All rights reserved.
//

import Foundation

extension Conditions: JSONConvertible {

    static func fromJSON(json: [String : Any]) -> Conditions? {
        guard let epoch_string = json["observation_epoch"] as? String,
            let epoch_interval = TimeInterval(epoch_string),
            let weather = json["weather"] as? String,
            let temp = json["temp_f"] as? Double,
            let humidity = json["relative_humidity"] as? String,
            let wdir = json["wind_dir"] as? String,
            let wspd = json["wind_mph"] as? Double,
            let pressure = (json["pressure_in"] as? NSString)?.doubleValue,
            let dewpoint = json["dewpoint_f"] as? Double,
            let feelslike = (json["feelslike_f"] as? NSString)?.doubleValue,
            let visibility = (json["visibility_mi"] as? NSString)?.doubleValue,
            let uvi = (json["UV"] as? NSString)?.integerValue,
            let precip_1hr = (json["precip_1hr_in"] as? NSString)?.doubleValue,
            let precip_day = (json["precip_today_in"] as? NSString)?.doubleValue,
            let icon_string = json["icon"] as? String
            else { return nil }

        let icon = ConditionsIcon.from(string: icon_string)
        let wind = Wind(speed: wspd, direction: wdir)

        return Conditions(
            date: Date(timeIntervalSince1970: epoch_interval),
            weather: weather,
            temp: temp,
            humidity: humidity,
            wind: wind,
            pressure: pressure,
            dewpoint: dewpoint,
            feelslike: feelslike,
            visibility: visibility,
            uvi: uvi,
            precip_1hr: precip_1hr,
            precip_day: precip_day,
            icon: icon
        )
    }
    
}