var CAMPANAS = [];
$(document).ready(function () {
    cargarIni();
    var OPCIONES_EXCEL = [
        {
            extend: 'excelHtml5',
            title: 'MiCall-Resultante-Mes-' + formatFecha(new Date())
        }
    ];
    OPCIONES_DATATABLES.buttons = OPCIONES_EXCEL;
});

function cargarIni() {
    cargarSelectCampana(function (obj) {
        $('#select-campana').html(obj.options);
        CAMPANAS = obj.campanas;
    });
}

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

function buscarEjecutivos() {
    cargarTabla(function (obj) {
        armarTabla(obj);
    });
}

function cargarTabla(callback) {
    var idcampana = $('#select-campana').val();
    var datos = {
        tipo: 'ejecutivos',
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
    $('.dataTable').DataTable().destroy();
    $('#cuerpo-ejecutivos').html(obj.cuerpo);
    $('#tabla-ejecutivos').DataTable(OPCIONES_DATATABLES);
}