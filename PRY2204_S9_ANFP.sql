SET DEFINE OFF

CREATE TABLE region (
    id_region NUMBER(3),
    nombre VARCHAR2(100) NOT NULL,
    CONSTRAINT pk_region PRIMARY KEY (id_region)
);

CREATE TABLE comuna (
    id_comuna NUMBER(5),
    id_region NUMBER(3) NOT NULL,
    nombre VARCHAR2(80) NOT NULL,
    CONSTRAINT pk_comuna PRIMARY KEY (id_comuna),
    CONSTRAINT fk_comuna_region FOREIGN KEY (id_region) REFERENCES region (id_region)
);

CREATE TABLE asociacion (
    id_asociacion NUMBER(5),
    nombre_asociacion VARCHAR2(100) NOT NULL,
    fecha_creacion DATE NOT NULL,
    tipo_asociacion CHAR(1) DEFAULT 'A' NOT NULL,
    CONSTRAINT pk_asociacion PRIMARY KEY (id_asociacion),
    CONSTRAINT ck_asociacion_fecha CHECK (fecha_creacion >= DATE '1980-12-31'),
    CONSTRAINT ck_asociacion_tipo CHECK (tipo_asociacion IN ('P', 'A'))
);

CREATE TABLE nacionalidad (
    id_nacion NUMBER(5) GENERATED ALWAYS AS IDENTITY (START WITH 210 INCREMENT BY 2),
    descripcion VARCHAR2(50) NOT NULL,
    CONSTRAINT pk_nacionalidad PRIMARY KEY (id_nacion),
    CONSTRAINT un_nacionalidad_descripcion UNIQUE (descripcion)
);

CREATE SEQUENCE seq_club_futbol START WITH 703 INCREMENT BY 4 NOCACHE NOCYCLE;

CREATE TABLE club_futbol (
    id_club NUMBER(6) DEFAULT seq_club_futbol.NEXTVAL,
    nombre_club VARCHAR2(100) NOT NULL,
    patrimonio NUMBER(14,0) DEFAULT 0 NOT NULL,
    ubicacion_calle VARCHAR2(150) NOT NULL,
    tipo_club VARCHAR2(12) DEFAULT 'Profesional' NOT NULL,
    CONSTRAINT pk_club_futbol PRIMARY KEY (id_club),
    CONSTRAINT un_club_futbol_nombre UNIQUE (nombre_club),
    CONSTRAINT ck_club_futbol_patrimonio CHECK (patrimonio >= 0),
    CONSTRAINT ck_club_futbol_tipo CHECK (tipo_club IN ('Profesional', 'Amateur'))
);

CREATE TABLE escuela_futbol (
    id_escuela NUMBER(6),
    nombre_escuela VARCHAR2(100) NOT NULL,
    capacidad NUMBER(6) NOT NULL,
    fecha_fundacion DATE NOT NULL,
    CONSTRAINT pk_escuela_futbol PRIMARY KEY (id_escuela),
    CONSTRAINT ck_escuela_futbol_capacidad CHECK (capacidad > 0)
);

CREATE TABLE idioma (
    id_idioma NUMBER(3),
    nombre_idioma VARCHAR2(50) NOT NULL,
    CONSTRAINT pk_idioma PRIMARY KEY (id_idioma),
    CONSTRAINT un_idioma_nombre UNIQUE (nombre_idioma)
);

CREATE TABLE trabajador (
    id_inscripcion NUMBER(10),
    rut NUMBER(8) NOT NULL,
    dv CHAR(1) NOT NULL,
    nombres VARCHAR2(80) NOT NULL,
    apellido_paterno VARCHAR2(50) NOT NULL,
    apellido_materno VARCHAR2(50),
    sueldo_base NUMBER(12,0) DEFAULT 0 NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    genero CHAR(1) NOT NULL,
    estado_civil VARCHAR2(25) NOT NULL,
    telefono_movil VARCHAR2(20) NOT NULL,
    correo VARCHAR2(100),
    direccion VARCHAR2(150) NOT NULL,
    id_comuna NUMBER(5) NOT NULL,
    id_nacion NUMBER(5) NOT NULL,
    id_club NUMBER(6) NOT NULL,
    CONSTRAINT pk_trabajador PRIMARY KEY (id_inscripcion),
    CONSTRAINT un_trabajador_rut UNIQUE (rut),
    CONSTRAINT un_trabajador_correo UNIQUE (correo),
    CONSTRAINT ck_trabajador_rut CHECK (rut > 0),
    CONSTRAINT ck_trabajador_dv CHECK (dv IN ('0','1','2','3','4','5','6','7','8','9','K')),
    CONSTRAINT ck_trabajador_sueldo CHECK (sueldo_base >= 0),
    CONSTRAINT ck_trabajador_genero CHECK (genero IN ('M','F','O')),
    CONSTRAINT fk_trabajador_comuna FOREIGN KEY (id_comuna) REFERENCES comuna (id_comuna),
    CONSTRAINT fk_trabajador_nacionalidad FOREIGN KEY (id_nacion) REFERENCES nacionalidad (id_nacion),
    CONSTRAINT fk_trabajador_club FOREIGN KEY (id_club) REFERENCES club_futbol (id_club)
);

CREATE TABLE jugador (
    id_inscripcion NUMBER(10),
    puesto VARCHAR2(30) NOT NULL,
    total_premios NUMBER(14,0) DEFAULT 0 NOT NULL,
    id_asociacion NUMBER(5) NOT NULL,
    id_escuela NUMBER(6),
    anio_fin_amateur NUMBER(4),
    CONSTRAINT pk_jugador PRIMARY KEY (id_inscripcion),
    CONSTRAINT fk_jugador_trabajador FOREIGN KEY (id_inscripcion) REFERENCES trabajador (id_inscripcion),
    CONSTRAINT fk_jugador_asociacion FOREIGN KEY (id_asociacion) REFERENCES asociacion (id_asociacion),
    CONSTRAINT fk_jugador_escuela FOREIGN KEY (id_escuela) REFERENCES escuela_futbol (id_escuela),
    CONSTRAINT ck_jugador_premios CHECK (total_premios >= 0),
    CONSTRAINT ck_jugador_anio CHECK (anio_fin_amateur BETWEEN 1900 AND 9999),
    CONSTRAINT ck_jugador_formacion CHECK (
        (id_escuela IS NULL AND anio_fin_amateur IS NULL) OR
        (id_escuela IS NOT NULL AND anio_fin_amateur IS NOT NULL)
    )
);

CREATE TABLE personal_planta (
    id_inscripcion NUMBER(10),
    horas_trabajadas NUMBER(6,2),
    valor_hora_extra NUMBER(10,0),
    CONSTRAINT pk_personal_planta PRIMARY KEY (id_inscripcion),
    CONSTRAINT fk_planta_trabajador FOREIGN KEY (id_inscripcion) REFERENCES trabajador (id_inscripcion),
    CONSTRAINT ck_planta_horas CHECK (horas_trabajadas >= 0),
    CONSTRAINT ck_planta_valor_extra CHECK (valor_hora_extra >= 0)
);

CREATE TABLE permanencia_jugador (
    id_inscripcion NUMBER(10),
    fecha_inicio DATE,
    id_club NUMBER(6) NOT NULL,
    fecha_fin DATE,
    CONSTRAINT pk_permanencia_jugador PRIMARY KEY (id_inscripcion, fecha_inicio),
    CONSTRAINT fk_permanencia_jugador FOREIGN KEY (id_inscripcion) REFERENCES jugador (id_inscripcion),
    CONSTRAINT fk_permanencia_club FOREIGN KEY (id_club) REFERENCES club_futbol (id_club),
    CONSTRAINT ck_permanencia_fechas CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
);

CREATE UNIQUE INDEX un_permanencia_abierta ON permanencia_jugador (
    CASE WHEN fecha_fin IS NULL THEN id_inscripcion END
);

CREATE TABLE jugador_idioma (
    id_inscripcion NUMBER(10),
    id_idioma NUMBER(3),
    nivel_dominio VARCHAR2(15) NOT NULL,
    CONSTRAINT pk_jugador_idioma PRIMARY KEY (id_inscripcion, id_idioma),
    CONSTRAINT fk_jugador_idioma_jugador FOREIGN KEY (id_inscripcion) REFERENCES jugador (id_inscripcion),
    CONSTRAINT fk_jugador_idioma_idioma FOREIGN KEY (id_idioma) REFERENCES idioma (id_idioma),
    CONSTRAINT ck_jugador_idioma_nivel CHECK (nivel_dominio IN ('Basico','Intermedio','Avanzado','Nativo'))
);

INSERT INTO region VALUES (1, 'ARICA Y PARINACOTA Y TARAPACA');
INSERT INTO region VALUES (2, 'ANTOFAGASTA');
INSERT INTO region VALUES (3, 'ATACAMA Y COQUIMBO');
INSERT INTO region VALUES (5, 'VALPARAISO');
INSERT INTO region VALUES (13, 'METROPOLITANA');
INSERT INTO region VALUES (8, 'BIOBIO');
INSERT INTO region VALUES (16, 'NUBLE');

INSERT INTO comuna VALUES (101, 13, 'Santiago');
INSERT INTO comuna VALUES (102, 5, 'Valparaíso');
INSERT INTO comuna VALUES (103, 8, 'Concepción');
INSERT INTO comuna VALUES (104, 2, 'Antofagasta');
INSERT INTO comuna VALUES (105, 16, 'Chillán');

INSERT INTO asociacion VALUES (25, 'Asociación de Fútbol de Santiago', DATE '2001-05-15', 'P');
INSERT INTO asociacion VALUES (26, 'Asociación Nacional de Fútbol Amateur', DATE '1998-03-10', 'A');
INSERT INTO asociacion VALUES (27, 'Asociación de Fútbol de Valparaíso', DATE '1987-07-21', 'P');
INSERT INTO asociacion VALUES (28, 'Asociación de Fútbol de Concepción', DATE '1995-11-30', 'A');
INSERT INTO asociacion VALUES (29, 'Asociación de Fútbol de Antofagasta', DATE '2003-06-25', 'P');
INSERT INTO asociacion VALUES (30, 'Asociación de Fútbol de Temuco', DATE '2010-01-12', 'A');
INSERT INTO asociacion VALUES (31, 'Asociación de Fútbol de Rancagua', DATE '1999-09-08', 'P');
INSERT INTO asociacion VALUES (32, 'Asociación de Fútbol de Puerto Montt', DATE '2005-04-20', 'A');
INSERT INTO asociacion VALUES (33, 'Asociación de Fútbol de La Serena', DATE '2012-08-14', 'P');
INSERT INTO asociacion VALUES (34, 'Asociación de Fútbol de Chillán', DATE '2018-12-01', 'A');

INSERT INTO nacionalidad (descripcion) VALUES ('Chilena');
INSERT INTO nacionalidad (descripcion) VALUES ('Argentina');
INSERT INTO nacionalidad (descripcion) VALUES ('Peruana');
INSERT INTO nacionalidad (descripcion) VALUES ('Boliviana');
INSERT INTO nacionalidad (descripcion) VALUES ('Brasileña');

INSERT INTO club_futbol (nombre_club, patrimonio, ubicacion_calle, tipo_club)
VALUES ('Colo-Colo', 500000000, 'Av. Marathon 5300', 'Profesional');
INSERT INTO club_futbol (nombre_club, patrimonio, ubicacion_calle, tipo_club)
VALUES ('Universidad de Chile', 450000000, 'Av. El Parrón 0931', 'Profesional');
INSERT INTO club_futbol (nombre_club, patrimonio, ubicacion_calle, tipo_club)
VALUES ('Deportes Antofagasta', 180000000, 'Avenida Angamos 01606', 'Profesional');
INSERT INTO club_futbol (nombre_club, patrimonio, ubicacion_calle, tipo_club)
VALUES ('Huachipato', 220000000, 'Avenida Desiderio García 909', 'Profesional');
INSERT INTO club_futbol (nombre_club, patrimonio, ubicacion_calle, tipo_club)
VALUES ('Ñublense', 170000000, 'Avenida Pedro Aguirre Cerda 1003', 'Profesional');

COMMIT;

-- Informe 1: asociaciones profesionales creadas después del año 2000.
SELECT 'ID:' || id_asociacion || ' * ' || nombre_asociacion AS "ASOCIACION",
       TO_CHAR(fecha_creacion, 'DD-MM-YYYY') AS "CREADA",
       tipo_asociacion AS "TIPO"
FROM asociacion
WHERE tipo_asociacion = 'P'
  AND fecha_creacion >= DATE '2001-01-01'
ORDER BY fecha_creacion DESC;

-- Informe 2: patrimonio de clubes profesionales.
SELECT id_club AS "CLUB",
       nombre_club AS "NOMBRE CLUB",
       patrimonio AS "PATRIMONIO EN PESOS",
       patrimonio / 955 AS "PATRIMONIO EN DOLARES"
FROM club_futbol
WHERE LOWER(nombre_club) LIKE '%a%'
  AND patrimonio > 200000000
  AND tipo_club = 'Profesional'
ORDER BY id_club DESC;
