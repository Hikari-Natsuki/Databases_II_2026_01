USE ModeloCRM
GO

-- INSERTAR REGISTROS

INSERT INTO Anotacion VALUES 
('El Prospecto se nego a pagar a horas extras.'),
('El Prospecto acepto todos los terminos sin negacion alguna.'),
('El Prospecto requiere mas reuniones de negociacion.'),
('El prospecto se rehusa a aumentar sus prestaciones laborales brindadas'),
('EL Prospecto dejo su contrato sin firmar por indecision')

-- Prospecto 
INSERT INTO Prospecto VALUES 
('Andres Felipe Cano', 'Andresito@gmail.com', '3054896356'),
('Sergio Remirez', 'Ramirez@gmail.com', '3056798234'),
('Yokito Fokito', 'Yokito@gmail.com', '3067895678'),
('Maria Isabel Fernandez', 'Isabelsota@hotmail.com', '3014878963'),
('Jorge Paniagua perez', 'Jorgecurioso@gmail.com', '3047895427')

-- Tarea
INSERT INTO Tarea VALUES 
('2026-03-10','16:40:00','Si', 'Enviar Correo'),
('2026-04-07','12:00:00','Si', ' LLamar por Telefono'),
('2026-03-15', '17:00:00', 'Si', 'Enviar Correo'),
('2026-07-18', '18:30:00', 'Si', 'Enviar Correo'),
('2026-09-12', '06:30:00', 'Si', 'Enviar SMS')

-- Acceso
INSERT INTO ACCESO (Contrasena, TipoUsuario)
VALUES
('admin_general', 'Administrador'),
('mlopez', 'Usuario'),
('jramirez','Usuario'),
('admin_ventas', 'Administrador'),
('cperez', 'Usuario');

-- Estado
INSERT INTO Estado VALUES 
('Contacto Inicial'),
('Negociando'),
('Terminado'),
('Contacto Inicial'),
('En Proceso');

-- Origen
INSERT INTO Origen VALUES
('Correo'),
('Anuncio WEB'),
('Anuncio movil'),
('Asociados'),
('Correo');

-- Producto
INSERT INTO Producto VALUES 
('Tecnico en Programacion'),
('Auxiliar en punto de venta'),
('Auxiliar Administrativo'),
('Ingeniero Ambiental'),
('Tencino Automotriz')

-- Citas
INSERT INTO Citas VALUES
('2024-01-10', '09:00', 'Calle 1 #10-20', 'Reunion inicial'),
('2024-01-15', '10:30', 'Calle 2 #20-30', 'Seguimiento'),
('2024-01-20', '11:00', 'Calle 3 #30-40', 'Presentacion'),
('2024-01-25', '14:00', 'Calle 4 #40-50', 'Negociacion'),
('2024-01-30', '15:30', 'Calle 5 #50-60', 'Cierre');

-- Asesor
INSERT INTO Asesor VALUES
(1, 'Juan', 'Cuadrado', 'vhvhj328@gmail.com', '3133096564'),
(2, 'Julian', 'Higuita', 'higuitacanojulian@gmail.com', '3133096564'),
(3, 'Estefanía', 'Gomez', 'tefagomez123@gmail.com', '3133096564'),
(4, 'Camila', 'Rendón', 'hutao1111@gmail.com', '3133096564'),
(5, 'Carlos', 'Quintero', 'carlitosss2@gmail.com', '3133096564')

-- Historico 
INSERT INTO Historico VALUES
(1, 1, 2, 1, '2026-01-10'),
(2, 2, 3, 2, '2026-01-15'),
(3, 3, 4, 3, '2026-01-20'),
(4, 4, 5, 4, '2026-01-25'),
(5, 1, 3, 5, '2026-01-30');

-- Oferta
INSERT INTO Oferta VALUES
(1, 1, 1, 1, 4),
(1, 2, 3, 3, 2),
(2, 4, 3, 2, 5),
(2, 3, 4, 4, 1),
(5, 3, 4, 5, 3)

-- RegistroActividades
INSERT INTO RegistroActividad VALUES
(1, 3, 5, 4, 2),
(2, 1, 4, 3, 1),
(3, 4, 3, 5, 3),
(4, 5, 2, 2, 5),
(5, 2, 1, 1, 4)

SELECT * FROM Anotacion