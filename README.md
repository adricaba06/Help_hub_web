# Help Hulp API

Bienvenido a la documentación de la API de Help Hulp. Aquí encontrarás todos los endpoints organizados por recursos, ejemplos de uso y detalles de las respuestas. Esta API está pensada para ser utilizada desde el frontend y por desarrolladores que deseen integrarse con la plataforma.

## Autenticación

Todos los endpoints protegidos requieren autenticación mediante JWT. El token se obtiene al hacer login y debe enviarse en la cabecera `Authorization: Bearer <token>`.

### Endpoints de Autenticación

- **POST /auth/login**: Iniciar sesión.
- **POST /auth/register**: Registrar un nuevo usuario.
- **POST /auth/change-password**: Cambiar la contraseña del usuario autenticado.

## Usuarios

- **PUT /user/profile**: Editar el perfil del usuario autenticado.
- **POST /user/profile/picture**: Subir foto de perfil.

## Organizaciones

- **POST /organizations**: Crear una organización (solo MANAGER).
- **GET /organizations**: Listar organizaciones del manager autenticado.
- **GET /organizations/all**: Listar todas las organizaciones (solo ADMIN).
- **GET /organizations/{id}**: Obtener detalles de una organización.
- **PUT /organizations/{id}**: Editar una organización.
- **DELETE /organizations/{id}**: Eliminar una organización.

## Oportunidades

- **POST /opportunity/add**: Crear una oportunidad (solo MANAGER).
- **GET /opportunity**: Buscar y filtrar oportunidades.
- **GET /opportunity/{id}**: Ver detalle de una oportunidad.
- **GET /opportunity/organizations/{organizationId}/opportunities**: Listar oportunidades de una organización.

## Favoritos

- **POST /favorites/{opportunityId}**: Marcar oportunidad como favorita.
- **DELETE /favorites/{opportunityId}**: Quitar de favoritos.
- **GET /favorites/me**: Listar mis favoritos.

## Solicitudes (Applications)

- **GET /applications/users/{userId}**: Listar solicitudes de un usuario.
- **GET /applications/opportunity/{opportunityId}**: Listar solicitudes de una oportunidad.
- **PATCH /applications/{id}/status**: Cambiar estado de una solicitud.
- **POST /applications/opportunities/{id}/apply**: Aplicar a una oportunidad.

## Archivos

- **POST /upload/files**: Subir múltiples archivos.
- **POST /upload**: Subir un archivo.
- **GET /download/{id}**: Descargar archivo por ID.

---

### Ejemplo de uso de autenticación

```json
POST /auth/login
{
  "email": "usuario@demo.com",
  "password": "123456"
}
```

Respuesta:
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 1,
    "email": "usuario@demo.com",
    "displayName": "Usuario Demo",
    "role": "USER"
  }
}
```

---

Para más detalles sobre cada endpoint, consulta la colección Postman incluida en el repositorio.
