import Foundation
import CoreLocation
import Combine

/// Manages location permissions and fetches the current city name.
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var currentCity: String = ""
    @Published var temperature: Int = 18 // Simulated realistic default temp
    @Published var weatherIcon: String = "sun.max.fill"
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        manager.stopUpdatingLocation()
        
        // Reverse Geocode to get the city name
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            if let placemark = placemarks?.first {
                let city = placemark.locality ?? placemark.administrativeArea ?? "Konum"
                
                DispatchQueue.main.async {
                    self.currentCity = city
                    self.simulateWeatherOptions()
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }
    
    /// Simulates a weather condition for visual flair
    private func simulateWeatherOptions() {
        let conditions = [
            (temp: 18, icon: "sun.max.fill"),
            (temp: 22, icon: "cloud.sun.fill"),
            (temp: 15, icon: "cloud.fill"),
            (temp: 19, icon: "sun.max.fill")
        ]
        if let random = conditions.randomElement() {
            temperature = random.temp
            weatherIcon = random.icon
        }
    }
}
