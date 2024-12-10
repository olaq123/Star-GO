protocol GameState: Codable, Decodable {
    var currentPlayer: Player? { get set }
    var planets: [Planet] { get set }
    
    func hasPlanetNearby(_ location: Location, within distance: Double) -> Bool
} 