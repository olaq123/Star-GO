import FirebaseFirestore
import FirebaseAuth

/// This file contains the database schema and initial setup for Firestore
struct FirestoreSetup {
    static let shared = FirestoreSetup()
    private let db = Firestore.firestore()
    
    // MARK: - Collection Names
    struct Collections {
        static let users = "users"
        static let planets = "planets"
        static let gameStates = "gameStates"
        static let research = "research"
        static let fleets = "fleets"
    }
    
    // MARK: - Initial Setup
    func setupInitialData() async throws {
        // First verify connection
        try await verifyConnection()
        
        // Create initial research options
        try await setupResearchTree()
        
        // Create initial planet types
        try await setupPlanetTypes()
    }
    
    // MARK: - Connection Test
    private func verifyConnection() async throws {
        let testDoc = db.collection("_test").document("connection")
        try await testDoc.setData([
            "timestamp": FieldValue.serverTimestamp(),
            "status": "connected"
        ])
        try await testDoc.delete()
        print("✅ Firebase connection verified successfully!")
    }
    
    private func setupResearchTree() async throws {
        let researchTypes = [
            "weapons": [
                "name": "Advanced Weapons",
                "description": "Improve your fleet's attack power",
                "levels": 5,
                "baseCost": 1000,
                "costMultiplier": 1.5
            ],
            "shields": [
                "name": "Shield Technology",
                "description": "Enhance your fleet's defense",
                "levels": 5,
                "baseCost": 1000,
                "costMultiplier": 1.5
            ],
            "propulsion": [
                "name": "Propulsion Systems",
                "description": "Increase fleet speed and range",
                "levels": 5,
                "baseCost": 1200,
                "costMultiplier": 1.6
            ],
            "economy": [
                "name": "Economic Development",
                "description": "Improve resource generation",
                "levels": 5,
                "baseCost": 800,
                "costMultiplier": 1.4
            ]
        ]
        
        for (id, data) in researchTypes {
            try await db.collection(Collections.research)
                .document(id)
                .setData(data, merge: true)
        }
        print("✅ Research tree initialized successfully!")
    }
    
    private func setupPlanetTypes() async throws {
        let planetTypes = [
            "terrestrial": [
                "name": "Terrestrial Planet",
                "resourceMultiplier": 1.0,
                "maxPopulation": 1000000,
                "buildingSlots": 10
            ],
            "gas_giant": [
                "name": "Gas Giant",
                "resourceMultiplier": 1.5,
                "maxPopulation": 500000,
                "buildingSlots": 8
            ],
            "desert": [
                "name": "Desert Planet",
                "resourceMultiplier": 0.8,
                "maxPopulation": 800000,
                "buildingSlots": 12
            ],
            "ice": [
                "name": "Ice Planet",
                "resourceMultiplier": 0.7,
                "maxPopulation": 600000,
                "buildingSlots": 9
            ]
        ]
        
        for (id, data) in planetTypes {
            try await db.collection("planetTypes")
                .document(id)
                .setData(data, merge: true)
        }
        print("✅ Planet types initialized successfully!")
    }
}
