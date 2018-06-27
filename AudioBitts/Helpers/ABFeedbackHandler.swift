//
//  ABFeedbackHandler.swift
//  AudioBitts
//
//  Created by Ashok on 28/04/16.
//  Copyright © 2016 mobileways. All rights reserved.
//

import Foundation

class ABFeedbackHandler {
    func saveUserFeedback(_ text: String? = nil, type: ABFeedbackType? = nil, feedFlagged: ABFeed? = nil, userFlagged: ABUser? = nil) {
        let feedback = ABFeedback(feedbackText: text, type: type, feed_Flagged: feedFlagged, user_Flagged: userFlagged)
        HeyParse.sharedInstance.saveInfoInFeedbackTable(feedback)
    }
}

class ABFeedback {
    var feedbackText: String?
    var type: ABFeedbackType?
    var reportedBy: ABUser?
    var feed_Flagged: ABFeed?
    var user_Flagged: ABUser?
    
    init(feedbackText: String?, type: ABFeedbackType?, reportedBy: ABUser? = nil, feed_Flagged: ABFeed?, user_Flagged: ABUser?) {
        self.feedbackText = feedbackText
        self.type = type
        self.reportedBy = reportedBy
        self.feed_Flagged = feed_Flagged
        self.user_Flagged = user_Flagged
    }
}

enum ABFeedbackType: String {
    case GeneralFeedback = "Genral Feedback"
    case SomethingIsntWorking = "Something Is Not Working"
    case ReportAbuse = "Report Abuse"
}
