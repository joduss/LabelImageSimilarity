//

import SwiftUI
import UniformTypeIdentifiers




struct HomeView: View {
    
    @ObservedObject var labeler: Labeler
    
    init( labeler: Labeler) {
        self.labeler = labeler
    }
    
    
    var body: some View {
        Button("Pick Destination Directory", action: {
            let panel = NSOpenPanel()
            panel.canChooseDirectories = true
            panel.canChooseFiles = false
            
            panel.runModal()
            
            guard panel.urls.count > 0 else { return }
            self.labeler.savePath = panel.urls[0]
        }).padding(.all, 20)
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        HomeView(labeler: Labeler(savePath: URL(fileURLWithPath: "asfads")))
    }
}
