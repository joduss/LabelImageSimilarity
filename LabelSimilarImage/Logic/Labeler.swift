//  Created by Jonathan Duss on 18.05.2022.

import Foundation

/// Creates a dataset from images located in a directory and its subdirectory
/// when the users drop images.
/// The dataset will be a csv containing path to pair of images and a boolean
/// indicating if the images are similar.
class Labeler: ObservableObject {

    private(set) var dataset: Dataset?
    
    @Published var datasetInformation: String = ""
    @Published var labelerVisible = false
    
    @Published var selected: DatasetKind = .training {
        didSet {
            datasetInformation = "Loading..."
            Task {
                try await loadDataset()
                self.updateDatasetInformation()
            }
        }
    }
        
    init(savePath: URL? = nil) {
        self.savePath = savePath
        
        guard let savePath = savePath else {
            self.dataset = nil
            return
        }
    }
    
    private func loadDataset() async throws {
        
        self.dataset = Dataset(path: savePath.appendingPathComponent("dataset-\(selected.rawValue).csv"))

        try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<Void, Error>) -> Void in
            do {
                try self.dataset!.load()
                continuation.resume()
            } catch {
                print("Failed to load dataset: \(error)")
                dataset = nil
                continuation.resume(throwing: error)
            }

            DispatchQueue.main.async {
                self.labelerVisible = self.dataset != nil
            }
            self.updateDatasetInformation()
        }
    }
    
    public func saveDataset() {
        do {
            try self.dataset?.save()
        } catch {
            print(error)
            datasetInformation = "Failed to save dataset"
        }
    }
    
    var savePath: URL! {
        didSet {
            guard savePath != nil else { return }
            Task {
                try await loadDataset()
            }
        }
    }
    
    /// Process images considering all of them duplicates
    func processDuplicateImages(_ urls: [URL]) {
        processImage(urls, areDuplicate: true)
    }
    
    /// Process images considering all of them different from each other
    func processDifferentImages(_ urls: [URL]) {
        processImage(urls, areDuplicate: false)
    }

    func processImage(_ urls: [URL], areDuplicate: Bool) {
        var urlAUsed: [URL] = []

        for urlA in urls {
            urlAUsed.append(urlA)
            for urlB in urls {
                guard urlA != urlB && urlAUsed.contains(urlB) == false else { continue }

                self.dataset?.add(imageAPath: urlA, imageBPath: urlB, areDuplicate: areDuplicate)
            }
        }

        self.updateDatasetInformation()
    }
    
    private func updateDatasetInformation() {
        Task { @MainActor in
            self.datasetInformation = "Total in \(self.selected.rawValue): \(self.dataset?.count ?? 0)"
        }
    }
}
