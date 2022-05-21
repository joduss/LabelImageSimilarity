//

import SwiftUI

struct LabelerView: View {
    
    @ObservedObject var labeler: Labeler
    
    private var imageDifferentDropHandler: DropImageHandler
    private var imageSimilarDropHandler: DropImageHandler
    
    init(labeler: Labeler) {
        self.labeler = labeler
        imageDifferentDropHandler = DropImageHandler(labeler: labeler, duplicateImages: false)
        imageSimilarDropHandler = DropImageHandler(labeler: labeler, duplicateImages: true)
    }
    
    var body: some View {
        VStack {
            Picker("Dataset", selection: $labeler.selected) {
                ForEach(DatasetKind.allCases) { kind in
                    Text(kind.rawValue.localizedUppercase)
                }
            }.frame(width: 250, alignment: .center)
                .padding(.bottom, 20)
            HStack {
                VStack {
                    Text("Different images")
                    Image(systemName: "arrow.down.doc.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .onDrop(of: [imageDifferentDropHandler.dropType], delegate: imageDifferentDropHandler)
                }
                VStack {
                    Text("Similar images")
                    Image(systemName: "arrow.down.doc.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .onDrop(of: [imageSimilarDropHandler.dropType], delegate: imageSimilarDropHandler)
                }.padding(.leading, 30)
            }
            .padding(.bottom, 20)
            Text("\(self.labeler.datasetInformation)")
        }
        .padding()
    }
}

struct LabelerView_Previews: PreviewProvider {
    
    static let labeler = Labeler(savePath: URL(fileURLWithPath: "fasd"))
    
    static var previews: some View {
        LabelerView(labeler: self.labeler)
            .environmentObject(labeler)
    }
}
