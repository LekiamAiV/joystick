import Foundation
import CoreLocation

/// Mantiene una ubicación *simulada* y la va desplazando según el vector del joystick.
///
/// Importante: esta clase mueve un punto en el mapa DENTRO de la propia app.
/// No modifica el GPS real del dispositivo ni engaña a otras apps del sistema.
@MainActor
final class LocationSimulator: ObservableObject {

    /// Coordenada actual simulada.
    @Published var coordinate: CLLocationCoordinate2D

    /// Velocidad base en metros por segundo (a joystick al máximo).
    @Published var speed: Double = 8.0

    /// Rumbo en grados (0 = norte), útil para orientar un icono.
    @Published var heading: Double = 0

    /// Indica si el simulador está corriendo.
    @Published private(set) var isRunning = false

    /// Vector del joystick: x = este(+)/oeste(-), y = norte(+)/sur(-), rango -1...1.
    private var joystickVector: CGVector = .zero

    private var timer: Timer?
    private let updateInterval: TimeInterval = 1.0 / 30.0 // 30 Hz

    init(start: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038)) {
        self.coordinate = start
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    /// Recibe el vector normalizado del joystick.
    func updateJoystick(_ vector: CGVector) {
        joystickVector = vector
    }

    /// Reposiciona el punto a una coordenada concreta.
    func teleport(to coord: CLLocationCoordinate2D) {
        coordinate = coord
    }

    private func tick() {
        let raw = hypot(joystickVector.dx, joystickVector.dy)
        guard raw > 0.02 else { return }          // zona muerta central

        let magnitude = min(raw, 1.0)             // intensidad 0...1
        let normX = joystickVector.dx / raw       // dirección normalizada
        let normY = joystickVector.dy / raw

        let meters = speed * updateInterval * magnitude

        // Conversión metros -> grados
        let metersPerDegreeLat = 111_320.0
        let metersPerDegreeLon = 111_320.0 * cos(coordinate.latitude * .pi / 180)

        let deltaLat = (normY * meters) / metersPerDegreeLat
        let deltaLon = (normX * meters) / max(metersPerDegreeLon, 0.0001)

        var newLat = coordinate.latitude + deltaLat
        var newLon = coordinate.longitude + deltaLon

        newLat = min(max(newLat, -90), 90)
        if newLon > 180 { newLon -= 360 }
        if newLon < -180 { newLon += 360 }

        coordinate = CLLocationCoordinate2D(latitude: newLat, longitude: newLon)
        heading = atan2(normX, normY) * 180 / .pi
    }
}
