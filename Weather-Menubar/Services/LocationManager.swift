import CoreLocation

class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    @Published var cityName: String?
    @Published var locationPermissionDenied = false
    
    override init() {
        super.init()
        configureLocationManager()
        requestLocation()
    }

    private func configureLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.delegate = self
    }

    func requestLocation() {
        DispatchQueue.main.async {
            self.locationManager.requestLocation()
        }
    }
    
    func getPlace(for location: CLLocation, completion: @escaping (CLPlacemark?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, preferredLocale: .current) { placemarks, error in
            guard error == nil else {
                print("Reverse geocode failed: \(error!.localizedDescription)")
                completion(nil)
                return
            }
            if let placeArray = placemarks, let placeMark = placeArray.first {
                DispatchQueue.main.async { [weak self] in
                    self?.cityName = placeMark.locality // Store the city name
                    completion(placeMark)
                }
            }
        }
    }
    
    // Handle the authorization changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined, .restricted, .denied:
            DispatchQueue.main.async {
                self.locationPermissionDenied = true
            }
        case .authorizedWhenInUse, .authorizedAlways:
            DispatchQueue.main.async {
                self.locationPermissionDenied = false
                self.locationManager.startUpdatingLocation()
            }
        default:
            break
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    // Handle location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            DispatchQueue.main.async {
                self.currentLocation = location
                self.getPlace(for: location) { placemark in
                }
            }
        }
    }

    // Handle location manager errors
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

