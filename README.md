# Help Hup Web (Frontend)

Bienvenido al frontend de Help Hulp. Esta aplicación está desarrollada en Flutter y permite a los usuarios interactuar con la plataforma de voluntariado de forma sencilla y visual.

## Estructura del proyecto

- **lib/**: Código fuente principal de la app.
- **assets/**: Recursos estáticos (imágenes, datos, etc).
- **android/**, **ios/**, **web/**, **linux/**, **macos/**, **windows/**: Plataformas soportadas.
- **test/**: Pruebas unitarias y de widgets.

## Configuración inicial

1. Instala Flutter y las dependencias necesarias.
2. Ejecuta `flutter pub get` para instalar los paquetes.
3. Configura las variables de entorno si es necesario.
4. Ejecuta la app con `flutter run`.

## Funcionalidades principales

- Registro y login de usuarios.
- Visualización y filtrado de oportunidades de voluntariado.
- Gestión de perfil de usuario y foto de perfil.
- Aplicar a oportunidades y ver el estado de las solicitudes.
- Marcar oportunidades como favoritas.
- Gestión de organizaciones (solo managers/admins).

## Consumo de la API

La app consume la API REST documentada en el backend. Todos los endpoints requieren autenticación JWT salvo el login y el registro.

### Ejemplo de petición

```dart
final response = await http.get(
	Uri.parse('https://tudominio.com/api/opportunity'),
	headers: {
		'Authorization': 'Bearer <token>',
	},
);
```

## Pruebas

Para ejecutar los tests:

```bash
flutter test
```

---

Para más detalles sobre los endpoints y la estructura de la API, consulta el README del backend y la colección Postman incluida.