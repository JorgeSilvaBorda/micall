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
        port: defaultConfig.port,
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
app.post('/ins-simulacion', function(req, res) {
    try {
        var simulacion = {
            codcampana: req.body.codcampana,
            rutvendedor: req.body.rutvendedor,
            dvvendedor: req.body.dvvendedor,
            rutcliente: req.body.rutcliente,
            dvcliente: req.body.dvcliente,
            monto: req.body.monto,
            cuotas: req.body.cuotas,
            valorcuota: req.body.valorcuota,
            tasainteres: req.body.tasainteres,
            tasaanual: req.body.tasaanual,
            cae: req.body.cae,
            vencimiento: req.body.vencimiento,
            costototal: req.body.costototal,
            comision: req.body.comision,
            rutempresa: req.body.rutempresa,
            subproductos: req.body.subproductos,
        };
        //Acá se valida
        var salida;
        validarSimulacion(simulacion, function(resp) {
            salida = resp;

            if (salida.codigo === 0) {
                insertarSimulacion(simulacion, function(salida) {
                    var codigo;
                    var mensaje;
                    if (salida !== 0) {
                        codigo = 0;
                        mensaje = 'Simulación ingresada correctamente';
                    } else {
                        (codigo = 20), (mensaje = 'La simulación no ha sido cursada');
                    }
                    res.send({
                        codigo: codigo,
                        mensaje: mensaje,
                    });
                });
            } else {
                res.send({
                    codigo: 30,
                    mensaje: 'La simulación no es válida',
                });
            }
        });
    } catch (err) {
        respuesta = {
            codigo: 3,
            mensaje: 'Error' + err,
        };
        res.send(respuesta);
    }
});

app.post('/rec-simulacion', function(req, res) {
    if (!req.body.rutcliente || !req.body.fechasimulacion || !req.body.rutempresa) {
        //Si no vienen los campos, se retorna error.
        res.send({estado: "error", mensaje: "El request no posee todos los campos mínimos requeridos."});
    }else{
        //Si se corrobora que vienen al menos los tres campos requeridos, se procesa.
        var rutcliente = req.body.rutcliente;
        var fechasimulacion = req.body.fechasimulacion;
        var rutempresa = req.body.rutempresa;

        var query = 'CALL SP_GET_SIMULACION_API(' + rutcliente + ", '" + fechasimulacion + "', " + rutempresa + ')';
        console.log(query);
        var mysql = require('mysql');
        var conn = mysql.createConnection({
            host: defaultConfig.bdServer,
            user: defaultConfig.bdUser,
            password: defaultConfig.bdPassword,
            database: defaultConfig.baseDatos,
            port: defaultConfig.port,
        });

        conn.query(query, function(error, rows, fields) {
            if (rows[0].length > 0) {
                var simulacion = {
                    idsimulacion: rows[0][0].IDSIMULACION,
                    idcampana: rows[0][0].IDCAMPANA,
                    fechasimulacion: rows[0][0].FECHASIMULACION,
                    rutvendedor: rows[0][0].RUTVENDEDOR,
                    dvvendedor: rows[0][0].DVVENDEDOR,
                    rutcliente: rows[0][0].RUTCLIENTE,
                    dvcliente: rows[0][0].DVCLIENTE,
                    monto: rows[0][0].MONTO,
                    cuotas: rows[0][0].CUOTAS,
                    valorcuota: rows[0][0].VALORCUOTA,
                    tasainteres: rows[0][0].TASAINTERES,
                    tasaanual: rows[0][0].TASAANUAL,
                    cae: rows[0][0].CAE,
                    vencimiento: rows[0][0].VENCIMIENTO,
                    costototal: rows[0][0].COSTOTOTAL,
                    comision: rows[0][0].COMISION,
                    codcampana: rows[0][0].CODCAMPANA,
                    nomcampana: rows[0][0].NOMCAMPANA,
                    codproducto: rows[0][0].CODPRODUCTO,
                    descproducto: rows[0][0].DESCPRODUCTO,
                    rutempresa: rows[0][0].RUTEMPRESA,
                    dvempresa: rows[0][0].DVEMPRESA,
                    nomempresa: rows[0][0].NOMEMPRESA,
                    subproductos: [],
                };
                if (rows[0][0].IDSUBPRODUCTO === null) {
                    //No hay subproductos asociados
                    res.send(simulacion);
                } else {
                    console.log(rows[0].length);
                    for (var i = 0; i < rows[0].length; i++) {
                        var subproducto = {
                            idsubproducto: rows[0][i].IDSUBPRODUCTO,
                            codsubproducto: rows[0][i].CODSUBPRODUCTO,
                            descsubproducto: rows[0][i].DESCSUBPRODUCTO,
                            prima: rows[0][i].PRIMA,
                        };
                        simulacion.subproductos.push(subproducto);
                    }
                    res.send(simulacion);
                }
            }
        });
        conn.end();
    }

    
});

app.post('/rec-venta', function(req, res) {
    if (!req.body.rutcliente || !req.body.fechaventa || !req.body.rutempresa || !req.body.codcampana) {
        //Si no vienen los campos, se retorna error.
        res.send({estado: "error", mensaje: "El request no posee todos los campos mínimos requeridos."});
    }else{
        //Si se corrobora que vienen al menos los tres campos requeridos, se procesa.
        var rutcliente = req.body.rutcliente;
        var fechaventa = req.body.fechaventa;
        var rutempresa = req.body.rutempresa;
        var codcampana = req.body.codcampana;

        var query = "CALL SP_GET_VENTA_API(" + rutcliente + ", '" + fechaventa + "', " + rutempresa + ", '" + codcampana + "')";
        var mysql = require('mysql');
        var conn = mysql.createConnection({
            host: defaultConfig.bdServer,
            user: defaultConfig.bdUser,
            password: defaultConfig.bdPassword,
            database: defaultConfig.baseDatos,
            port: defaultConfig.port,
        });

        conn.query(query, function(error, rows, fields) {
            if (rows[0].length > 0) {
                var simulacion = {
                    idsimulacion: rows[0][0].IDSIMULACION,
                    idcampana: rows[0][0].IDCAMPANA,
                    fechasimulacion: rows[0][0].FECHASIMULACION,
                    fechaventa: rows[0][0].FECHAVENTA,
                    rutvendedor: rows[0][0].RUTVENDEDOR,
                    dvvendedor: rows[0][0].DVVENDEDOR,
                    rutcliente: rows[0][0].RUTCLIENTE,
                    dvcliente: rows[0][0].DVCLIENTE,
                    monto: rows[0][0].MONTO,
                    cuotas: rows[0][0].CUOTAS,
                    valorcuota: rows[0][0].VALORCUOTA,
                    tasainteres: rows[0][0].TASAINTERES,
                    tasaanual: rows[0][0].TASAANUAL,
                    cae: rows[0][0].CAE,
                    vencimiento: rows[0][0].VENCIMIENTO,
                    costototal: rows[0][0].COSTOTOTAL,
                    comision: rows[0][0].COMISION,
                    impuesto: rows[0][0].IMPUESTO,
                    codcampana: rows[0][0].CODCAMPANA,
                    nomcampana: rows[0][0].NOMCAMPANA,
                    codproducto: rows[0][0].CODPRODUCTO,
                    descproducto: rows[0][0].DESCPRODUCTO,
                    rutempresa: rows[0][0].RUTEMPRESA,
                    dvempresa: rows[0][0].DVEMPRESA,
                    nomempresa: rows[0][0].NOMEMPRESA,
                    subproductos: [],
                };
                if (rows[0][0].IDSUBPRODUCTO === null) {
                    //No hay subproductos asociados
                    res.send(simulacion);
                } else {
                    for (var i = 0; i < rows[0].length; i++) {
                        var subproducto = {
                            idsubproducto: rows[0][i].IDSUBPRODUCTO,
                            codsubproducto: rows[0][i].CODSUBPRODUCTO,
                            descsubproducto: rows[0][i].DESCSUBPRODUCTO,
                            prima: rows[0][i].PRIMA,
                        };
                        simulacion.subproductos.push(subproducto);
                    }
                    res.send(simulacion);
                }
            }
        });
        conn.end();
    }

    
});

app.post('/rec-usuarios', function(req, res) {
    var query = 'CALL SP_GET_USUARIOS()';
    var mysql = require('mysql');
    var connection = mysql.createConnection({
        host: defaultConfig.bdServer,
        user: defaultConfig.bdUser,
        password: defaultConfig.bdPassword,
        database: defaultConfig.baseDatos,
        port: defaultConfig.port,
    });

    connection.query(query, function(error, result) {
        res.send(result[0]);
    });
    connection.end();
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

function insertarSimulacion(simulacion, callback) {
    try {
        var mysql = require('mysql');
        var connection = mysql.createConnection({
            host: defaultConfig.bdServer,
            user: defaultConfig.bdUser,
            password: defaultConfig.bdPassword,
            database: defaultConfig.baseDatos,
            port: defaultConfig.port,
        });
        var query =
            'CALL SP_INS_SIMULACION_API(' +
            simulacion.rutvendedor +
            ", '" +
            simulacion.dvvendedor +
            "', " +
            simulacion.rutcliente +
            ", '" +
            simulacion.dvcliente +
            "', " +
            simulacion.monto +
            ', ' +
            simulacion.cuotas +
            ', ' +
            simulacion.valorcuota +
            ', ' +
            simulacion.tasainteres +
            ', ' +
            simulacion.tasaanual +
            ', ' +
            simulacion.cae +
            ", '" +
            simulacion.vencimiento +
            "', " +
            simulacion.costototal +
            ', ' +
            simulacion.comision +
            ", '" +
            simulacion.codcampana +
            "', " +
            simulacion.rutempresa +
            ')';
        connection.query(query, function(error, results, fields) {
            var liid = results[0][0].LIID;

            for (var i = 0; i < simulacion.subproductos.length; i++) {
                var connection2 = mysql.createConnection({
                    host: defaultConfig.bdServer,
                    user: defaultConfig.bdUser,
                    password: defaultConfig.bdPassword,
                    database: defaultConfig.baseDatos,
                    port: defaultConfig.port,
                });
                var query2 =
                    'CALL SP_INS_SIMULACION_SUBPRODUCTO_API(' +
                    liid +
                    ", '" +
                    simulacion.subproductos[i] +
                    "', " +
                    simulacion.rutempresa +
                    ')';
                connection2.query(query2, function(error, results, fields) {});
                connection2.end();
            }

            callback(liid);
        });
        connection.end();
    } catch (err) {
        console.log(err);
        callback(0);
    }
}

function validarSimulacion(simulacion, callback) {
    try {
        var mysql = require('mysql');
        var connection = mysql.createConnection({
            host: defaultConfig.bdServer,
            user: defaultConfig.bdUser,
            password: defaultConfig.bdPassword,
            database: defaultConfig.baseDatos,
            port: defaultConfig.port,
        });
        var query = "CALL SP_VALIDA_SIMULACION_API('" + simulacion.codcampana + "', " + simulacion.rutcliente + ')';

        connection.query(query, function(error, results, fields) {
            var resp = {
                codigo: results[0][0].CODIGO,
                mensaje: results[0][0].MENSAJE,
                idcampana: results[0][0].IDCAMPANA,
            };
            callback(resp);
        });

        connection.end();
    } catch (err) {
        var resp = {
            codigo: 3,
            mensaje: err,
        };
        callback(resp);
    }
}
//Fin Funciones utilizadas por los api-----------------------------------------------------------------------------