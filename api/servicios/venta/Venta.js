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
        port: defaultConfig.bdPort
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
    try{
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
            subproductos: req.body.subproductos
        };
        //Acá se valida
        var salida;
        validarSimulacion(simulacion, function(resp){
            salida = resp;

            if(salida.codigo === 0){

                insertarSimulacion(simulacion, function(salida){
                    var codigo;
                    var mensaje;
                    if(salida !== 0){
                        codigo = 0;
                        mensaje = "Simulación ingresada correctamente";
                        
                    }else{
                        codigo = 20,
                        mensaje = "La simulación no ha sido cursada";
                    }
                    res.send({
                        codigo: codigo,
                        mensaje: mensaje
                    });
                });
            }else{
                res.send({
                    codigo: 30,
                    mensaje: "La simulación no es válida"
                });
            }
        });


    }catch(err){
        respuesta = {
            codigo: 3,
            mensaje: "Error" + err
        };
        res.send(respuesta);
    }
    
});

app.post('/rec-simulacion', function(req, res){
    var rutcliente = req.body.rutcliente;
    var fechasimulacion = req.body.fechasimulacion;
    var rutempresa = req.body.rutempresa;
    var query = "CALL SP_GET_SIMULACION_API(" + rutcliente + ", '" + fechasimulacion + "', " + rutempresa + ")";

    var mysql = require('mysql');
    var connection = mysql.createConnection({
        host: defaultConfig.bdServer,
        user: defaultConfig.bdUser,
        password: defaultConfig.bdPassword,
        database: defaultConfig.baseDatos,
        port: defaultConfig.bdPort
    });

    connection.query(query, function(error, results, fields){

        var simulacion = {
            idsimulacion: results[0][0].IDSIMULACION,
            idcampana: results[0][0].IDCAMPANA,
            fechasimulacion: results[0][0].FECHASIMULACION,
            rutvendedor: results[0][0].RUTVENDEDOR,
            dvvendedor: results[0][0].DVVENDEDOR,
            rutcliente: results[0][0].RUTCLIENTE,
            dvcliente: results[0][0].DVCLIENTE,
            monto: results[0][0].MONTO,
            cuotas: results[0][0].CUOTAS,
            valorcuota: results[0][0].VALORCUOTA,
            tasainteres: results[0][0].TASAINTERES,
            tasaanual: results[0][0].TASAANUAL,
            cae: results[0][0].CAE,
            vencimiento: results[0][0].VENCIMIENTO,
            costototal: results[0][0].COSTOTOTAL,
            comision: results[0][0].COMISION,
            codcampana: results[0][0].CODCAMPANA,
            nomcampana: results[0][0].NOMCAMPANA,
            codproducto: results[0][0].CODPRODUCTO,
            descproducto: results[0][0].DESCPRODUCTO,
            rutempresa: results[0][0].RUTEMPRESA,
            dvempresa: results[0][0].DVEMPRESA,
            nomempresa: results[0][0].NOMEMPRESA,
            idsubproducto: results[0][0].IDSUBPRODUCTO
        };
        /*
        var simulacion = {
            idsimulacion: results[0][0].IDSIMULACION,
            idcampana: results[0][0].IDCAMPANA,
            fechasimulacion: results[0][0].FECHASIMULACION,
            rutvendedor: results[0][0].RUTVENDEDOR,
            dvvendedor: results[0][0].DVVENDEDOR,
            rutcliente: results[0][0].RUTCLIENTE,
            dvcliente: results[0][0].DVCLIENTE,
            monto: results[0][0].MONTO,
            cuotas: results[0][0].CUOTAS,
            valorcuota: results[0][0].VALORCUOTA,
            tasainteres: results[0][0].TASAINTERES,
            tasaanual: results[0][0].TASAANUAL,
            cae: results[0][0].CAE,
            vencimiento: results[0][0].VENCIMIENTO,
            costototal: results[0][0].COSTOTOTAL,
            comision: results[0][0].COMISION,
            codcampana: results[0][0].CODCAMPANA,
            nomcampana: results[0][0].NOMCAMPANA,
            codproducto: results[0][0].CODPRODUCTO,
            descproducto: results[0][0].DESCPRODUCTO,
            rutempresa: results[0][0].RUTEMPRESA,
            dvempresa: results[0][0].DVEMPRESA,
            nomempresa: results[0][0].NOMEMPRESA,
            subproductos: []
        }; 
        */
        //console.log(results[0]);
        if(results[0][0].IDSUBPRODUCTO !== null){
            //Tiene al menos uno. Iniciar for en '
        }
        console.log(simulacion);
        //res.send(simulacion);
        
       res.send({});
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

function insertarSimulacion(simulacion, callback){
    
    try{
        var mysql = require('mysql');
        var connection = mysql.createConnection({
            host: defaultConfig.bdServer,
            user: defaultConfig.bdUser,
            password: defaultConfig.bdPassword,
            database: defaultConfig.baseDatos,
            port: defaultConfig.bdPort
        });
        var query = "CALL SP_INS_SIMULACION_API(" + simulacion.rutvendedor + ", '" + simulacion.dvvendedor + "', " + simulacion.rutcliente + ", '" + simulacion.dvcliente + "', " + simulacion.monto + ", " + simulacion.cuotas + ", " + simulacion.valorcuota + ", " + simulacion.tasainteres + ", " + simulacion.tasaanual + ", " + simulacion.cae + ", '" + simulacion.vencimiento + "', " + simulacion.costototal + ", " + simulacion.comision + ", '" + simulacion.codcampana + "', " + simulacion.rutempresa + ")";
        connection.query(query, function(error, results, fields){

            var liid = results[0][0].LIID;
            
            for(var i = 0; i < simulacion.subproductos.length; i++){
                var connection2 = mysql.createConnection({
                    host: defaultConfig.bdServer,
                    user: defaultConfig.bdUser,
                    password: defaultConfig.bdPassword,
                    database: defaultConfig.baseDatos,
                    port: defaultConfig.bdPort
                });
                var query2 = "CALL SP_INS_SIMULACION_SUBPRODUCTO_API(" + liid + ", '" + simulacion.subproductos[i] + "', " + simulacion.rutempresa + ")";
                connection2.query(query2, function(error, results, fields){

                });
                connection2.end();
            }
            
            callback(liid);
        });
        connection.end();
    }catch(err){
        console.log(err);
        callback(0);
    }
}

function validarSimulacion(simulacion, callback){
    try{
        var mysql = require('mysql');
        var connection = mysql.createConnection({
            host: defaultConfig.bdServer,
            user: defaultConfig.bdUser,
            password: defaultConfig.bdPassword,
            database: defaultConfig.baseDatos,
            port: defaultConfig.bdPort
        });
        var query = "CALL SP_VALIDA_SIMULACION_API('" + simulacion.codcampana + "', " + simulacion.rutcliente + ")";

        connection.query(query, function(error, results, fields) {
            var resp = {codigo: results[0][0].CODIGO, mensaje: results[0][0].MENSAJE, idcampana: results[0][0].IDCAMPANA};
            callback(resp);
        });

        connection.end();
    }catch(err){
        var resp = {
            codigo: 3,
            mensaje: err
        };
        callback(resp);
    }
}
//Fin Funciones utilizadas por los api-----------------------------------------------------------------------------