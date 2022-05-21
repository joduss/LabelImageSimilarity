//  Created by Jonathan Duss on 18.05.22.

import Foundation
import UniformTypeIdentifiers
import SwiftUI


class DropImageHandler: DropDelegate, ObservableObject {
        
    private let supportedFileExtensions = [".jpg", ".png", ".heic"]
    
    public let dropType = UTType.fileURL
    
    private let labeler: Labeler
    private let duplicateImages: Bool
    
    private var imageUrls: [URL] = []
        
    init(labeler: Labeler, duplicateImages: Bool) {
        self.labeler = labeler
        self.duplicateImages = duplicateImages
    }


    func performDrop(info: DropInfo) -> Bool {
        self.imageUrls.removeAll()

        Task {
            await process(itemProviders: Array(info.itemProviders(for: [dropType])))
            processImageUrls()
        }

        return true
    }

    private func process(itemProviders: [NSItemProvider]) async {
        for provider in itemProviders {
            if provider.hasItemConformingToTypeIdentifier(dropType.identifier) {
                await process(itemProvider: provider)
            }
        }
    }
    
    private func process(itemProvider: NSItemProvider) async {
            do {
                let encodedItem = try await itemProvider.loadItem(forTypeIdentifier: dropType.identifier, options: nil)
                guard let pathData = encodedItem as? Data,
                      let fileUrl = URL(dataRepresentation: pathData, relativeTo: nil) else {
                    return
                }

                if isImage(fileUrl) {
                    self.imageUrls.append(fileUrl)
                }

            } catch {
                print("Failed to load dropped item")
            }
    }

    private func isImage(_ url: URL) -> Bool {
        return UTType(filenameExtension: url.pathExtension)?.conforms(to: .image) ?? false;
    }
    
    private func processImageUrls() {
        if self.duplicateImages {
            self.labeler.processDuplicateImages(self.imageUrls)
        } else {
            self.labeler.processDifferentImages(self.imageUrls)
        }
        
        self.labeler.saveDataset()
        self.imageUrls.removeAll()
    }
}
