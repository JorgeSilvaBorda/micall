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
            //console.log(resp);
            var obj = JSON.parse(resp);
            callback(obj);
        }
    });
}

function armarTabla(obj) {
    
    obj.cabeceras.shift();
    console.log(obj.cabeceras);
    var cuerpo = "";
    var opt = {
        rows: obj.cabeceras
    };
    $('#detalle').pivot(obj.registros, opt);
    /*
     $(registros).each(function(){
     
     cuerpo += "<tr>";
     cuerpo += "<td style='font-weight: bold;' >Rut<br />Cargados</td>";
     cuerpo += "<td>" + $(this)[0].rutcargados + "</td>";
     cuerpo += "</tr>";
     
     cuerpo += "<tr>";
     cuerpo += "<td style='font-weight: bold;' >Rut<br />Llamados</td>";
     cuerpo += "<td>" + $(this)[0].rutllamados + "</td>";
     cuerpo += "</tr>";
     
     cuerpo += "<tr>";
     cuerpo += "<td style='font-weight: bold;' >Fonos<br />Cargados</td>";
     cuerpo += "<td>" + $(this)[0].rutfonocargados + "</td>";
     cuerpo += "</tr>";
     
     cuerpo += "<tr>";
     cuerpo += "<td style='font-weight: bold;' >Fonos<br />Llamados</td>";
     cuerpo += "<td>" + $(this)[0].fonosllamados + "</td>";
     cuerpo += "</tr>";
     
     cuerpo += "<tr>";
     cuerpo += "<td style='font-weight: bold;' >Contactados</td>";
     cuerpo += "<td>" + $(this)[0].contactados + "</td>";
     cuerpo += "</tr>";
     
     cuerpo += "<tr>";
     cuerpo += "<td style='font-weight: bold;' >No<br />Contactados</td>";
     cuerpo += "<td>" + $(this)[0].nocontactados + "</td>";
     cuerpo += "</tr>";
     
     cuerpo += "<tr>";
     cuerpo += "<td style='font-weight: bold;' >Ventas</td>";
     cuerpo += "<td>" + $(this)[0].venta + "</td>";
     cuerpo += "</tr>";
     
     cuerpo += "<tr>";
     cuerpo += "<td style='font-weight: bold;' >Contactabilidad<br />Telefónica</td>";
     cuerpo += "<td>" + $(this)[0].contactabilidad + "</td>";
     cuerpo += "</tr>";
     
     cuerpo += "<tr>";
     cuerpo += "<td style='font-weight: bold;' >Contactabilidad<br/>Rut</td>";
     cuerpo += "<td>" + $(this)[0].contactabilidadrut + "</td>";
     cuerpo += "</tr>";
     
     cuerpo += "<tr>";
     cuerpo += "<td style='font-weight: bold;' >Efectividad<br/>BBDD</td>";
     cuerpo += "<td>" + $(this)[0].efectividadbbdd + "</td>";
     cuerpo += "</tr>";
     });
     */
    //$('#cuerpo-indicadores').html(cuerpo);
}