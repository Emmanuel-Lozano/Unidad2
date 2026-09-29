USE ReservasCanchas;
GO

INSERT INTO UsuarioDeportivo (nombres, apellidos, documento, telefono, correo, estado)
VALUES ('Sofia', 'Herrera', '1011', '3011111111', 'sofia.herrera@mail.com', 'Activo');
GO

---Mostrar los usuarios junto con la información de sus reservas
SELECT u.idUsuario, u.nombres, u.apellidos, r.idReserva, r.estado
FROM UsuarioDeportivo u
LEFT JOIN Reserva r ON u.idUsuario = r.idUsuario;
GO

---Contar cuántas reservas existen agrupadas por su estado (Group by)
SELECT estado, COUNT(*) AS CantidadReservas
FROM Reserva
GROUP BY estado;
GO

SELECT COUNT (*) AS CantidadActivas
FROM Reserva
WHERE estado = 'Activo';

---Agregar temporalmente el campo ciudad y lo elimina
ALTER TABLE UsuarioDeportivo
ADD ciudad varchar(20);

ALTER TABLE UsuarioDeportivo
DROP COLUMN ciudad;

---Altera el tamaño de la capacidad de la columna telefono de 20 caracteres a 30
ALTER TABLE UsuarioDeportivo
ALTER COLUMN telefono varchar(30) not null;

---Se agregar el atributo idUsuario a la tabla Pago y crear la restricción de clave foránea hacia UsuarioDeportivo
ALTER TABLE Pago
ADD idUsuario INT;
GO

ALTER TABLE Pago
ADD CONSTRAINT FK_Pago_Usuario
FOREIGN KEY (idUsuario)
REFERENCES UsuarioDeportivo(idUsuario);
GO

---Pruebas de la FK
UPDATE Pago SET idUsuario = 999 WHERE idPago = 1;
UPDATE Pago SET idUsuario = 1 WHERE idPago = 1;

---Agrega una restricción CHECK al telefono del Usuario que impide guardar valores que no sean numéricos.
ALTER TABLE UsuarioDeportivo
ADD CONSTRAINT CK_UsuarioDeportivo_Telefono
CHECK (telefono NOT LIKE '%[^0-9]%');
GO

---Usa el procedimiento sp_rename para cambiar el nombre de una tabla de prueba que luego se elimina
CREATE TABLE TablaDePruebas (
	id Int IDENTITY (1,1),
	descripcion varchar(30)
);
GO

EXEC sp_rename 'TablaDePruebas', 'RenombrarTabla';
GO

EXEC sp_rename 'RenombrarTabla.descripcion', 'detalle', 'COLUMN';
GO

SELECT * FROM RenombrarTabla;

DROP TABLE RenombrarTabla;
GO

--Crear un índice no agrupado sobre el campo 'apellidos' de UsuarioDeportivo
--CREATE NONCLUSTERED INDEX I_UsuarioDeportivo_apellidos
--ON UsuarioDeportivo(apellidos);
GO

--SELECT idUsuario, nombres, apellidos
--FROM UsuarioDeportivo
--WHERE apellidos = 'Torres';

---Listar las canchas de tipo Fútbol o Tenis que estén en estado Disponible.
SELECT idCancha, nombre, tipo, estado
FROM Cancha
WHERE (tipo = 'Futbol' OR tipo = 'Tenis')
AND estado = 'Disponible'

---Listar los pagos con un valor de 40.000 o más que no se hayan hecho en efectivo.
SELECT idPago, idReserva, valor, metodoPago
FROM Pago
WHERE valor >= 40000
AND metodoPago <> 'Efectivo';

---Listar los pagos que aún no tienen a ningun usuario asociado en la columna
SELECT idPago, idReserva, valor, idUsuario
FROM Pago
WHERE idUsuario IS NULL;

---Listar los usuarios que nunca han hecho una reserva.
SELECT u.idUsuario, u.nombres, u.apellidos
FROM UsuarioDeportivo u
LEFT JOIN Reserva r ON u.idUsuario = r.idUsuario
WHERE r.idReserva IS NULL;

---Listar todas las canchas con sus horarios incluyendo las canchas que no tienen ningún horario registrado.
SELECT c.idCancha, c.nombre, h.idHorario, h.fecha, h.horaInicio
FROM Cancha c
LEFT JOIN Horario h ON c.idCancha = h.idCancha;

---Listar todos los usuarios con su reserva, incluyendo los que no han reservado, usando RIGHT JOIN///.
SELECT r.idReserva, r.estado, u.idUsuario, u.nombres
FROM Reserva r
RIGHT JOIN UsuarioDeportivo u ON r.idUsuario = u.idUsuario;
GO

---Muestra el total recaudado por cada método de pago, pero solo visualiza los métodos cuyo total supere los 90.000.
SELECT metodoPago, SUM(valor) AS Total
FROM Pago
GROUP BY metodoPago
HAVING SUM(valor) > 90000;
GO

---Mostrar los tipos de cancha que tienen más de 2 canchas registradas en la base.
SELECT tipo, COUNT(*) AS CantidadCanchas
FROM Cancha
GROUP BY tipo
HAVING COUNT(*) > 2

---Listar las canchas que tienen horario registrado
SELECT idCancha, nombre, tipo
FROM Cancha
WHERE idCancha IN (SELECT idCancha FROM Horario);

---Listar las canchas que no tienen ningún horario registrado.
SELECT idCancha, nombre, tipo
FROM Cancha
WHERE idCancha NOT IN (SELECT idCancha FROM Horario);

---Listar los usuarios que no tienen ninguna reserva
SELECT idUsuario, nombres, apellidos
FROM UsuarioDeportivo
WHERE idUsuario NOT IN (SELECT idUsuario FROM Reserva);

---Listar los usuarios que tienen alguna reserva
SELECT idUsuario, nombres, apellidos
FROM UsuarioDeportivo
WHERE idUsuario IN (SELECT idUsuario FROM Reserva);

---Obtener una sola lista con los nombres de las canchas de tipo Fútbol y los de tipo Tenis
SELECT c.idCancha, nombre, tipo
FROM Cancha c
WHERE tipo = 'Futbol'
UNION
SELECT c.idCancha, nombre, tipo
FROM Cancha c
WHERE tipo = 'Tenis';

---Encontrar a los usuarios que tienen reservas Activas y que también han pagado por Transferencia
SELECT idUsuario
FROM Reserva
WHERE estado = 'Activa'
INTERSECT
SELECT u.idUsuario
FROM UsuarioDeportivo u
INNER JOIN Reserva ON u.idUsuario = Reserva.idUsuario
INNER JOIN Pago ON Reserva.idReserva = Pago.idReserva
WHERE Pago.metodoPago = 'Transferencia';

---Listar a los usuarios que tienen reserva, excepto a los que han pagado en efectivo
SELECT u.idUsuario
FROM UsuarioDeportivo u
INNER JOIN Reserva r ON u.idUsuario = r.idUsuario
EXCEPT
SELECT u.idUsuario
FROM UsuarioDeportivo u
INNER JOIN Reserva r ON u.idUsuario = r.idUsuario
INNER JOIN Pago p ON r.idReserva = p.idReserva
WHERE p.metodoPago = 'Efectivo';

---Mostrar los nombres de los usuarios en mayúsculas y sus apellidos en minúsculas
SELECT idUsuario, UPPER(nombres) AS NombreMayus, LOWER(apellidos) AS ApellidoMinus
FROM UsuarioDeportivo;

---Mostrar el prefijo del numero de celular de cada usuario
SELECT idUsuario, telefono, SUBSTRING(telefono, 1, 3) AS Prefijo
FROM UsuarioDeportivo;

---Mostrar el nombre completo de cada usuario y añadirle su numero al lado
SELECT idUsuario, CONCAT(nombres, ' ', apellidos, ' - ', telefono) AS DatosUsuario
FROM UsuarioDeportivo;

---Mostrar el día, mes y año por separado de la reserva, y la fecha/hora actual
SELECT idReserva, DAY(fechaReserva) AS Dia, MONTH(fechaReserva) AS Mes, YEAR(fechaReserva) AS Anio, GETDATE() AS FechaActual
FROM Reserva;

---Calcular cuántos días han pasado desde la fecha de reserva hasta el momento
SELECT idReserva, fechaReserva, DATEDIFF(DAY, fechaReserva, GETDATE()) AS Dias_Transcurridos
FROM Reserva;

---Calcular la diferencia, siempre en positivo, entre el valor de cada pago y un promedio de referencia de 100.000
SELECT idPago, ABS(valor - 100000) AS DiferenciaAbsoluta
FROM Pago;

---Calcular la raíz cuadrada del valor de cada pago
SELECT idPago, SQRT(valor) AS RaizCuadrada
FROM Pago;

---Elevar al cuadrado el valor de cada pago
SELECT idPago, POWER(valor, 2) AS Valor_Al_Cuadrado
FROM Pago;

---Convertir el valor de cada pago a texto para concatenarlo en un sting
SELECT idPago, CONCAT('Valor pagado: $', CAST(valor AS VARCHAR(20))) AS DetallePago
FROM Pago;

---Mostrar los 3 pagos de mayor valor
SELECT TOP 3 idPago, valor, metodoPago
FROM Pago
ORDER BY valor DESC;

---Listar, sin repetir, los métodos de pago que se han usado
SELECT DISTINCT metodoPago
FROM Pago;
GO

---Crear una vista que muestre el total pagado por cada usuario, teniendo en cuenta únicamente las reservas en estado Activa
CREATE VIEW VistaTotalPagadoPorUsuarioActivo AS
SELECT u.idUsuario, u.nombres, u.apellidos, SUM(p.valor) AS TotalPagado
FROM Pago p
INNER JOIN Reserva r ON p.idReserva = r.idReserva
INNER JOIN Horario h ON r.idHorario = h.idHorario
INNER JOIN UsuarioDeportivo u ON r.idUsuario = u.idUsuario
WHERE r.estado = 'Activa'
GROUP BY u.idUsuario, u.nombres, u.apellidos;
GO
--SELECT * FROM VistaTotalPagadoPorUsuarioActivo;

---Crear una vista que muestre la cantidad de reservas por cancha, únicamente para las canchas de Fútbol
CREATE OR ALTER VIEW VistaReservasPorCanchaFutbol AS
SELECT c.idCancha, c.nombre AS NombreCancha, COUNT(*) AS CantidadReservas
FROM Reserva r
INNER JOIN Horario h ON r.idHorario = h.idHorario
INNER JOIN Cancha c ON h.idCancha = c.idCancha
INNER JOIN UsuarioDeportivo u ON r.idUsuario = u.idUsuario
WHERE c.tipo = 'Futbol'
GROUP BY c.idCancha, c.nombre;
GO
--SELECT * FROM VistaReservasPorCanchaFutbol;

---Crear una vista que muestre los usuarios cuyo total pagado supera los 50.000
CREATE OR ALTER VIEW VistaUsuariosAltoPago AS
SELECT u.idUsuario, u.nombres, u.apellidos, SUM(p.valor) AS TotalPagado
FROM Pago p
INNER JOIN Reserva r ON p.idReserva = r.idReserva
INNER JOIN Horario h ON r.idHorario = h.idHorario
INNER JOIN UsuarioDeportivo u ON r.idUsuario = u.idUsuario
GROUP BY u.idUsuario, u.nombres, u.apellidos
HAVING SUM(p.valor) > 50000;
GO
--SELECT * FROM VistaUsuariosAltoPago;

---Crear una vista que muestre las canchas que tienen más de 1 reserva registrada
CREATE OR ALTER VIEW VistaCanchasConVariasReservas AS
SELECT c.idCancha, c.nombre AS NombreCancha, COUNT(*) AS CantidadReservas
FROM Reserva r
INNER JOIN Horario h ON r.idHorario = h.idHorario
INNER JOIN Cancha c ON h.idCancha = c.idCancha
INNER JOIN UsuarioDeportivo u ON r.idUsuario = u.idUsuario
GROUP BY c.idCancha, c.nombre
HAVING COUNT(*) > 1;
GO
--SELECT * FROM VistaTotalPorMetodoPago;

---tabla temporal que resume cada reserva junto al nombre del usuario, la cancha reservada y el valor pagado
CREATE TABLE #ResumenReservas (
    idReserva  INT,
    usuario    VARCHAR(120),
    cancha     VARCHAR(50),
    valorPago  DECIMAL(10,2)
);
GO

INSERT INTO #ResumenReservas (idReserva, usuario, cancha, valorPago)
SELECT r.idReserva,
       u.nombres + ' ' + u.apellidos AS usuario,
       c.nombre AS cancha,
       p.valor
FROM Reserva r
INNER JOIN UsuarioDeportivo u ON r.idUsuario = u.idUsuario
INNER JOIN Horario h ON r.idHorario = h.idHorario
INNER JOIN Cancha c ON h.idCancha = c.idCancha
INNER JOIN Pago p ON r.idReserva = p.idReserva;
GO

SELECT * FROM #ResumenReservas;
DROP TABLE #ResumenReservas;

---Mostrar el estado de cada reserva junto con 'En curso' si la reserva está Activa, o 'No activa' en cualquier otro caso.
SELECT idReserva, estado,
       IIF(estado = 'Activa', 'En curso', 'No activa') AS EstadoDescriptivo
FROM Reserva;
GO

---Mostrar si cada usuario puede hacer reservas actualmente, según si su estado es Activo o Inactivo.
SELECT idUsuario, nombres, apellidos, estado,
       IIF(estado = 'Activo', 'Puede reservar', 'No puede reservar') AS DisponibilidadReserva
FROM UsuarioDeportivo;
GO

---Mostrar una descripción completa del método de pago usado en cada transacción."
SELECT idPago, metodoPago,
       CASE metodoPago
           WHEN 'Efectivo' THEN 'Pago en efectivo'
           WHEN 'Tarjeta' THEN 'Pago con tarjeta'
           WHEN 'Transferencia' THEN 'Transferencia bancaria'
           WHEN 'Nequi' THEN 'Billetera Nequi'
           WHEN 'Daviplata' THEN 'Billetera Daviplata'
           ELSE 'Otro método'
       END AS DescripcionMetodo
FROM Pago;
GO

---Mostrar el nombre completo del tipo de cancha, según su categoría (Fútbol, Tenis, Squash o Voleibol).
SELECT idCancha, nombre, tipo,
       CASE tipo
           WHEN 'Futbol'   THEN 'Cancha de Fútbol'
           WHEN 'Tenis'    THEN 'Cancha de Tenis'
           WHEN 'Squash'   THEN 'Cancha de Squash'
           WHEN 'Voleibol' THEN 'Cancha de Voleibol'
           ELSE 'Otro tipo'
       END AS DescripcionCancha
FROM Cancha;
GO





