# MYSQL2_Examen

Estudiante: Yonder Maldonado

## Examen Integración de Datos Externos

### Contexto

El coworking ahora acepta reservas desde una plataforma externa (como Airbnb o Meetup). Debes integrar esos datos.

### Tarea 

**1. Crear la tabla `ReservasExternas`**

La tabla debe contener los siguientes campos:

* `id`
* `plataforma`
* `fecha_reserva`
* `espacio_id`
* `usuario_externo`
* `duracion`

**2. Crear el procedimiento almacenado `sp_importar_reserva_externa`**

El procedimiento debe realizar las siguientes operaciones:

* Convertir una reserva externa en una reserva interna.
* Asignar el espacio correspondiente.
* Generar un usuario temporal si el usuario no existe.

**3. Validar conflictos de horario**

* Verificar que no existan conflictos de horario con las reservas internas existentes.
* Evitar que se asignen dos reservas al mismo espacio durante horarios que se superpongan.


### Resultado

-Se creo la tabla reservas_externas donde se guardan las reservas creadas de fuentes externas

-se creo la el procedimiento sp_importar_reserva_externa que valida una reserva externa si exite, si tiene usuario y si el espacio esta disponible, si todo esta correcto inserta un usuario nuevo (si no existe)y crea una nueva reserva

### Evidencia

-procedimiento funcionando

![Imagen](/Captura%20desde%202026-10-08%2015-35-49.png)

