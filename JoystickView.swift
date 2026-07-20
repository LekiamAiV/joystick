import SwiftUI

/// Joystick analógico. Devuelve un vector con rango -1...1 en cada eje.
/// Convención: hacia arriba = +y (norte), hacia la derecha = +x (este).
struct JoystickView: View {

    /// Se llama cada vez que cambia la posición del joystick.
    var onChange: (CGVector) -> Void

    var baseRadius: CGFloat = 75
    var knobRadius: CGFloat = 32

    @State private var knobOffset: CGSize = .zero

    private var limit: CGFloat { baseRadius - knobRadius }

    var body: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .overlay(Circle().stroke(.white.opacity(0.3), lineWidth: 1))
                .frame(width: baseRadius * 2, height: baseRadius * 2)

            // Cruz guía
            Group {
                Capsule().fill(.white.opacity(0.15)).frame(width: 2, height: baseRadius * 1.4)
                Capsule().fill(.white.opacity(0.15)).frame(width: baseRadius * 1.4, height: 2)
            }

            Circle()
                .fill(Color.accentColor.gradient)
                .frame(width: knobRadius * 2, height: knobRadius * 2)
                .overlay(Circle().stroke(.white.opacity(0.8), lineWidth: 2))
                .shadow(color: .black.opacity(0.35), radius: 6, y: 3)
                .offset(knobOffset)
                .animation(.interactiveSpring(response: 0.2, dampingFraction: 0.7), value: knobOffset)
        }
        .contentShape(Circle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    var dx = value.translation.width
                    var dy = value.translation.height
                    let dist = hypot(dx, dy)
                    if dist > limit {
                        dx = dx / dist * limit
                        dy = dy / dist * limit
                    }
                    knobOffset = CGSize(width: dx, height: dy)
                    // Normalizamos e invertimos Y para que "arriba" sea norte.
                    onChange(CGVector(dx: dx / limit, dy: -dy / limit))
                }
                .onEnded { _ in
                    knobOffset = .zero
                    onChange(.zero)
                }
        )
    }
}
