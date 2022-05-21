//

import SwiftUI

@main
struct LabelSimilarImageApp: App {
    
    @ObservedObject private var labeler = Labeler()
    
    var body: some Scene {
        WindowGroup {
            if labeler.labelerVisible {
                LabelerView(labeler: labeler)
                    .fixedSize()
            } else {
                HomeView(labeler: labeler)
                    .frame(minWidth: 200, minHeight: 200)
            }
        }
    }
}
