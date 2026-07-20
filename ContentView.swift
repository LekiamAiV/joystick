import SwiftUI
import MapKit

struct ContentView: View {

    @StateObject private var simulator = LocationSimulator()
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var followMarker = true

    var body: some View {
        ZStack(alignment: .bottom) {
            map
                .ignoresSafeArea()

            VStack(spacing: 14) {
                coordinateCard
                controlBar
            }
            .padding()
        }
        .onAppear {
            simulator.start()
            recenter()
        }
        .onChange(of: simulator.coordinate.latitude) { _, _ in
            guard followMarker else { return }
            cameraPosition = .region(
                MKCoordinateRegion(center: simulator.coordinate,
                                   latitudinalMeters: 350,
                                   longitudinalMeters: 350)
            )
        }
    }

    // MARK: - Mapa

    private var map: some View {
        Map(position: $cameraPosition) {
            Annotation("Ubicación simulada", coordinate: simulator.coordinate) {
                ZStack {
                    Circle().fill(.blue.opacity(0.2)).frame(width: 46, height: 46)
                    Circle().fill(.blue).frame(width: 18, height: 18)
                        .overlay(Circle().stroke(.white, lineWidth: 3))
                    Image(systemName: "location.north.fill")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .rotationEffect(.degrees(simulator.heading))
                }
            }
        }
        .mapControls { MapCompass() }
    }

    // MARK: - Panel de coordenadas

    private var coordinateCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Latitud").font(.caption2).foregroundStyle(.secondary)
                Text(String(format: "%.6f", simulator.coordinate.latitude))
                    .font(.system(.body, design: .monospaced).weight(.semibold))
            }
            Spacer()
            VStack(alignment: .leading, spacing: 2) {
                Text("Longitud").font(.caption2).foregroundStyle(.secondary)
                Text(String(format: "%.6f", simulator.coordinate.longitude))
                    .font(.system(.body, design: .monospaced).weight(.semibold))
            }
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Controles (joystick + velocidad + follow)

    private var controlBar: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 10) {
                Toggle("Seguir", isOn: $followMarker)
                    .toggleStyle(.button)
                    .buttonStyle(.borderedProminent)

                Button {
                    recenter()
                } label: {
                    Label("Centrar", systemImage: "scope")
                }
                .buttonStyle(.bordered)

                VStack(alignment: .leading) {
                    Text("Velocidad: \(Int(simulator.speed)) m/s")
                        .font(.caption)
                    Slider(value: $simulator.speed, in: 1...80)
                        .frame(width: 150)
                }
                .padding(10)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }

            Spacer()

            JoystickView { vector in
                simulator.updateJoystick(vector)
            }
        }
    }

    private func recenter() {
        cameraPosition = .region(
            MKCoordinateRegion(center: simulator.coordinate,
                               latitudinalMeters: 350,
                               longitudinalMeters: 350)
        )
    }
}

#Preview {
    ContentView()
}
