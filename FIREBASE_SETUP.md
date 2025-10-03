# 🔥 Configuración de Firebase para GreenTag

## 📋 Pasos para configurar Firebase

### 1. Crear Proyecto en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Haz clic en "Crear un proyecto"
3. Nombre del proyecto: `GreenTag`
4. Habilita Google Analytics (recomendado)
5. Acepta los términos y crea el proyecto

### 2. Configurar la aplicación iOS

1. En el proyecto de Firebase, haz clic en "Agregar app" → iOS
2. Ingresa los siguientes datos:
   - **Bundle ID**: `com.greentag.app` (o el que prefieras)
   - **Nombre de la app**: `GreenTag`
   - **App Store ID**: (opcional, puedes añadirlo después)

3. Descarga el archivo `GoogleService-Info.plist`
4. Arrastra el archivo a tu proyecto Xcode en la carpeta raíz
5. Asegúrate de que esté marcado para el target principal

### 3. Instalar Firebase SDK

#### Usando Swift Package Manager (Recomendado)

1. En Xcode, ve a `File` → `Add Package Dependencies`
2. Ingresa la URL: `https://github.com/firebase/firebase-ios-sdk`
3. Selecciona la versión más reciente
4. Añade las siguientes bibliotecas:
   - `FirebaseAuth`
   - `FirebaseFirestore`
   - `FirebaseStorage`
   - `FirebaseAnalytics`
   - `FirebaseCrashlytics` (opcional)
   - `FirebaseMessaging` (para notificaciones push)

#### Usando CocoaPods

Añade al `Podfile`:

```ruby
platform :ios, '15.0'

target 'GreenTag' do
  use_frameworks!

  # Firebase
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Messaging'
end
```

### 4. Configurar Firebase en la aplicación

#### App.swift

```swift
import SwiftUI
import Firebase

@main
struct GreenTagApp: App {
    
    init() {
        FirebaseConfig.shared.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AuthViewModel())
        }
    }
}
```

### 5. Configurar Authentication

#### Métodos de autenticación habilitados:

1. Ve a `Authentication` → `Sign-in method`
2. Habilita:
   - **Email/Password**
   - **Google** (opcional, para login social)
   - **Apple** (opcional, requerido para App Store)

#### Configurar dominios autorizados:

- Añade los dominios donde se ejecutará tu app (para desarrollo local)

### 6. Configurar Firestore Database

#### Crear la base de datos:

1. Ve a `Firestore Database` → `Crear base de datos`
2. Elige el modo:
   - **Modo de prueba** (para desarrollo)
   - **Modo de producción** (con reglas de seguridad)

#### Ubicación:

- Selecciona la región más cercana a tus usuarios (ej: `europe-west1` para Europa)

#### Reglas de seguridad:

Usa las reglas definidas en `FirebaseConfig.swift`:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Products collection
    match /products/{productId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == resource.data.sellerId;
      allow update, delete: if request.auth != null && request.auth.uid == resource.data.sellerId;
    }
    
    // Reviews collection
    match /reviews/{reviewId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == resource.data.reviewerId;
      allow update, delete: if request.auth != null && request.auth.uid == resource.data.reviewerId;
    }
    
    // Shipments collection
    match /shipments/{shipmentId} {
      allow read, write: if request.auth != null && 
        (request.auth.uid == resource.data.buyerId || request.auth.uid == resource.data.sellerId);
    }
    
    // Rankings collection
    match /rankings/{rankingId} {
      allow read: if request.auth != null;
      allow write: if false; // Only server can write rankings
    }
  }
}
```

### 7. Configurar Storage

#### Crear bucket de almacenamiento:

1. Ve a `Storage` → `Comenzar`
2. Elige las reglas de seguridad (modo de prueba para desarrollo)
3. Selecciona la ubicación (misma que Firestore)

#### Reglas de Storage:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // User profile images
    match /user_profiles/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Product images
    match /product_images/{productId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

### 8. Variables de Entorno

#### Crear archivo de configuración:

```swift
// Config.swift
struct Config {
    static let environment: FirebaseEnvironment = .development
    
    struct Firebase {
        static let projectId = "greentag-dev"
        static let storageBucket = "greentag-dev.appspot.com"
        static let databaseURL = "https://greentag-dev-default-rtdb.firebaseio.com/"
    }
    
    struct App {
        static let version = "1.0.0"
        static let buildNumber = "1"
    }
}
```

### 9. Índices de Firestore

#### Crear índices para consultas complejas:

1. Ve a `Firestore` → `Índices`
2. Añade los siguientes índices compuestos:

**Productos:**
- Colección: `products`
- Campos: `category` (Ascending), `createdAt` (Descending)
- Campos: `sellerId` (Ascending), `createdAt` (Descending)
- Campos: `isActive` (Ascending), `createdAt` (Descending)

**Rankings:**
- Colección: `rankings`
- Campos: `type` (Ascending), `period` (Ascending), `points` (Descending)

### 10. Configurar Notificaciones Push (Opcional)

#### APNs Configuration:

1. Ve a `Project Settings` → `Cloud Messaging`
2. Sube tu certificado APNs o clave de autenticación
3. Configura el Bundle ID

#### En Xcode:

1. Habilita `Push Notifications` capability
2. Añade `FirebaseMessaging` al proyecto

### 11. Testing y Debugging

#### Firebase Emulator Suite (Para desarrollo):

```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Inicializar Firebase en tu proyecto
firebase init

# Ejecutar emuladores locales
firebase emulators:start
```

#### Configurar emuladores en la app:

```swift
#if DEBUG
func connectToFirebaseEmulator() {
    let settings = Firestore.firestore().settings
    settings.host = "localhost:8080"
    settings.isPersistenceEnabled = false
    settings.isSSLEnabled = false
    Firestore.firestore().settings = settings
    
    Auth.auth().useEmulator(withHost: "localhost", port: 9099)
    Storage.storage().useEmulator(withHost: "localhost", port: 9199)
}
#endif
```

### 12. Monitoreo y Analytics

#### Configurar Analytics:

1. Los eventos están definidos en `FirebaseAnalyticsEvents`
2. Firebase Analytics se configura automáticamente

#### Configurar Crashlytics:

1. Añade el script de build phase en Xcode
2. Los crashes se reportarán automáticamente

## 🔧 Comandos útiles

```bash
# Ver logs de Firebase en tiempo real
firebase functions:log --follow

# Desplegar reglas de Firestore
firebase deploy --only firestore:rules

# Desplegar reglas de Storage
firebase deploy --only storage

# Backup de Firestore
gcloud firestore export gs://[BUCKET_NAME]
```

## 📱 Configuración de Info.plist

Añade las siguientes configuraciones a tu `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>GreenTag necesita acceso a la cámara para tomar fotos de productos</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>GreenTag necesita acceso a la galería para seleccionar imágenes de productos</string>

<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>REVERSED_CLIENT_ID</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

## 🚀 Listo para usar

Una vez completados estos pasos, tu aplicación GreenTag estará completamente integrada con Firebase y lista para:

- ✅ Autenticación de usuarios
- ✅ Base de datos en tiempo real
- ✅ Almacenamiento de imágenes
- ✅ Analytics y monitoreo
- ✅ Notificaciones push
- ✅ Escalabilidad automática

¡Tu marketplace ecológico está listo para conquistar el mundo! 🌱🚀