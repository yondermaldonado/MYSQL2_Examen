# MYSQL2_Examen

Estudiante: Yonder Maldonado

## Examen Integración de Datos Externos

### Contexto

El coworking ahora acepta reservas desde una plataforma externa (como Airbnb o Meetup). Debes integrar esos datos.

### Tarea 

1. Crear una tabla ReservasExternas con: id, plataforma, fecha_reserva, espacio_id, usuario_externo, duración.
2. Escribir un procedimiento sp_importar_reserva_externa que:
├── Convierta una reserva externa en una reserva interna.
├── Asigne el espacio correcto.
├── Genere un usuario temporal si no existe.
3. Validar que no haya conflictos de horario con reservas existentes.

### Resultado

-Se creo la tabla reservas_externas donde se guardan las reservas creadas de fuentes externas

-se creo la el procedimiento sp_importar_reserva_externa que valida una reserva externa si exite, si tiene usuario y si el espacio esta disponible, si todo esta correcto inserta un usuario nuevo (si no existe)y crea una nueva reserva

### Evidencia

-procedimiento funcionando

![Imagen](/Captura%20desde%202026-10-08%2015-35-49.png)

