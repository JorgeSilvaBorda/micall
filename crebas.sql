-- phpMyAdmin SQL Dump
-- version 4.7.9
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1:3306
-- Tiempo de generación: 09-08-2019 a las 21:35:13
-- Versión del servidor: 5.7.21
-- Versión de PHP: 5.6.35

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";

--
-- Base de datos: `micall`
--

DELIMITER $$
--
-- Procedimientos
--
DROP PROCEDURE IF EXISTS `SP_DEL_CAMPANA`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_DEL_CAMPANA` (IN `_IDCAMPANA` INT)  BEGIN
	DELETE FROM
		CAMPANA
	WHERE
		IDCAMPANA = _IDCAMPANA;
END$$

DROP PROCEDURE IF EXISTS `SP_DEL_CAMPANASUBPRODUCTO`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_DEL_CAMPANASUBPRODUCTO` (IN `_IDCAMPANA` INT)  BEGIN
	DELETE FROM
		CAMPANASUBPRODUCTO
	WHERE
		IDCAMPANA = _IDCAMPANA;
END$$

DROP PROCEDURE IF EXISTS `SP_DEL_EMPRESA`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_DEL_EMPRESA` (IN `_IDEMPRESA` INT)  BEGIN
	DELETE FROM EMPRESA WHERE IDEMPRESA = _IDEMPRESA;
END$$

DROP PROCEDURE IF EXISTS `SP_DEL_PRODUCTO`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_DEL_PRODUCTO` (IN `_IDPRODUCTO` INT)  BEGIN
	DELETE FROM
		PRODUCTO
	WHERE
		IDPRODUCTO = _IDPRODUCTO;
END$$

DROP PROCEDURE IF EXISTS `SP_DEL_SUBPRODUCTO`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_DEL_SUBPRODUCTO` (IN `_IDSUBPRODUCTO` INT)  BEGIN
	DELETE FROM 
		SUBPRODUCTO
	WHERE
		IDSUBPRODUCTO = _IDSUBPRODUCTO;
END$$

DROP PROCEDURE IF EXISTS `SP_DEL_USUARIO`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_DEL_USUARIO` (IN `_IDUSUARIO` INT)  BEGIN
	DELETE FROM
		USUARIO
	WHERE
		IDUSUARIO = _IDUSUARIO;
END$$

DROP PROCEDURE IF EXISTS `SP_DETALLE_VENTAS_EMPRESA`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_DETALLE_VENTAS_EMPRESA` (IN `_RUTUSUARIO` INT, IN `_FECHAINI` DATE, IN `_FECHAFIN` DATE)  BEGIN

SELECT
	A.FECHASIMULACION,
    B.CODCAMPANA,
    B.NOMCAMPANA,
    C.CODPRODUCTO,
    C.DESCPRODUCTO,
    A.RUTCLIENTE,
    CONCAT(A.RUTCLIENTE, '-', A.DVCLIENTE) RUTFULLCLIENTE,
    CONCAT(A.RUTVENDEDOR, '-', A.DVVENDEDOR) RUTFULLVENDEDOR,
    A.DVCLIENTE,
    A.CUOTAS,
    A.VALORCUOTA,
    A.MONTO,
    B.META,
    IFNULL(COUNT(E.IDSUBPRODUCTO), 0) SUBPRODUCTOS
FROM
	SIMULACION A INNER JOIN CAMPANA B
    ON A.IDCAMPANA = B.IDCAMPANA INNER JOIN PRODUCTO C
    ON B.IDPRODUCTO = C.IDPRODUCTO INNER JOIN EMPRESA D
    ON C.IDEMPRESA = D.IDEMPRESA LEFT JOIN SIMULACIONSUBPRODUCTO E
    ON E.IDSIMULACION = A.IDSIMULACION
WHERE
	A.FECHASIMULACION BETWEEN _FECHAINI AND _FECHAFIN
    AND D.RUTEMPRESA = (SELECT RUTEMPRESA FROM EMPRESA A INNER JOIN USUARIO B ON A.IDEMPRESA = B.IDEMPRESA WHERE RUTUSUARIO = _RUTUSUARIO)
GROUP BY
	A.FECHASIMULACION,
    B.CODCAMPANA,
    B.NOMCAMPANA,
    C.CODPRODUCTO,
    C.DESCPRODUCTO,
    A.RUTCLIENTE,
    A.DVCLIENTE,
    A.CUOTAS,
    A.VALORCUOTA,
    A.MONTO,
    B.META;
END$$

DROP PROCEDURE IF EXISTS `SP_EXISTE_EMPRESA`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_EXISTE_EMPRESA` (IN `_RUTEMPRESA` INT)  BEGIN
	SELECT
		COUNT(IDEMPRESA) CANTIDAD
	FROM
		EMPRESA
	WHERE
		RUTEMPRESA = _RUTEMPRESA;
END$$

DROP PROCEDURE IF EXISTS `SP_EXISTE_PRODUCTO`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_EXISTE_PRODUCTO` (IN `_CODPRODUCTO` VARCHAR(50), IN `_IDEMPRESA` INT)  BEGIN
	SELECT
		COUNT(IDPRODUCTO) CANTIDAD
	FROM
		PRODUCTO
	WHERE
		CODPRODUCTO = _CODPRODUCTO
        AND IDEMPRESA = _IDEMPRESA;
END$$

DROP PROCEDURE IF EXISTS `SP_EXISTE_RUT_EMPRESA`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_EXISTE_RUT_EMPRESA` (IN `_RUT` INT)  BEGIN
	SELECT
		COUNT(RUTEMPRESA)
	FROM
		EMPRESA
	WHERE
		RUTEMPRESA = _RUT;
END$$

DROP PROCEDURE IF EXISTS `SP_EXISTE_SUBPRODUCTO`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_EXISTE_SUBPRODUCTO` (IN `_CODSUBPRODUCTO` VARCHAR(50), IN `_IDEMPRESA` INT)  BEGIN
	SELECT
		COUNT(IDSUBPRODUCTO) CANTIDAD
	FROM
		SUBPRODUCTO
	WHERE
		CODSUBPRODUCTO = _CODSUBPRODUCTO
        AND IDEMPRESA = _IDEMPRESA;
END$$

DROP PROCEDURE IF EXISTS `SP_EXISTE_USUARIO`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_EXISTE_USUARIO` (IN `_RUTUSUARIO` INT)  BEGIN
	SELECT
		COUNT(IDUSUARIO) CANTIDAD
	FROM
		USUARIO
	WHERE
		RUTUSUARIO = _RUTUSUARIO;
END$$

DROP PROCEDURE IF EXISTS `SP_GET_CAMPANAS`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_CAMPANAS` ()  BEGIN

	SELECT
		A.IDCAMPANA,
        A.IDPRODUCTO,
        B.CODPRODUCTO,
        B.DESCPRODUCTO,
        B.IDEMPRESA,
        C.NOMBRE,
        C.RUTEMPRESA,
        C.DVEMPRESA,
        A.NOMCAMPANA,
        A.CODCAMPANA,
        A.FECHAINI,
        A.FECHAFIN,
        A.META,
        COUNT(D.IDCAMPANA) SUBPRODUCTOS
	FROM
		CAMPANA A INNER JOIN PRODUCTO B
        ON A.IDPRODUCTO = B.IDPRODUCTO INNER JOIN EMPRESA C
        ON B.IDEMPRESA = C.IDEMPRESA LEFT JOIN CAMPANASUBPRODUCTO D
        ON A.IDCAMPANA = D.IDCAMPANA
	GROUP BY
		A.IDCAMPANA,
        A.IDPRODUCTO,
        B.CODPRODUCTO,
        B.DESCPRODUCTO,
        B.IDEMPRESA,
        C.NOMBRE,
        C.RUTEMPRESA,
        C.DVEMPRESA,
        A.NOMCAMPANA,
        A.CODCAMPANA,
        A.FECHAINI,
        A.FECHAFIN,
        A.META;
END$$

DROP PROCEDURE IF EXISTS `SP_GET_CAMPANA_EMPRESA_RUTCLIETE`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_CAMPANA_EMPRESA_RUTCLIETE` (IN `_RUT` INT, IN `_IDEMPRESA` INT)  BEGIN

SELECT 
	B.IDCAMPANA,
    C.IDPRODUCTO,
    D.IDEMPRESA,
    A.RUT,
    A.DV,
	A.NOMBRES,
    A.APELLIDOS,
    A.GENERO,
    A.FECHANAC,
    A.DIRECCION,
    A.COMUNA,
    A.REGION,
    A.CODIGOPOSTAL,
    A.EMAIL,
    A.FONO1,
    A.FONO2,
    A.FONO3,
    B.NOMCAMPANA,
    B.CODCAMPANA,
    B.FECHAINI,
    B.FECHAFIN,
    B.META,
    C.CODPRODUCTO,
    C.DESCPRODUCTO,
    D.NOMBRE,
    D.RUTEMPRESA,
    D.DVEMPRESA,
    A.MONTOAPROBADO
FROM 
	RUTERO A INNER JOIN CAMPANA B
    ON A.IDCAMPANA = B.IDCAMPANA INNER JOIN PRODUCTO C
    ON B.IDPRODUCTO = C.IDPRODUCTO INNER JOIN EMPRESA D
    ON C.IDEMPRESA = D.IDEMPRESA
WHERE
	DATE(NOW()) BETWEEN B.FECHAINI AND B.FECHAFIN
    AND A.RUT = _RUT
    -- AND D.IDEMPRESA = _IDEMPRESA
GROUP BY
	B.IDCAMPANA,
    C.IDPRODUCTO,
    D.IDEMPRESA,
    A.RUT,
    A.DV,
	A.NOMBRES,
    A.APELLIDOS,
    A.GENERO,
    A.FECHANAC,
    A.DIRECCION,
    A.COMUNA,
    A.REGION,
    A.CODIGOPOSTAL,
    A.EMAIL,
    A.FONO1,
    A.FONO2,
    A.FONO3,
    B.NOMCAMPANA,
    B.CODCAMPANA,
    B.FECHAINI,
    B.FECHAFIN,
    B.META,
    C.CODPRODUCTO,
    C.DESCPRODUCTO,
    D.NOMBRE,
    D.RUTEMPRESA,
    A.MONTOAPROBADO;
END$$

DROP PROCEDURE IF EXISTS `SP_GET_CAMPANA_IDCAMPANA_IDEMPRESA`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_CAMPANA_IDCAMPANA_IDEMPRESA` (IN `_IDCAMPANA` INT, IN `_IDEMPRESA` INT)  BEGIN

SELECT 
	B.IDCAMPANA,
    C.IDPRODUCTO,
    D.IDEMPRESA,
    A.RUT,
    A.DV,
	A.NOMBRES,
    A.APELLIDOS,
    A.GENERO,
    A.FECHANAC,
    A.DIRECCION,
    A.COMUNA,
    A.REGION,
    A.CODIGOPOSTAL,
    A.EMAIL,
    A.FONO1,
    A.FONO2,
    A.FONO3,
    B.NOMCAMPANA,
    B.CODCAMPANA,
    B.FECHAINI,
    B.FECHAFIN,
    B.META,
    C.CODPRODUCTO,
    C.DESCPRODUCTO,
    D.NOMBRE,
    D.RUTEMPRESA,
    D.DVEMPRESA,
    A.MONTOAPROBADO
FROM 
	RUTERO A INNER JOIN CAMPANA B
    ON A.IDCAMPANA = B.IDCAMPANA INNER JOIN PRODUCTO C
    ON B.IDPRODUCTO = C.IDPRODUCTO INNER JOIN EMPRESA D
    ON C.IDEMPRESA = D.IDEMPRESA
WHERE
	DATE(NOW()) BETWEEN B.FECHAINI AND B.FECHAFIN
    AND A.IDCAMPANA = _IDCAMPANA
    AND D.IDEMPRESA = _IDEMPRESA
GROUP BY
	B.IDCAMPANA,
    C.IDPRODUCTO,
    D.IDEMPRESA,
    A.RUT,
    A.DV,
	A.NOMBRES,
    A.APELLIDOS,
    A.GENERO,
    A.FECHANAC,
    A.DIRECCION,
    A.COMUNA,
    A.REGION,
    A.CODIGOPOSTAL,
    A.EMAIL,
    A.FONO1,
    A.FONO2,
    A.FONO3,
    B.NOMCAMPANA,
    B.CODCAMPANA,
    B.FECHAINI,
    B.FECHAFIN,
    B.META,
    C.CODPRODUCTO,
    C.DESCPRODUCTO,
    D.NOMBRE,
    D.RUTEMPRESA,
    A.MONTOAPROBADO;
END$$

DROP PROCEDURE IF EXISTS `SP_GET_DETALLE_SUBPRODUCTOS`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_DETALLE_SUBPRODUCTOS` (IN `_IDCAMPANA` INT)  BEGIN
SELECT
	A.IDCAMPANA,
    A.IDSUBPRODUCTO,
    A.MONTOMETA,
    A.CANTIDADMETA,
    B.IDEMPRESA,
    B.CODSUBPRODUCTO,
    B.DESCSUBPRODUCTO,
    B.PRIMA
FROM
	CAMPANASUBPRODUCTO A INNER JOIN SUBPRODUCTO B
    ON A.IDSUBPRODUCTO = B.IDSUBPRODUCTO
WHERE
	A.IDCAMPANA = _IDCAMPANA;
END$$

DROP PROCEDURE IF EXISTS `SP_GET_EMPRESAS`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_EMPRESAS` ()  BEGIN
	SELECT
		IDEMPRESA,
        RUTEMPRESA,
        DVEMPRESA,
        NOMBRE,
        DIRECCION,
        CREACION,
        ULTMODIFICACION
	FROM
		EMPRESA;
END$$

DROP PROCEDURE IF EXISTS `SP_GET_EMPRESA_BY_ID`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_EMPRESA_BY_ID` (IN `_IDEMPRESA` INT)  BEGIN
	SELECT
		IDEMPRESA,
        RUTEMPRESA,
        DVEMPRESA,
        NOMBRE,
        DIRECCION,
        CREACION,
        ULTMODIFICACION
	FROM
		EMPRESA
	WHERE
		IDEMPRESA = _IDEMPRESA;
END$$

DROP PROCEDURE IF EXISTS `SP_GET_EMPRESA_BY_RUT`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_EMPRESA_BY_RUT` (IN `_RUTEMPRESA` INT)  BEGIN
	SELECT
		IDEMPRESA,
        RUTEMPRESA,
        DVEMPRESA,
        NOMBRE,
        DIRECCION,
        CREACION,
        ULTMODIFICACION
	FROM
		EMPRESA
	WHERE
		RUTEMPRESA = _RUTEMPRESA;
END$$

DROP PROCEDURE IF EXISTS `SP_GET_PRODUCTOS`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_PRODUCTOS` ()  BEGIN
	SELECT
		A.IDPRODUCTO,
        A.IDEMPRESA,
        A.CODPRODUCTO,
        A.DESCPRODUCTO,
        B.RUTEMPRESA,
        B.DVEMPRESA,
        B.NOMBRE
	FROM
		PRODUCTO A INNER JOIN EMPRESA B
        ON A.IDEMPRESA = B.IDEMPRESA;
END$$

DROP PROCEDURE IF EXISTS `SP_GET_RESUMEN_MES_VENDEDOR`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_RESUMEN_MES_VENDEDOR` (IN `_RUTVENDEDOR` INT)  BEGIN
SELECT
	A.IDCAMPANA,
    A.IDPRODUCTO,
    A.CODCAMPANA,
    A.NOMCAMPANA,
    B.CODPRODUCTO,
    B.DESCPRODUCTO,
    C.RUTEMPRESA,
    C.DVEMPRESA,
    A.META,
    IFNULL(SUM(D.MONTO), 0) MONTOACUM,
    (IFNULL(SUM(D.MONTO), 0) * 100) / A.META PORCACUM,
    COUNT(D.IDCAMPANA) CANTIDAD,
    D.RUTVENDEDOR
FROM
	CAMPANA A INNER JOIN PRODUCTO B
    ON A.IDPRODUCTO = B.IDPRODUCTO INNER JOIN EMPRESA C
    ON B.IDEMPRESA = C.IDEMPRESA LEFT JOIN SIMULACION D
    ON A.IDCAMPANA = D.IDCAMPANA
WHERE
	(D.FECHASIMULACION BETWEEN (LAST_DAY(NOW() - INTERVAL 1 MONTH) + INTERVAL 1 DAY) AND LAST_DAY(NOW())
    OR D.FECHASIMULACION IS NULL)
    AND ( D.RUTVENDEDOR = _RUTVENDEDOR OR D.RUTVENDEDOR IS NULL)
GROUP BY
	A.IDCAMPANA,
    A.IDPRODUCTO,
    A.CODCAMPANA,
    A.NOMCAMPANA,
    B.CODPRODUCTO,
    B.DESCPRODUCTO,
    C.RUTEMPRESA,
    C.DVEMPRESA,
    A.META;
    
END$$

DROP PROCEDURE IF EXISTS `SP_GET_SELECT_PRODUCTOS`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_SELECT_PRODUCTOS` (IN `_IDEMPRESA` INT)  BEGIN
	SELECT
		IDPRODUCTO,
        DESCPRODUCTO
	FROM
		PRODUCTO
	WHERE
		IDEMPRESA = _IDEMPRESA;
END$$

DROP PROCEDURE IF EXISTS `SP_GET_SIMULACIONES_IDEMPRESA`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_SIMULACIONES_IDEMPRESA` (IN `_IDEMPRESA` INT)  BEGIN
SELECT
	A.IDSIMULACION,
    A.IDCAMPANA,
    B.CODCAMPANA,
    B.NOMCAMPANA,
    B.IDPRODUCTO,
    C.CODPRODUCTO,
    C.DESCPRODUCTO,
    A.FECHASIMULACION,
    A.RUTVENDEDOR,
    A.DVVENDEDOR,
    A.RUTCLIENTE,
    A.DVCLIENTE,
    A.MONTO,
    A.CUOTAS,
    A.VALORCUOTA,
    A.TASAINTERES,
    A.TASAANUAL,
    A.CAE,
    A.VENCIMIENTO,
    A.COSTOTOTAL,
    A.COMISION,
    D.NOMBRES NOMBRESCLIENTE,
    D.APELLIDOS APELLIDOSCLIENTE
FROM
	SIMULACION A INNER JOIN CAMPANA B
    ON A.IDCAMPANA = B.IDCAMPANA INNER JOIN PRODUCTO C
    ON B.IDPRODUCTO = C.IDPRODUCTO INNER JOIN RUTERO D
    ON A.RUTCLIENTE = D.RUT 
		AND A.DVCLIENTE = D.DV 
WHERE C.IDEMPRESA = _IDEMPRESA;
END$$

DROP PROCEDURE IF EXISTS `SP_GET_SIMULACIONES_RUTVENDEDOR`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_SIMULACIONES_RUTVENDEDOR` (IN `_RUTVENDEDOR` INT)  BEGIN
SELECT
	A.IDSIMULACION,
    A.IDCAMPANA,
    B.CODCAMPANA,
    B.NOMCAMPANA,
    B.IDPRODUCTO,
    C.CODPRODUCTO,
    C.DESCPRODUCTO,
    A.FECHASIMULACION,
    A.RUTVENDEDOR,
    A.DVVENDEDOR,
    A.RUTCLIENTE,
    A.DVCLIENTE,
    A.MONTO,
    A.CUOTAS,
    A.VALORCUOTA,
    A.TASAINTERES,
    A.TASAANUAL,
    A.CAE,
    A.VENCIMIENTO,
    A.COSTOTOTAL,
    A.COMISION,
    D.NOMBRES NOMBRESCLIENTE,
    D.APELLIDOS APELLIDOSCLIENTE,
    COUNT(E.IDSUBPRODUCTO) SUBPRODUCTOS
FROM
	SIMULACION A INNER JOIN CAMPANA B
    ON A.IDCAMPANA = B.IDCAMPANA INNER JOIN PRODUCTO C
    ON B.IDPRODUCTO = C.IDPRODUCTO INNER JOIN RUTERO D
    ON A.RUTCLIENTE = D.RUT 
		AND A.DVCLIENTE = D.DV LEFT JOIN SIMULACIONSUBPRODUCTO E
	ON A.IDSIMULACION = E.IDSIMULACION
WHERE A.RUTVENDEDOR = _RUTVENDEDOR;
END$$

DROP PROCEDURE IF EXISTS `SP_GET_SIMULACION_API`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_SIMULACION_API` (IN `_RUTCLIENTE` INT, IN `_FECHASIMULACION` DATE, IN `_RUTEMPRESA` INT)  BEGIN
SELECT
	A.IDSIMULACION,
    A.IDCAMPANA,
    DATE(A.FECHASIMULACION) FECHASIMULACION,
    A.RUTVENDEDOR,
    A.DVVENDEDOR,
    A.RUTCLIENTE,
    A.DVCLIENTE,
    A.MONTO,
    A.CUOTAS,
    A.VALORCUOTA,
    A.TASAINTERES,
    A.TASAANUAL,
    A.CAE,
    A.VENCIMIENTO,
    A.COSTOTOTAL,
    A.COMISION,
    B.CODCAMPANA,
    B.NOMCAMPANA,
    C.CODPRODUCTO,
    C.DESCPRODUCTO,
    D.RUTEMPRESA,
    D.DVEMPRESA,
    D.NOMBRE NOMEMPRESA,
    F.IDSUBPRODUCTO,
    F.CODSUBPRODUCTO,
    F.DESCSUBPRODUCTO,
    F.PRIMA
FROM
	SIMULACION A INNER JOIN CAMPANA B
    ON A.IDCAMPANA = B.IDCAMPANA INNER JOIN PRODUCTO C
    ON B.IDPRODUCTO = C.IDPRODUCTO INNER JOIN EMPRESA D
    ON C.IDEMPRESA = D.IDEMPRESA INNER JOIN SIMULACIONSUBPRODUCTO E
    ON A.IDSIMULACION = E.IDSIMULACION INNER JOIN SUBPRODUCTO F
    ON E.IDSUBPRODUCTO = F.IDSUBPRODUCTO
WHERE
	A.RUTCLIENTE = _RUTCLIENTE
    AND DATE(A.FECHASIMULACION) = _FECHASIMULACION
    AND D.RUTEMPRESA = _RUTEMPRESA;
END$$

DROP PROCEDURE IF EXISTS `SP_GET_SUBPRODUCTOS`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_SUBPRODUCTOS` ()  BEGIN
	SELECT
		A.IDSUBPRODUCTO,
        A.CODSUBPRODUCTO,
        A.DESCSUBPRODUCTO,
        B.IDEMPRESA,
        B.RUTEMPRESA,
        B.DVEMPRESA,
        B.NOMBRE,
        A.PRIMA
	FROM
		SUBPRODUCTO A INNER JOIN EMPRESA B
        ON A.IDEMPRESA = B.IDEMPRESA;
END$$

DROP PROCEDURE IF EXISTS `SP_GET_SUBPRODUCTOS_EMPRESA`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_SUBPRODUCTOS_EMPRESA` (IN `_IDEMPRESA` INT)  BEGIN
	SELECT
		A.IDSUBPRODUCTO,
        A.CODSUBPRODUCTO,
        A.DESCSUBPRODUCTO,
        B.IDEMPRESA,
        B.RUTEMPRESA,
        B.DVEMPRESA,
        B.NOMBRE,
        A.PRIMA
	FROM
		SUBPRODUCTO A INNER JOIN EMPRESA B
        ON A.IDEMPRESA = B.IDEMPRESA
	WHERE
		A.IDEMPRESA = _IDEMPRESA;
END$$

DROP PROCEDURE IF EXISTS `SP_GET_SUBPRODUCTOS_SIMULACION_API`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_SUBPRODUCTOS_SIMULACION_API` (IN `_IDSIMULACION` INT)  BEGIN

SELECT
	B.IDSUBPRODUCTO,
    B.CODSUBPRODUCTO,
    B.DESCSUBPRODUCTO,
    B.PRIMA
FROM 
	SIMULACIONSUBPRODUCTO A INNER JOIN SUBPRODUCTO B
    ON A.IDSUBPRODUCTO = B.IDSUBPRODUCTO 
WHERE IDSIMULACION = _IDSIMULACION;
END$$

DROP PROCEDURE IF EXISTS `SP_GET_TIPOUSUARIOS`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_TIPOUSUARIOS` ()  BEGIN
	SELECT
		IDTIPOUSUARIO,
        DESCTIPOUSUARIO
	FROM
		TIPOUSUARIO;
END$$

DROP PROCEDURE IF EXISTS `SP_GET_USUARIOS`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_USUARIOS` ()  BEGIN
SELECT
	A.IDUSUARIO,
    A.IDEMPRESA,
    B.RUTEMPRESA,
    B.DVEMPRESA,
    B.NOMBRE,
    A.IDTIPOUSUARIO,
    C.DESCTIPOUSUARIO,
    A.RUTUSUARIO,
    A.DVUSUARIO,
    A.NOMUSUARIO,
    A.APPATERNO,
    A.APMATERNO,
    A.ESTADO
FROM
	USUARIO A INNER JOIN EMPRESA B
    ON A.IDEMPRESA = B.IDEMPRESA INNER JOIN TIPOUSUARIO C
    ON A.IDTIPOUSUARIO = C.IDTIPOUSUARIO;
END$$

DROP PROCEDURE IF EXISTS `SP_GET_VENTAS_DETALLE_VENDEDOR`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_VENTAS_DETALLE_VENDEDOR` (IN `_RUTVENDEDOR` INT, IN `_DESDE` DATE, IN `_HASTA` DATE)  BEGIN

SELECT
	IDSIMULACION,
    A.IDCAMPANA,
    A.FECHASIMULACION,
    A.RUTVENDEDOR,
    A.DVVENDEDOR,
    A.RUTCLIENTE,
    A.DVCLIENTE,
    A.MONTO,
    A.CUOTAS,
    A.VALORCUOTA,
    A.TASAINTERES,
    A.TASAANUAL,
    A.CAE,
    A.COSTOTOTAL,
    A.VENCIMIENTO,
    A.COMISION,
    B.IDPRODUCTO,
    B.META,
    B.CODCAMPANA,
    B.NOMCAMPANA,
    C.CODPRODUCTO,
    C.DESCPRODUCTO,
    D.RUTEMPRESA,
    D.DVEMPRESA,
    D.NOMBRE
FROM
	SIMULACION A INNER JOIN CAMPANA B
    ON A.IDCAMPANA = B.IDCAMPANA INNER JOIN PRODUCTO C
    ON B.IDPRODUCTO = C.IDPRODUCTO INNER JOIN EMPRESA D
    ON C.IDEMPRESA = D.IDEMPRESA
WHERE
	A.RUTVENDEDOR = _RUTVENDEDOR
    AND A.FECHASIMULACION BETWEEN _DESDE AND _HASTA;
END$$

DROP PROCEDURE IF EXISTS `SP_INS_CAMPANA`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INS_CAMPANA` (IN `_IDPRODUCTO` INT, IN `_NOMCAMPANA` VARCHAR(100), IN `_CODCAMPANA` VARCHAR(50), IN `_FECHAINI` DATE, IN `_FECHAFIN` DATE, IN `_META` BIGINT)  BEGIN
	INSERT INTO
		CAMPANA(
			IDPRODUCTO,
            NOMCAMPANA,
            CODCAMPANA,
            FECHAINI,
            FECHAFIN,
            META
		)VALUES(
			_IDPRODUCTO,
            _NOMCAMPANA,
            _CODCAMPANA,
            _FECHAINI,
            _FECHAFIN,
            _META
		);
        
		SELECT LAST_INSERT_ID() LIID; -- LAST INSERT ID
END$$

DROP PROCEDURE IF EXISTS `SP_INS_CAMPANA_SUBPRODUCTO`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INS_CAMPANA_SUBPRODUCTO` (IN `_IDCAMPANA` INT, IN `_IDSUBPRODUCTO` INT, IN `_MONTOMETA` BIGINT, IN `_CANTMETA` INT)  BEGIN
	INSERT INTO
		CAMPANASUBPRODUCTO(
			IDCAMPANA,
            IDSUBPRODUCTO,
            MONTOMETA,
            CANTIDADMETA
		)VALUES(
			_IDCAMPANA,
            _IDSUBPRODUCTO,
            _MONTOMETA,
            _CANTMETA
		);
        
	SELECT MAX(IDCAMPANA) LIID FROM CAMPANASUBPRODUCTO; -- LAST INSERT EN CRUCE PARA CORROBORAR
END$$

DROP PROCEDURE IF EXISTS `SP_INS_EMPRESA`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INS_EMPRESA` (IN `_RUT` INT, IN `_DV` VARCHAR(1), IN `_NOMBRE` VARCHAR(60), IN `_DIRECCION` VARCHAR(100))  BEGIN
	INSERT INTO
		EMPRESA(
			RUTEMPRESA,
            DVEMPRESA,
            NOMBRE,
            DIRECCION,
            CREACION,
            ULTMODIFICACION)
		VALUES(
			_RUT,
            _DV,
            _NOMBRE,
            _DIRECCION,
            NOW(),
            NOW());
END$$

DROP PROCEDURE IF EXISTS `SP_INS_FILA_RUTERO`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INS_FILA_RUTERO` (IN `_IDCAMPANA` INT, IN `_RUTCLIENTE` INT, IN `_DVCLIENTE` VARCHAR(1), IN `_NOMBRES` VARCHAR(30), IN `_APELLIDOS` VARCHAR(30), IN `_GENERO` VARCHAR(1), IN `_FECHANAC` DATE, IN `_DIRECCION` VARCHAR(100), IN `_COMUNA` VARCHAR(50), IN `_REGION` VARCHAR(50), IN `_CODIGOPOSTAL` INT, IN `_EMAIL` VARCHAR(70), IN `_MONTOAPROBADO` INT, IN `_FONO1` INT, IN `_FONO2` INT, IN `_FONO3` INT)  BEGIN
	-- ELIMINAR UN REGISTRO DE CLIENTE QUE YA EXISTA PARA LA MISMA CAMPAÑA
    DELETE FROM RUTERO WHERE IDCAMPANA = _IDCAMPANA AND RUT = _RUTCLIENTE;
    
    -- PROCEDER CON EL INSERT.
	INSERT INTO
		RUTERO(
			IDCAMPANA,
            RUT,
            DV,
            NOMBRES,
            APELLIDOS,
            GENERO,
            FECHANAC,
            DIRECCION,
            COMUNA,
            REGION,
            CODIGOPOSTAL,
            EMAIL,
            MONTOAPROBADO,
            FONO1,
            FONO2,
            FONO3
		)VALUES(
			_IDCAMPANA,
            _RUTCLIENTE,
            _DVCLIENTE,
            _NOMBRES,
            _APELLIDOS,
            _GENERO,
            _FECHANAC,
            _DIRECCION,
            _COMUNA,
            _REGION,
            _CODIGOPOSTAL,
            _EMAIL,
            _MONTOAPROBADO,
            _FONO1,
            _FONO2,
            _FONO3
		);
END$$

DROP PROCEDURE IF EXISTS `SP_INS_PRODUCTO`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INS_PRODUCTO` (IN `_IDEMPRESA` INT, IN `_CODPRODUCTO` VARCHAR(50), IN `_DESCPRODUCTO` VARCHAR(100))  BEGIN
	INSERT INTO 
		PRODUCTO(
            IDEMPRESA, 
            CODPRODUCTO, 
            DESCPRODUCTO) 
		VALUES(
			_IDEMPRESA, 
            _CODPRODUCTO, 
            _DESCPRODUCTO);
END$$

DROP PROCEDURE IF EXISTS `SP_INS_SIMULACION`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INS_SIMULACION` (IN `_IDCAMPANA` INT, IN `_RUTVENDEDOR` INT, IN `_DVVENDEDOR` VARCHAR(1), IN `_RUTCLIENTE` INT, IN `_DVCLIENTE` VARCHAR(1), IN `_MONTO` INT, IN `_CUOTAS` INT, IN `_VALORCUOTA` INT, IN `_TASAINTERES` DECIMAL(5,2), IN `_TASAANUAL` DECIMAL(5,2), IN `_CAE` DECIMAL(5,2), IN `_VENCIMIENTO` DATE, IN `_COSTOTOTAL` INT, IN `_COMISION` INT)  BEGIN
	INSERT INTO
		SIMULACION(
			IDCAMPANA,
            FECHASIMULACION,
            RUTVENDEDOR,
            DVVENDEDOR,
            RUTCLIENTE,
            DVCLIENTE,
            MONTO,
            CUOTAS,
            VALORCUOTA,
            TASAINTERES,
            TASAANUAL,
            CAE,
            VENCIMIENTO,
            COSTOTOTAL,
            COMISION
		)VALUES(
			_IDCAMPANA,
            NOW(),
            _RUTVENDEDOR,
            _DVVENDEDOR,
            _RUTCLIENTE,
            _DVCLIENTE,
            _MONTO,
            _CUOTAS,
            _VALORCUOTA,
            _TASAINTERES,
            _TASAANUAL,
            _CAE,
            _VENCIMIENTO,
            _COSTOTOTAL,
            _COMISION
		);
SELECT LAST_INSERT_ID() LIID;
END$$

DROP PROCEDURE IF EXISTS `SP_INS_SIMULACION_API`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INS_SIMULACION_API` (IN `_RUTVENDEDOR` INT, IN `_DVVENDEDOR` VARCHAR(1), IN `_RUTCLIENTE` INT, IN `_DVCLIENTE` VARCHAR(1), IN `_MONTO` INT, IN `_CUOTAS` INT, IN `_VALORCUOTA` INT, IN `_TASAINTERES` DECIMAL(5,2), IN `_TASAANUAL` DECIMAL(5,2), IN `_CAE` DECIMAL(5,2), IN `_VENCIMIENTO` DATE, IN `_COSTOTOTAL` INT, IN `_COMISION` INT, IN `_CODCAMPANA` VARCHAR(50), IN `_RUTEMPRESA` INT)  BEGIN
	DECLARE _IDCAMPANA INT;
    SELECT
		IDCAMPANA
	INTO
		_IDCAMPANA
	FROM
		CAMPANA A INNER JOIN PRODUCTO B
		ON A.IDPRODUCTO = B.IDPRODUCTO INNER JOIN EMPRESA C
		ON B.IDEMPRESA = C.IDEMPRESA
	WHERE
		CODCAMPANA = _CODCAMPANA
		AND C.RUTEMPRESA = _RUTEMPRESA;
        
	INSERT INTO
		SIMULACION(
			IDCAMPANA,
            FECHASIMULACION,
            RUTVENDEDOR,
            DVVENDEDOR,
            RUTCLIENTE,
            DVCLIENTE,
            MONTO,
            CUOTAS,
            VALORCUOTA,
            TASAINTERES,
            TASAANUAL,
            CAE,
            VENCIMIENTO,
            COSTOTOTAL,
            COMISION
		)VALUES(
			_IDCAMPANA,
            NOW(),
            _RUTVENDEDOR,
            _DVVENDEDOR,
            _RUTCLIENTE,
            _DVCLIENTE,
            _MONTO,
            _CUOTAS,
            _VALORCUOTA,
            _TASAINTERES,
            _TASAANUAL,
            _CAE,
            _VENCIMIENTO,
            _COSTOTOTAL,
            _COMISION
		);
SELECT LAST_INSERT_ID() LIID;
END$$

DROP PROCEDURE IF EXISTS `SP_INS_SIMULACION_SUBPRODUCTO`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INS_SIMULACION_SUBPRODUCTO` (IN `_IDSIMULACION` INT, IN `_IDSUBPRODUCTO` INT)  BEGIN
	INSERT INTO
		SIMULACIONSUBPRODUCTO(
			IDSIMULACION,
            IDSUBPRODUCTO
		)VALUES(
			_IDSIMULACION,
            _IDSUBPRODUCTO
		);
END$$

DROP PROCEDURE IF EXISTS `SP_INS_SIMULACION_SUBPRODUCTO_API`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INS_SIMULACION_SUBPRODUCTO_API` (IN `_IDSIMULACION` INT, IN `_CODSUBPRODUCTO` VARCHAR(50), IN `_RUTEMPRESA` INT)  BEGIN
	DECLARE _IDSUBPRODUCTO INT;
    SELECT
		E.IDSUBPRODUCTO
	INTO
		_IDSUBPRODUCTO
	FROM
		SIMULACION A INNER JOIN CAMPANA B
		ON A.IDCAMPANA = B.IDCAMPANA INNER JOIN PRODUCTO C
		ON B.IDPRODUCTO = C.IDPRODUCTO INNER JOIN EMPRESA D
		ON C.IDEMPRESA = D.IDEMPRESA INNER JOIN SUBPRODUCTO E
		ON D.IDEMPRESA = E.IDEMPRESA
	WHERE
		E.CODSUBPRODUCTO = _CODSUBPRODUCTO
		AND D.RUTEMPRESA = _RUTEMPRESA;
	
    IF(_IDSUBPRODUCTO IS NOT NULL) THEN
		INSERT INTO
			SIMULACIONSUBPRODUCTO(
				IDSIMULACION,
				IDSUBPRODUCTO
			)VALUES(
				_IDSIMULACION,
				_IDSUBPRODUCTO
			);
	END IF;
	
END$$

DROP PROCEDURE IF EXISTS `SP_INS_SUBPRODUCTO`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INS_SUBPRODUCTO` (IN `_IDEMPRESA` INT, IN `_CODSUBPRODUCTO` VARCHAR(50), IN `_DESCSUBPRODUCTO` VARCHAR(100), IN `_PRIMA` DECIMAL(5,2))  BEGIN
	INSERT INTO
		SUBPRODUCTO(
			IDEMPRESA,
            CODSUBPRODUCTO,
            DESCSUBPRODUCTO,
            PRIMA)
		VALUES(
			_IDEMPRESA,
            _CODSUBPRODUCTO,
            _DESCSUBPRODUCTO,
            _PRIMA);
END$$

DROP PROCEDURE IF EXISTS `SP_INS_USUARIO`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INS_USUARIO` (IN `_RUTUSUARIO` INT, IN `_DVUSUARIO` VARCHAR(1), IN `_NOMUSUARIO` VARCHAR(60), IN `_APPATERNO` VARCHAR(50), IN `_APMATERNO` VARCHAR(50), IN `_IDEMPRESA` INT, IN `_IDTIPOUSUARIO` INT)  BEGIN
	INSERT INTO
		USUARIO(
			RUTUSUARIO,
            DVUSUARIO,
            NOMUSUARIO,
            APPATERNO,
            APMATERNO,
            IDEMPRESA,
            IDTIPOUSUARIO,
            ESTADO,
            ULTMODIFICACION,
            PASSWORD)
		VALUES(
			_RUTUSUARIO,
            _DVUSUARIO,
            _NOMUSUARIO,
            _APPATERNO,
            _APMATERNO,
            _IDEMPRESA,
            _IDTIPOUSUARIO,
            1,
            NOW(),
            MD5('password'));
END$$

DROP PROCEDURE IF EXISTS `SP_RESET_PASSWORD`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_RESET_PASSWORD` (IN `_RUTADMIN` INT, IN `_RUTUSUARIO` INT, IN `_NEWPASSWORD` VARCHAR(64))  BEGIN
	DECLARE _CODTIPOUSUARIO INT;
    SELECT
		IDTIPOUSUARIO
	INTO
		_CODTIPOUSUARIO
	FROM
		USUARIO
	WHERE
		RUTUSUARIO = _RUTADMIN;
        
	IF(_CODTIPOUSUARIO = 1) THEN
		UPDATE
			USUARIO
		SET
			PASSWORD = _NEWPASSWORD
		WHERE
			RUTUSUARIO = _RUTUSUARIO;
		
        SELECT 0 AS SALIDA;
	ELSE
		SELECT -1 AS SALIDA;
	END IF;
END$$

DROP PROCEDURE IF EXISTS `SP_RESUMEN_MES_VENDEDOR`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_RESUMEN_MES_VENDEDOR` (IN `_RUTVENDEDOR` INT)  BEGIN
SELECT
	B.IDCAMPANA,
    B.CODCAMPANA,
    B.NOMCAMPANA,
    C.CODPRODUCTO,
    C.DESCPRODUCTO,
    SUM(A.MONTO) ACUMMES,
    COUNT(A.IDCAMPANA) CANTIDAD
FROM
	SIMULACION A INNER JOIN CAMPANA B
    ON A.IDCAMPANA = B.IDCAMPANA INNER JOIN PRODUCTO C
    ON B.IDPRODUCTO = C.IDPRODUCTO
WHERE
	RUTVENDEDOR = _RUTVENDEDOR
    AND (A.FECHASIMULACION BETWEEN (LAST_DAY(NOW() - INTERVAL 1 MONTH) + INTERVAL 1 DAY) AND LAST_DAY(NOW())
    OR A.FECHASIMULACION IS NULL)
GROUP BY
	B.IDCAMPANA,
    B.CODCAMPANA,
    B.NOMCAMPANA,
    C.CODPRODUCTO,
    C.DESCPRODUCTO;
END$$

DROP PROCEDURE IF EXISTS `SP_RESUMEN_VENTAS_EMPRESA`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_RESUMEN_VENTAS_EMPRESA` (IN `_RUTUSUARIO` INT)  BEGIN
DECLARE _RUTEMPRESA INT;
SELECT RUTEMPRESA INTO _RUTEMPRESA FROM EMPRESA A INNER JOIN USUARIO B ON A.IDEMPRESA = B.IDEMPRESA WHERE B.RUTUSUARIO = _RUTUSUARIO;
SELECT
	A.IDCAMPANA,
    A.CODCAMPANA,
    A.NOMCAMPANA,
    A.META,
    A.FECHAINI,
    A.FECHAFIN,
    A.IDPRODUCTO,
    B.CODPRODUCTO,
    B.DESCPRODUCTO,
    IFNULL(SUM(D.MONTO), 0) MONTOACUM,
    (SELECT IFNULL(SUM(MONTO), 0) FROM SIMULACION WHERE IDCAMPANA = A.IDCAMPANA AND FECHASIMULACION = DATE(NOW())) ACUMDIA,
    (IFNULL(SUM(D.MONTO), 0) * 100) / A.META PORCACUM,
    COUNT(D.IDSIMULACION) CANTIDAD
FROM
	CAMPANA A INNER JOIN PRODUCTO B
    ON A.IDPRODUCTO = B.IDPRODUCTO INNER JOIN EMPRESA C
    ON B.IDEMPRESA = C.IDEMPRESA LEFT JOIN SIMULACION D
    ON A.IDCAMPANA = D.IDCAMPANA
WHERE
	NOW() BETWEEN A.FECHAINI AND A.FECHAFIN
    AND C.RUTEMPRESA = _RUTEMPRESA
GROUP BY
	A.IDCAMPANA,
    A.CODCAMPANA,
    A.NOMCAMPANA,
    A.META,
    A.FECHAINI,
    A.FECHAFIN,
    A.IDPRODUCTO,
    B.CODPRODUCTO,
    B.DESCPRODUCTO,
    (SELECT SUM(MONTO) FROM SIMULACION WHERE IDCAMPANA = A.IDCAMPANA AND FECHASIMULACION = DATE(NOW()));
END$$

DROP PROCEDURE IF EXISTS `SP_SEL_SELECT_CAMPANAS`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_SELECT_CAMPANAS` (IN `_IDEMPRESA` INT)  BEGIN
	SELECT
		IDCAMPANA,
        CODCAMPANA,
        NOMCAMPANA,
        CONCAT('[', CODCAMPANA, '] ', NOMCAMPANA) TEXTO
	FROM
		CAMPANA A INNER JOIN PRODUCTO B
        ON A.IDPRODUCTO = B.IDPRODUCTO INNER JOIN EMPRESA C
        ON B.IDEMPRESA = C.IDEMPRESA
	WHERE
		B.IDEMPRESA = _IDEMPRESA;
END$$

DROP PROCEDURE IF EXISTS `SP_SEL_SELECT_CAMPANAS_FECHA`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_SELECT_CAMPANAS_FECHA` (IN `_IDEMPRESA` INT)  BEGIN
	SELECT
		IDCAMPANA,
        CODCAMPANA,
        NOMCAMPANA,
        CONCAT('[', CODCAMPANA, '] ', NOMCAMPANA) TEXTO
	FROM
		CAMPANA A INNER JOIN PRODUCTO B
        ON A.IDPRODUCTO = B.IDPRODUCTO INNER JOIN EMPRESA C
        ON B.IDEMPRESA = C.IDEMPRESA
	WHERE
		B.IDEMPRESA = _IDEMPRESA
        AND DATE(NOW()) BETWEEN A.FECHAINI AND A.FECHAFIN -- USADO PARA CARGAR CAMPAÑAS EN FECHA
        ;
END$$

DROP PROCEDURE IF EXISTS `SP_UPD_CAMPANA`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPD_CAMPANA` (IN `_IDCAMPANA` INT, IN `_IDPRODUCTO` INT, IN `_NOMCAMPANA` VARCHAR(100), IN `_CODCAMPANA` VARCHAR(50), IN `_FECHAINI` DATE, IN `_FECHAFIN` DATE, IN `_META` INT)  BEGIN
	UPDATE 
		CAMPANA
	SET
		IDPRODUCTO = _IDPRODUCTO,
        NOMCAMPANA = _NOMCAMPANA,
        CODCAMPANA = _CODCAMPANA,
        FECHAINI = _FECHAINI,
        FECHAFIN = _FECHAFIN,
        META = _META
	WHERE
		IDCAMPANA = _IDCAMPANA;
END$$

DROP PROCEDURE IF EXISTS `SP_UPD_EMPRESA`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPD_EMPRESA` (IN `_IDEMPRESAORIGEN` INT, IN `_RUTEMPRESA` INT, IN `_DVEMPRESA` VARCHAR(1), IN `_NOMBRE` VARCHAR(60), IN `_DIRECCION` VARCHAR(100))  BEGIN
	UPDATE EMPRESA
    SET
		RUTEMPRESA = _RUTEMPRESA,
        DVEMPRESA = _DVEMPRESA,
        NOMBRE = _NOMBRE,
        DIRECCION = _DIRECCION,
        ULTMODIFICACION = NOW()
	WHERE
		IDEMPRESA = _IDEMPRESAORIGEN;
END$$

DROP PROCEDURE IF EXISTS `SP_UPD_PASSWORD`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPD_PASSWORD` (IN `_RUT` INT, IN `_PASSWORD` VARCHAR(64))  BEGIN
	UPDATE 
		USUARIO
    SET PASSWORD = _PASSWORD
    WHERE
		RUTUSUARIO = _RUT;
END$$

DROP PROCEDURE IF EXISTS `SP_UPD_PRODUCTO`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPD_PRODUCTO` (IN `_IDPRODUCTO` INT, IN `_IDEMPRESA` INT, IN `_CODPRODUCTO` VARCHAR(50), IN `_DESCPRODUCTO` VARCHAR(100))  BEGIN
	UPDATE PRODUCTO
		SET
			IDEMPRESA = _IDEMPRESA,
            DESCPRODUCTO = _DESCPRODUCTO,
            CODPRODUCTO = _CODPRODUCTO
		WHERE
			IDPRODUCTO = _IDPRODUCTO;
END$$

DROP PROCEDURE IF EXISTS `SP_UPD_SUBPRODUCTO`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPD_SUBPRODUCTO` (IN `_IDSUBPRODUCTO` INT, IN `_IDEMPRESA` INT, IN `_CODSUBPRODUCTO` VARCHAR(50), IN `_DESCSUBPRODUCTO` VARCHAR(100), IN `_PRIMA` DECIMAL(5,2))  BEGIN
	UPDATE SUBPRODUCTO
		SET
			CODSUBPRODUCTO = _CODSUBPRODUCTO,
            DESCSUBPRODUCTO = _DESCSUBPRODUCTO,
            IDEMPRESA = _IDEMPRESA,
            PRIMA = _PRIMA
		WHERE
			IDSUBPRODUCTO = _IDSUBPRODUCTO;
END$$

DROP PROCEDURE IF EXISTS `SP_UPD_USUARIO`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPD_USUARIO` (IN `_IDUSUARIO` INT, IN `_RUTUSUARIO` INT, IN `_DVUSUARIO` VARCHAR(1), IN `_NOMBRES` VARCHAR(60), IN `_APPATERNO` VARCHAR(50), IN `_APMATERNO` VARCHAR(50), IN `_IDEMPRESA` INT, IN `_IDTIPOUSUARIO` INT)  BEGIN
	UPDATE
		USUARIO
	SET
		RUTUSUARIO = _RUTUSUARIO,
        DVUSUARIO = _DVUSUARIO,
        NOMUSUARIO = _NOMBRES,
        APPATERNO = _APPATERNO,
        APMATERNO = APMATERNO,
        ULTMODIFICACION = NOW(),
        IDEMPRESA = _IDEMPRESA,
        IDTIPOUSUARIO = _IDTIPOUSUARIO
	WHERE
		IDUSUARIO = _IDUSUARIO;
END$$

DROP PROCEDURE IF EXISTS `SP_VALIDA_SIMULACION_API`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_VALIDA_SIMULACION_API` (IN `_CODCAMPANA` VARCHAR(50), IN `_RUTCLIENTE` INT)  BEGIN
	DECLARE _IDCAMPANA INT;

    SELECT
		A.IDCAMPANA
	INTO
		_IDCAMPANA
	FROM
		CAMPANA A INNER JOIN RUTERO B
        ON A.IDCAMPANA = B.IDCAMPANA
	WHERE
		B.RUT = _RUTCLIENTE
        AND A.CODCAMPANA = _CODCAMPANA;
	
    IF _IDCAMPANA IS NULL THEN 
		SELECT
			1 AS CODIGO,
            'El cliente a ingresar no pertenece a la campaña asociada' MENSAJE,
            0 IDCAMPANA;
	ELSE
		SELECT
			0 AS CODIGO,
            'Campaña válida para el cliente' MENSAJE,
            _IDCAMPANA IDCAMPANA;
	END IF;
    
END$$

DROP PROCEDURE IF EXISTS `SP_VALIDA_SUBPRODUCTO_API`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_VALIDA_SUBPRODUCTO_API` (IN `_CODCAMPANA` VARCHAR(50), IN `_RUTCLIENTE` INT, IN `_CODSUBPRODUCTO` VARCHAR(50))  BEGIN

SELECT
	COUNT(D.IDSUBPRODUCTO) CANTIDAD
FROM
	CAMPANA A INNER JOIN CAMPANASUBPRODUCTO B
    ON A.IDCAMPANA = B.IDCAMPANA INNER JOIN RUTERO C
    ON A.IDCAMPANA = C.IDCAMPANA INNER JOIN SUBPRODUCTO D
    ON B.IDSUBPRODUCTO = D.IDSUBPRODUCTO
WHERE
	A.CODCAMPANA = _CODCAMPANA
    AND C.RUT = _RUTCLIENTE
    AND D.CODSUBPRODUCTO = _CODSUBPRODUCTO;
END$$

DROP PROCEDURE IF EXISTS `SP_VALIDA_USUARIO`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_VALIDA_USUARIO` (IN `_RUT` INT, IN `_PASSWORD` VARCHAR(64))  BEGIN
	SELECT
		A.IDUSUARIO,
        A.IDEMPRESA,
        B.RUTEMPRESA,
        B.DVEMPRESA,
        B.NOMBRE EMPRESA,
        A.IDTIPOUSUARIO,
        C.DESCTIPOUSUARIO,
        A.RUTUSUARIO,
        A.DVUSUARIO,
        A.NOMUSUARIO,
        A.APPATERNO,
        A.APMATERNO,
        A.ESTADO,
        A.ULTMODIFICACION
	FROM
		USUARIO A INNER JOIN EMPRESA B
        ON A.IDEMPRESA = B.IDEMPRESA INNER JOIN TIPOUSUARIO C
        ON A.IDTIPOUSUARIO = C.IDTIPOUSUARIO
	WHERE
		A.RUTUSUARIO = _RUT
        AND A.PASSWORD = _PASSWORD;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `CAMPANA`
--

DROP TABLE IF EXISTS `CAMPANA`;
CREATE TABLE IF NOT EXISTS `CAMPANA` (
  `IDCAMPANA` int(11) NOT NULL AUTO_INCREMENT,
  `IDPRODUCTO` int(11) NOT NULL,
  `NOMCAMPANA` varchar(100) NOT NULL,
  `CODCAMPANA` varchar(50) NOT NULL,
  `FECHAINI` date NOT NULL,
  `FECHAFIN` date NOT NULL,
  `META` bigint(20) NOT NULL,
  PRIMARY KEY (`IDCAMPANA`),
  KEY `FK_RELATIONSHIP_6` (`IDPRODUCTO`)
) ENGINE=MyISAM AUTO_INCREMENT=22 DEFAULT CHARSET=latin1;

--
-- Estructura de tabla para la tabla `CAMPANASUBPRODUCTO`
--

DROP TABLE IF EXISTS `CAMPANASUBPRODUCTO`;
CREATE TABLE IF NOT EXISTS `CAMPANASUBPRODUCTO` (
  `IDCAMPANA` int(11) NOT NULL,
  `IDSUBPRODUCTO` int(11) NOT NULL,
  `MONTOMETA` bigint(20) DEFAULT NULL,
  `CANTIDADMETA` int(11) DEFAULT NULL,
  KEY `FK_RELATIONSHIP_7` (`IDCAMPANA`),
  KEY `FK_RELATIONSHIP_8` (`IDSUBPRODUCTO`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Estructura de tabla para la tabla `EMPRESA`
--

DROP TABLE IF EXISTS `EMPRESA`;
CREATE TABLE IF NOT EXISTS `EMPRESA` (
  `IDEMPRESA` int(11) NOT NULL AUTO_INCREMENT,
  `RUTEMPRESA` int(11) NOT NULL,
  `DVEMPRESA` varchar(1) NOT NULL,
  `NOMBRE` varchar(60) NOT NULL,
  `DIRECCION` varchar(100) NOT NULL,
  `CREACION` datetime NOT NULL,
  `ULTMODIFICACION` datetime NOT NULL,
  PRIMARY KEY (`IDEMPRESA`)
) ENGINE=MyISAM AUTO_INCREMENT=9 DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `EMPRESA`
--

INSERT INTO `EMPRESA` (`IDEMPRESA`, `RUTEMPRESA`, `DVEMPRESA`, `NOMBRE`, `DIRECCION`, `CREACION`, `ULTMODIFICACION`) VALUES
(1, 11111111, '1', 'Administración interna', 'Sin dirección', '2019-07-25 10:25:20', '2019-07-25 10:25:20');

--
-- Estructura de tabla para la tabla `PRODUCTO`
--

DROP TABLE IF EXISTS `PRODUCTO`;
CREATE TABLE IF NOT EXISTS `PRODUCTO` (
  `IDPRODUCTO` int(11) NOT NULL AUTO_INCREMENT,
  `CODPRODUCTO` varchar(50) NOT NULL,
  `IDEMPRESA` int(11) NOT NULL,
  `DESCPRODUCTO` varchar(100) NOT NULL,
  PRIMARY KEY (`IDPRODUCTO`),
  KEY `FK_RELATIONSHIP_5` (`IDEMPRESA`)
) ENGINE=MyISAM AUTO_INCREMENT=13 DEFAULT CHARSET=latin1;

--
-- Estructura de tabla para la tabla `RUTERO`
--

DROP TABLE IF EXISTS `RUTERO`;
CREATE TABLE IF NOT EXISTS `RUTERO` (
  `IDCAMPANA` int(11) NOT NULL,
  `RUT` int(11) NOT NULL,
  `DV` varchar(1) NOT NULL,
  `NOMBRES` varchar(30) NOT NULL,
  `APELLIDOS` varchar(30) NOT NULL,
  `GENERO` varchar(1) DEFAULT NULL,
  `FECHANAC` date DEFAULT NULL,
  `DIRECCION` varchar(100) DEFAULT NULL,
  `COMUNA` varchar(50) DEFAULT NULL,
  `REGION` varchar(50) DEFAULT NULL,
  `CODIGOPOSTAL` int(11) DEFAULT NULL,
  `EMAIL` varchar(70) DEFAULT NULL,
  `MONTOAPROBADO` int(11) NOT NULL,
  `FONO1` int(11) NOT NULL,
  `FONO2` int(11) DEFAULT NULL,
  `FONO3` int(11) DEFAULT NULL,
  KEY `FK_RELATIONSHIP_12` (`IDCAMPANA`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Estructura de tabla para la tabla `SIMULACION`
--

DROP TABLE IF EXISTS `SIMULACION`;
CREATE TABLE IF NOT EXISTS `SIMULACION` (
  `IDSIMULACION` int(11) NOT NULL AUTO_INCREMENT,
  `IDCAMPANA` int(11) NOT NULL,
  `FECHASIMULACION` datetime NOT NULL,
  `RUTVENDEDOR` int(11) NOT NULL,
  `DVVENDEDOR` varchar(1) NOT NULL,
  `RUTCLIENTE` int(11) NOT NULL,
  `DVCLIENTE` varchar(1) NOT NULL,
  `MONTO` int(11) NOT NULL,
  `CUOTAS` int(11) NOT NULL,
  `VALORCUOTA` int(11) NOT NULL,
  `TASAINTERES` decimal(5,2) NOT NULL,
  `TASAANUAL` decimal(5,2) NOT NULL,
  `CAE` decimal(5,2) NOT NULL,
  `VENCIMIENTO` date NOT NULL,
  `COSTOTOTAL` int(11) NOT NULL,
  `COMISION` int(11) NOT NULL,
  PRIMARY KEY (`IDSIMULACION`),
  KEY `FK_RELATIONSHIP_9` (`IDCAMPANA`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;

--
-- Estructura de tabla para la tabla `SIMULACIONSUBPRODUCTO`
--

DROP TABLE IF EXISTS `SIMULACIONSUBPRODUCTO`;
CREATE TABLE IF NOT EXISTS `SIMULACIONSUBPRODUCTO` (
  `IDSIMULACION` int(11) NOT NULL,
  `IDSUBPRODUCTO` int(11) NOT NULL,
  KEY `FK_RELATIONSHIP_10` (`IDSIMULACION`),
  KEY `FK_RELATIONSHIP_11` (`IDSUBPRODUCTO`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `SUBPRODUCTO`
--

DROP TABLE IF EXISTS `SUBPRODUCTO`;
CREATE TABLE IF NOT EXISTS `SUBPRODUCTO` (
  `IDSUBPRODUCTO` int(11) NOT NULL AUTO_INCREMENT,
  `IDEMPRESA` int(11) NOT NULL,
  `CODSUBPRODUCTO` varchar(50) NOT NULL,
  `DESCSUBPRODUCTO` varchar(100) NOT NULL,
  `PRIMA` decimal(5,2) NOT NULL,
  PRIMARY KEY (`IDSUBPRODUCTO`),
  KEY `FK_RELATIONSHIP_4` (`IDEMPRESA`)
) ENGINE=MyISAM AUTO_INCREMENT=13 DEFAULT CHARSET=latin1;

--
-- Estructura de tabla para la tabla `TIPOUSUARIO`
--

DROP TABLE IF EXISTS `TIPOUSUARIO`;
CREATE TABLE IF NOT EXISTS `TIPOUSUARIO` (
  `IDTIPOUSUARIO` int(11) NOT NULL AUTO_INCREMENT,
  `DESCTIPOUSUARIO` varchar(50) NOT NULL,
  PRIMARY KEY (`IDTIPOUSUARIO`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `TIPOUSUARIO`
--

INSERT INTO `TIPOUSUARIO` (`IDTIPOUSUARIO`, `DESCTIPOUSUARIO`) VALUES
(1, 'Administrador'),
(2, 'Cliente Empresa'),
(3, 'Ejecutivo Ventas');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `USUARIO`
--

DROP TABLE IF EXISTS `USUARIO`;
CREATE TABLE IF NOT EXISTS `USUARIO` (
  `IDUSUARIO` int(11) NOT NULL AUTO_INCREMENT,
  `IDEMPRESA` int(11) NOT NULL,
  `IDTIPOUSUARIO` int(11) NOT NULL,
  `RUTUSUARIO` int(11) NOT NULL,
  `DVUSUARIO` varchar(1) NOT NULL,
  `NOMUSUARIO` varchar(60) NOT NULL,
  `APPATERNO` varchar(50) NOT NULL,
  `APMATERNO` varchar(50) NOT NULL,
  `ESTADO` int(11) NOT NULL,
  `ULTMODIFICACION` datetime NOT NULL,
  `PASSWORD` varchar(64) NOT NULL,
  PRIMARY KEY (`IDUSUARIO`),
  KEY `FK_RELATIONSHIP_1` (`IDTIPOUSUARIO`),
  KEY `FK_RELATIONSHIP_2` (`IDEMPRESA`)
) ENGINE=MyISAM AUTO_INCREMENT=9 DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `USUARIO`
--

INSERT INTO `USUARIO` (`IDUSUARIO`, `IDEMPRESA`, `IDTIPOUSUARIO`, `RUTUSUARIO`, `DVUSUARIO`, `NOMUSUARIO`, `APPATERNO`, `APMATERNO`, `ESTADO`, `ULTMODIFICACION`, `PASSWORD`) VALUES
(1, 1, 1, 11111111, '1', 'Administrador', 'Interno', 'Empresa interna', 1, '2019-08-06 00:00:00', '5f4dcc3b5aa765d61d8327deb882cf99');
COMMIT;
