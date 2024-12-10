import Foundation

extension Collection {
    func partition(by predicate: (Element) -> Bool) -> ([Element], [Element]) {
        var matching: [Element] = []
        var nonMatching: [Element] = []
        
        for element in self {
            if predicate(element) {
                matching.append(element)
            } else {
                nonMatching.append(element)
            }
        }
        
        return (matching, nonMatching)
    }
} 