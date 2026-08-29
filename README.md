# Sistema legado xBase/Clipper

Este directorio contiene una copia de trabajo saneada del sistema xBase/Clipper.
El 28 de agosto de 2026 se reemplazaron todos los registros DBF originales por
un conjunto pequeno de datos completamente ficticios y se eliminaron los
indices binarios NTX/CDX.

## Punto de entrada

- `MENU.PRG`: fuente principal y version mas reciente del menu.
- `MENU1.PRG`: copia historica anterior; usar solo para comparar cambios.
- Los demas `*.PRG`: utilidades y procesos auxiliares.
- Los `*.DBF`: estructuras originales con registros demo.

Los archivos operativos siguen en la raiz a proposito. El codigo abre tablas e
indices mediante rutas relativas; moverlos a `src/` o `data/` cambiaria el
comportamiento del programa legado.

## Datos de demostracion

- Reservas: `900001`, `900002`, `900003`.
- Parcelas/codigos: `D010101`, `D010102`, `D020101`.
- Documentos: serie reservada ficticia `99000001` en adelante.
- Usuario demo: `BOB`; clave demo: `DEMO`.
- Clave demo de la llamada legada `Pass1()`: `DEMO00`.

La llamada a `Contrasenia()` esta comentada actualmente en `MENU.PRG`, por lo
que ese usuario solo sera necesario si se reactiva el control de acceso.

Los textos privados incrustados en los PRG fueron sustituidos por rotulos como
`EMPRESA DEMO`, `DOMICILIO FICTICIO`, `Plan Demo` y `Cocheria Demo`.

## Navegacion para IBM Bob

Leer primero `AGENTS.md`. Es el contrato persistente del proyecto: explica el
objetivo del hackathon, el estado del legado, las restricciones de privacidad,
los agentes especializados, las tareas y las puertas de aprobacion.

Antes de abrir la carpeta con Bob, confirmar que no exista
`_resguardo_privado/` ni otro respaldo con datos originales.

Al iniciar el programa, `OpenDbf()` en `MENU.PRG` vuelve a generar varios NTX
si no existen. Es normal que reaparezcan luego de ejecutar el sistema.
