var CAMPANAS = [];
$(document).ready(function () {
    cargarSelectCampana(function (obj) {
        $('#select-campana').html(obj.options);
        CAMPANAS = obj.campanas;
    });
});
function cargarSelectCampana(callback) {
    var datos = {tipo: 'select-campanas-new'};
    $.ajax({
        url: 'CampanaController',
        type: 'post',
        data: {
            datos: JSON.stringify(datos)
        },
        success: function (resp) {
            var obj = JSON.parse(resp);
            if (obj.estado === 'ok') {
                callback(obj);
            }
        }
    });
}

function traeDatosCampana() {
    var idcampana = parseInt($('#select-campana').val());
    if (idcampana === 0) {
        $("#desde").val('');
        $("#hasta").val('');
    } else {
        $("#desde").val(CAMPANAS[CAMPANAS.findIndex(x => x.idcampana === idcampana)].fechaini);
        $("#hasta").val(CAMPANAS[CAMPANAS.findIndex(x => x.idcampana === idcampana)].fechafin);
    }
}

function buscar() {
    cargarTabla(function (obj) {
        armarTabla(obj);
    });
}

function cargarTabla(callback) {
    var idcampana = $('#select-campana').val();
    var datos = {
        tipo: 'bbdd',
        idcampana: idcampana
    };
    $.ajax({
        url: 'ReportesController',
        type: 'post',
        data: {
            datos: JSON.stringify(datos)
        },
        success: function (resp) {
            var obj = JSON.parse(resp);
            callback(obj);
        }
    });
}

function armarTabla(obj) {

    obj.cabeceras.shift();
    var fechaini = obj.fechaini;
    var fechafin = obj.fechafin;

    var anio = fechaini.split("-")[0].toString();
    var mes = fechaini.split("-")[1].toString();
    var diafin = parseInt(fechafin.split("-")[2]);


    var tabla = "<table class='table table-condensed table-striped' style='font-size:10px;'><thead>";
    tabla += "<tr>";
    tabla += "<th>" + obj.cabeceras[0] + "</th>";
    tabla += "<th>" + obj.cabeceras[1] + "</th>";
    for (var i = 2; i < obj.cabeceras.length; i++) {
        var encabezado = obj.cabeceras[i].split("-")[2];
        tabla += "<th>" + reemplazarConcepto(encabezado) + "</th>";
    }
    tabla += "</tr>";
    tabla += "</thead>";
    tabla += "<tbody>";
    for (var i = 0; i < obj.registros.length; i++) {
        tabla += "<tr>";
        tabla += "<td style='font-weight: bold;'>" + reemplazarConcepto(obj.registros[i]["CONCEPTO"]) + "</td>";
        tabla += "<td style='font-weight: bold;'>" + obj.registros[i]["TOTAL"] + "</td>";
        for (var x = 1; x <= diafin; x++) {
            var dia = x;
            if (parseInt(dia) < 10) {
                dia = "0" + dia;
            }

            var campo = obj.registros[i][anio + "-" + mes + "-" + dia];
            if (campo.indexOf(".") !== -1) {
                campo = truncDecimales(campo, 2);
            }
            tabla += "<td>" + campo + "</td>";
        }
        tabla += "</tr>";
    }
    tabla += "</tbody>";
    tabla += "</table>";
    $('#detalle').html(tabla);
    //Forma de resolverlo con PIVOT---------------------------------------------
    //var opt = {
    //    rows: obj.cabeceras
    //};
    //$('#detalle').pivot(obj.registros, opt);
    //--------------------------------------------------------------------------
}

function reemplazarConcepto(concepto) {
    switch (concepto) {
        case "RUTCARGADOS":
            return "BBDD - Cargados";
            break;
        case "RUTLLAMADOS":
            return "Recorrido Por Rut";
            break;
            /*case "RUTFONOCARGADOS":
             return "Recorrido Por Fono";
             break;*/
        case "FONOSLLAMADOS":
            return "Recorrido Por Fono";
            break;
        case "CONTACTADOS":
            return "Contactados";
            break;
        case "NOCONTACTADOS":
            return "No Contactados";
            break;
        case "VENTA":
            return "Ventas";
            break;
        case "CONTACTABILIDAD":
            return "Contactabilidad/BBDD";
            break;
        case "EFECTIVIDADBBDD":
            return "Efectividad/BBDD";
            break;
        default:
            return concepto;
            break;

    }
}

function reemplazarTexto(texto) {
    switch (texto) {
        case "RUTCARGADOS":
            return "BBDD - Cargados";
            break;
        case "RUTLLAMADOS":
            return "Recorrido Por Rut";
            break;
        case "RUTFONOCARGADOS":
            return "Fonos Cargados";
            break;
        case "FONOSLLAMADOS":
            return "Recorrido Por Fono";
            break;
        case "CONTACTADOS":
            return "Contactados";
            break;
        case "NOCONTACTADOS":
            return "No Contactados";
            break;
        case "VENTA":
            return "Ventas";
            break;
        case "CONTACTABILIDAD":
            return "Contactabilidad/BBDD";
            break;
        case "CONTACTABILIDADRUT":
            return "Contactabilidad/Rut";
            break;
        case "EFECTIVIDADBBDD":
            return "Efectividad BBDD";
            break;
        default:
            return texto;
            break;
    }
}