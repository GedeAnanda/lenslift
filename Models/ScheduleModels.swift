//
//  SchedulesModels.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 08/06/26.
//

import Foundation

// MARK: - Request
struct ScheduleRequest: Codable {
    let dayOfWeek: String
    let templateId: String
    
    enum CodingKeys: String, CodingKey {
        case dayOfWeek = "day_of_week"
        case templateId = "template_id"
    }
}

// MARK: - Response
struct ScheduleResponse: Codable {
    let id: String
    let dayOfWeek: String
    let template: WorkoutTemplateListResponse
    
    enum CodingKeys: String, CodingKey {
        case id
        case dayOfWeek = "day_of_week"
        case template
    }
}
