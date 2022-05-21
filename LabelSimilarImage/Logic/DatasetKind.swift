//  Created by Jonathan Duss on 18.05.22.

import Foundation


enum DatasetKind: String, CaseIterable, Identifiable {
    var id: Self { self }
    
    case training, validation, test
    
    
}
