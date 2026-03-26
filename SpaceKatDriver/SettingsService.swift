import Foundation

/// Service for managing application settings
public class SettingsService {
    private let userDefaults = UserDefaults.standard
    private let settingsKey = "SpaceKatSettings"
    
    /// Load settings from user defaults
    public func loadSettings() -> Settings {
        guard let data = userDefaults.data(forKey: settingsKey) else {
            return Settings.default
        }
        
        do {
            let settings = try JSONDecoder().decode(Settings.self, from: data)
            return settings
        } catch {
            print("Failed to decode settings: \(error)")
            return Settings.default
        }
    }
    
    /// Save settings to user defaults
    public func saveSettings(_ settings: Settings) {
        do {
            let data = try JSONEncoder().encode(settings)
            userDefaults.set(data, forKey: settingsKey)
        } catch {
            print("Failed to encode settings: \(error)")
        }
    }
    
    /// Reset settings to default
    public func resetSettings() {
        userDefaults.removeObject(forKey: settingsKey)
    }
}