# Recetarium - Mushroom Chef 🍄‍🟫

Proyecto Flutter para la gestión y exploración de recetas, diseñado con una arquitectura modular y moderna.

## Requisitos Previos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (^3.5.2)
- [Dart SDK](https://dart.dev/get-started)
- Un emulador (Android/iOS) o dispositivo físico conectado.

## Instalación y Configuración

1. **Clonar el repositorio:**
   ```bash
   git clone <url-del-repositorio>
   cd recetarium_flutter
   ```

2. **Instalar dependencias:**
   ```bash
   flutter pub get
   ```

3. **Configuración de la API:**
   Las URLs de la API se gestionan en `lib/src/core/config/env.dart`. Por defecto, para desarrollo local se utiliza:
   - `apiUrlLocal`: `http://127.0.0.1:3000` (ajustar si es necesario).
   
   *Nota: Algunos servicios de autenticación como OTP pueden requerir el puerto 3003 según la configuración del servidor.*

## Ejecución

Para iniciar la aplicación en tu dispositivo o emulador:

```bash
flutter run
```

## Estructura del Proyecto

El proyecto está organizado siguiendo principios de arquitectura limpia y basada en características:

- **`lib/src/features/`**: Contiene la lógica de negocio y UI dividida por módulos (Auth, Recipes, Shopping Cart, User Profile).
- **`lib/src/core/`**: Centraliza configuraciones, temas globales (`AppTheme`), widgets reutilizables y el cliente base de API (`RecetasAPI`).
- **`lib/src/routing/`**: Define las rutas de navegación utilizando `go_router`.

## Funcionalidades Recientes

### Autenticación con OTP
Se ha implementado un flujo de verificación de cuenta mediante código de 6 dígitos:
- **Pantalla UI**: `lib/src/features/auth/ui/otp_verification_screen.dart` (Diseño basado en Mushroom Chef).
- **Servicio API**: `lib/src/features/auth/data/auth_api_service.dart`.
- **Integración**: Manejado a través de `AuthProvider`.

## Contribución

1. Crea una rama para tu funcionalidad (`git checkout -b feature/nueva-funcionalidad`).
2. Realiza tus cambios y haz commit (`git commit -m 'Añadir nueva funcionalidad'`).
3. Sube tus cambios (`git push origin feature/nueva-funcionalidad`).
4. Abre un Pull Request.
