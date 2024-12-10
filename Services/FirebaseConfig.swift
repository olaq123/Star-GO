import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class FirebaseConfig {
    static let shared = FirebaseConfig()
    private(set) var db: Firestore!
    
    private init() {
        setupFirestore()
    }
    
    private func setupFirestore() {
        // Ensure Firebase is configured
        guard let _ = FirebaseApp.app() else {
            fatalError("Firebase must be configured before initializing FirebaseConfig")
        }
        
        db = Firestore.firestore()
        
        // Configure Firestore settings
        let settings = FirestoreSettings()
        // Enable offline persistence with unlimited cache size
        settings.cacheSettings = PersistentCacheSettings(
            sizeBytes: NSNumber(value: Int(FirestoreCacheSizeUnlimited))
        )
        // Enable SSL for secure connections
        settings.isSSLEnabled = true
        
        db.settings = settings
        
        #if DEBUG
        // Enable more detailed logging in debug mode
        Firestore.enableLogging(true)
        #endif
        
        // Enable network by default
        db.enableNetwork { error in
            if let error = error {
                print("Error enabling Firestore network: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Database Setup
    func initializeGameData() async throws {
        try await FirestoreSetup.shared.setupInitialData()
    }
    
    // MARK: - Auth Methods
    var auth: Auth {
        return Auth.auth()
    }
    
    var isUserSignedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    
    var currentUserId: String? {
        return Auth.auth().currentUser?.uid
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    // MARK: - Network Management
    func clearCache() async throws {
        try await db.clearPersistence()
    }
    
    func setOfflineMode(_ offline: Bool) async {
        if offline {
            try? await db.disableNetwork()
        } else {
            try? await db.enableNetwork()
        }
    }
    
    // MARK: - Test Connection
    func testConnection() async throws {
        let testDoc = db.collection("_test").document()
        try await testDoc.setData([
            "timestamp": FieldValue.serverTimestamp(),
            "test": "Connection successful"
        ])
        try await testDoc.delete()  // Clean up after test
    }
    
    // MARK: - Testing
    #if DEBUG
    func runConnectionTest() async throws -> Bool {
        let testDoc = db.collection("_test").document("connection")
        try await testDoc.setData([
            "timestamp": FieldValue.serverTimestamp(),
            "status": "connected"
        ])
        try await testDoc.delete()
        return true
    }
    #endif
    
    func testConnectionOld() async throws -> Bool {
        do {
            let testDoc = db.collection("_test").document("connection")
            try await testDoc.setData([
                "status": "connected",
                "timestamp": FieldValue.serverTimestamp()
            ])
            return true
        } catch let error as NSError {
            print("Firebase connection test failed: \(error.localizedDescription)")
            if error.domain == FirestoreErrorDomain {
                switch error.code {
                case FirestoreErrorCode.unavailable.rawValue:
                    print("Network connection unavailable")
                case FirestoreErrorCode.permissionDenied.rawValue:
                    print("Permission denied - check Firestore rules")
                default:
                    print("Other Firestore error: \(error.code)")
                }
            }
            throw error
        }
    }
}
