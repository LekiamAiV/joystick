# JoystickLocation

App de iOS (SwiftUI) que muestra un mapa y permite **mover un marcador de ubicación con un joystick** en pantalla. Al arrastrar el joystick, el punto se desplaza por el mapa en tiempo real; puedes ajustar la velocidad y mantener la cámara centrada.

## Qué hace (y qué no hace)

- **Sí:** mueve una ubicación *simulada dentro de la propia app*. Perfecto para demos, prototipos de juegos basados en localización, pruebas de UI de mapas o enseñar CoreLocation/MapKit.
- **No:** no cambia el GPS real del dispositivo ni engaña a otras apps del sistema. Ese tipo de "falseo" global de ubicación requiere jailbreak y va contra las normas de la App Store, así que no está contemplado aquí.

Si lo que necesitas es **probar cómo reacciona tu propia app a distintas ubicaciones**, la vía oficial es simular la ubicación desde Xcode (menú *Debug ▸ Simulate Location*, o cargar un archivo `.gpx` para simular una ruta). Eso lo entiende el sistema en modo desarrollo sin trucos.

## Montaje en Xcode

1. Abre Xcode y crea un proyecto nuevo: **App** → interfaz **SwiftUI**, lenguaje **Swift**. Nómbralo `JoystickLocation`.
2. Sustituye/añade estos archivos en el proyecto:
   - `JoystickLocationApp.swift`
   - `ContentView.swift`
   - `LocationSimulator.swift`
   - `JoystickView.swift`
3. Requiere **iOS 17+** (usa la API nueva de `Map`).
4. Ejecuta en el simulador o en un dispositivo real. No hace falta pedir permisos de ubicación porque no se usa el GPS real.

## Estructura

| Archivo | Responsabilidad |
|---|---|
| `LocationSimulator.swift` | Guarda la coordenada simulada y la desplaza 30 veces por segundo según el vector del joystick. |
| `JoystickView.swift` | Control de joystick analógico reutilizable; devuelve un vector normalizado (-1…1). |
| `ContentView.swift` | Mapa, panel de coordenadas, control de velocidad y "seguir". |

## Ideas para ampliar

- Guardar y reproducir rutas grabadas.
- Botón para "teletransportar" tocando el mapa (`teleport(to:)` ya está preparado).
- Exportar la trayectoria a `.gpx`.
