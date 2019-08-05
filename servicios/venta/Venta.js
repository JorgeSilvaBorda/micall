var express = require('express');
var app = express();
var bodyParser = require('body-parser');
var config = require('../config.json');
var defaultConfig = config.dev;

//Inicio del servidor----------------------------------------------------------------------------------------------
var server = app.listen(defaultConfig.puerto, function() {
    console.log('Servidor Ventas listening on ' + defaultConfig.puerto);
    var mysql = require('mysql');
    var connection = mysql.createConnection({
        host: defaultConfig.bdServer,
        user: defaultConfig.bdUser,
        password: defaultConfig.bdPassword,
        database: defaultConfig.baseDatos,
    });
    connection.connect();

    connection.query('SELECT 1 + 1 AS solution', function(error, results, fields) {
        if (error) {
            throw error;
        } else {
            console.log('Conexión verificada OK');
        }
    });

    connection.end();
});

app.use(function(req, res, next) {
    //Incorporación de cabeceras para admitir CORS.
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET,POST');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    next();
});

app.use(bodyParser.json()); //Incorporación de body-parser: json().
app.use(
    bodyParser.urlencoded({
        extended: true,
    })
); //Incorporación de opción urlencoded
// Fin Configuración del servidor----------------------------------------------------------------------------------

//Servicios de respuesta-------------------------------------------------------------------------------------------
app.get('/test', function(req, res) {
    var salida = {
        status: 'OK',
        servicio: 'test',
    };
    res.send(salida);
});

app.post('/ins-simulacion', function(req, res) {
    var mysql = require('mysql');
    var connection = mysql.createConnection({
        host: defaultConfig.bdServer,
        user: defaultConfig.bdUser,
        password: defaultConfig.bdPassword,
        database: defaultConfig.baseDatos,
    });

    try {
        var simulacion = {
            codprodperiod: req.body.codprodperiod,
            rutvendedor: req.body.rutvendedor,
            dvvendedor: req.body.dvvendedor,
            rutcliente: req.body.rutcliente,
            dvcliente: req.body.dvcliente,
            monto: req.body.monto,
            fecha: req.body.fecha,
            vencimiento: req.body.vencimiento,
            cuotas: req.body.cuotas,
            valorcuota: req.body.valorcuota,
            costototal: req.body.costototal,
            tasainteres: req.body.tasainteres,
            tasaanual: req.body.tasaanual,
            cae: req.body.cae,
            comision: req.body.comision,
            porcentajes1: req.body.porcentajes1,
            porcentajes2: req.body.porcentajes2,
            montoseguro: req.body.montoseguro,
        };

        //console.log(simulacion);
        var query =
            'CALL SP_INS_SIMULACION(' +
            simulacion.codprodperiod +
            ', ' +
            simulacion.rutvendedor +
            ", '" +
            simulacion.dvvendedor +
            "', " +
            simulacion.rutcliente +
            ", '" +
            simulacion.dvcliente +
            "', " +
            simulacion.monto +
            ", '" +
            simulacion.fecha +
            "', '" +
            simulacion.vencimiento +
            "', " +
            simulacion.cuotas +
            ', ' +
            simulacion.valorcuota +
            ', ' +
            simulacion.costototal +
            ', ' +
            simulacion.tasainteres +
            ', ' +
            simulacion.tasaanual +
            ', ' +
            simulacion.cae +
            ', ' +
            simulacion.comision +
            ', ' +
            simulacion.porcentajes1 +
            ', ' +
            simulacion.porcentajes2 +
            ', ' +
            simulacion.montoseguro +
            ')';

        //console.log(query);

        connection.connect();
        connection.query(query, function(error, results, fields) {
            if (error) {
                res.send({
                    estado: 'error',
                    codigoRespuesta: 10,
                    error: 'Problemas al ejecutar la operación en base de datos.',
                });
                //throw error;
            } else {
                if (results.affectedRows === 1) {
                    res.send({
                        estado: 'ok',
                        codigoRespuesta: 0,
                        mensaje: 'Registro insertado correctamente.',
                    });
                } else {
                    res.send({
                        estado: 'error',
                        mensaje: error,
                        codigoRespuesta: 1,
                    });
                }
            }
        });
    } catch (err) {
        console.log('error al ejecutar ins-simulacion');
        console.log(err);
        res.send({
            estado: 'error',
            mensaje: 'Error al ejecutar ins-simulacion',
            codigoRespuesta: 1,
        });
    }
});

app.post('/rec-simulacion', function(req, res) {
    var mysql = require('mysql');
    var connection = mysql.createConnection({
        host: defaultConfig.bdServer,
        user: defaultConfig.bdUser,
        password: defaultConfig.bdPassword,
        database: defaultConfig.baseDatos,
    });

    try {
        var simulacion = {
            rutcliente: req.body.rutcliente,
            fecha: req.body.fecha,
        };

        var query = 'CALL SP_REC_SIMULACION(' + simulacion.rutcliente + ", '" + simulacion.fecha + "')";
        connection.connect();
        connection.query(query, function(error, results, fields) {
            if (error) {
                res.send({
                    estado: 'error',
                    codigoRespuesta: 10,
                    error: 'Problemas al ejecutar la operación en base de datos.',
                });
            } else {
                try {
                    var simulacion = {
                        rutcliente: results[0][0].RUTCLIENTE,
                        dvcliente: results[0][0].DVCLIENTE.toString(),
                        rutvendedor: results[0][0].RUTVENDEDOR,
                        dvvendedor: results[0][0].DVVENDEDOR.toString(),
                        codigo: results[0][0].CODIGO.toString(),
                        producto: results[0][0].PRODUCTO.toString(),
                        rutempresa: results[0][0].RUTEMPRESA,
                        dvempresa: results[0][0].DVEMPRESA.toString(),
                        empresa: results[0][0].EMPRESA.toString(),
                        monto: results[0][0].MONTO,
                        fecha: formatFecha(results[0][0].FECHA),
                        cuotas: results[0][0].CUOTAS,
                        valorcuota: results[0][0].VALORCUOTA,
                        tasainteres: results[0][0].TASAINTERES,
                        tasaanual: results[0][0].TASAANUAL,
                        cae: results[0][0].CAE,
                        vencimiento: formatFecha(results[0][0].VENCIMIENTO),
                        costototal: results[0][0].COSTOTOTAL,
                        comision: results[0][0].COMISION,
                        porcentajes1: results[0][0].PORCENTAJES1,
                        porcentajes2: results[0][0].PORCENTAJES2,
                        montoseguro: results[0][0].MONTOSEGURO,
                    };
                    res.send({
                        estado: 'ok',
                        codigoRespuesta: 0,
                        simulacion: simulacion,
                    });
                } catch (err) {
                    res.send({
                        estado: 'error',
                        codigoRespuesta: 12,
                        mensaje: err,
                    });
                }
            }
        });
        connection.end();
    } catch (err) {
        console.log('Error al ejecutar rec-simulacion');
        console.log(err);
        res.send({
            estado: 'error',
            codigoRespuesta: 1,
            error: 'Error al ejecutar ins-simulacion',
        });
    }
});

app.post('/rec-productos-empresa', function(req, res) {
    var mysql = require('mysql');
    var connection = mysql.createConnection({
        host: defaultConfig.bdServer,
        user: defaultConfig.bdUser,
        password: defaultConfig.bdPassword,
        database: defaultConfig.baseDatos,
    });
    try {
        var datos = {
            rutempresa: parseInt(req.body.rutempresa),
            rutusuario: parseInt(req.body.rutusuario),
            passusuario: req.body.passusuario,
        };

        var query =
            'CALL SP_GET_CAMPANAS_USUARIO_EMPRESA(' +
            datos.rutusuario +
            ', ' +
            datos.rutempresa +
            ", '" +
            datos.passusuario +
            "')";
        connection.connect();
        connection.query(query, function(error, results, fields) {
            if (error) {
                res.send({
                    estado: 'Error',
                    mensaje: 'No se pudo obtener el listado de productos para la empresa.',
                    err: error,
                });
            } else {
                res.send({
                    estado: 'ok',
                    productos: results,
                });
            }
        });
        connection.end();
    } catch (err) {
        console.log('Error al ejecutar rec-productos-empresa');
        console.log(err);
        res.send({
            estado: 'Error',
            mensaje: 'No se pudo obtener el listado de productos para la empresa.',
            error: 'Error al ejecutar rec-productos-empresa',
        });
    }
});

//Fin Servicios de respuesta---------------------------------------------------------------------------------------

//Funciones utilizadas por los api---------------------------------------------------------------------------------
function formatFecha(fecha) {
    var fec = new Date(fecha);
    var sep = '-';
    var mes = fec.getMonth() + 1 < 10 ? '0' + (fec.getMonth() + 1) : fec.getMonth() + 1;
    var dia = fec.getDate() < 10 ? '0' + fec.getDate() : fec.getDate();
    var date = fec.getFullYear() + sep + mes + sep + dia;
    return date;
}
//Fin Funciones utilizadas por los api-----------------------------------------------------------------------------