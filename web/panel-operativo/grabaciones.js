var CAMPANAS = [];
$(document).ready(function () {
    cargarIni();
    OPCIONES_DATATABLES.buttons = [];
});

function cargarIni() {
    cargarSelectCampana(function (obj) {
        $('#select-campana').html(obj.options);
        CAMPANAS = obj.campanas;
    });
}

function cargarSelectCampana(callback) {
    console.log("va a cargar");
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

function buscarGrabaciones() {
    $('.dataTable').DataTable().destroy();
    cargarTabla(function (obj) {
        armarTabla(obj);
    });
}

function cargarTabla(callback) {
    var idcampana = $('#select-campana').val();
    var datos = {
        tipo: 'grabaciones',
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
    OPCIONES_DATATABLES.buttons = [];

    if (parseInt(obj.registros) > 0) {
        var OPCIONES_EXCEL = [
            {
                extend: 'excelHtml5',
                title: ''
            }
        ];
        OPCIONES_DATATABLES.buttons = OPCIONES_EXCEL;
    }
    $('.dataTable').DataTable().destroy();
    $('#cuerpo-grabaciones').html(obj.cuerpo);
    $('#tabla-grabaciones').DataTable(OPCIONES_DATATABLES);
}