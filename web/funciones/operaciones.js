

function traerListado(detalle) {
    $.ajax({
        type: 'post',
        url: detalle.url,
        data: {
            datos: JSON.stringify(detalle.datos)
        },
        success: function (res) {
            var obj = JSON.parse(res);
            if (obj.estado === 'ok') {
                $('#' + detalle.bodyDestino).html(obj.cuerpotabla);
            } else {
                console.log("Error");
                console.log(obj.mensaje);
            }
        },
        error: function (a, b, c) {
            console.log(a);
            console.log(b);
            console.log(c);
        }
    });
}

function insertar(detalle) {
    $.ajax({
        type: 'post',
        url: detalle.url,
        data: {
            datos: JSON.stringify(detalle.datos)
        },
        success: function (res) {
            var obj = JSON.parse(res);
            if (obj.estado === 'ok') {
                
            }
        },
        error: function (a, b, c) {
            console.log(a);
            console.log(b);
            console.log(c);
        }
    });
}

function guardar(detalle) {
    $.ajax({
        type: 'post',
        url: detalle.url,
        data: {
            datos: JSON.stringify(detalle.datos)
        },
        success: function (res) {
            var obj = JSON.parse(res);
            if (obj.estado === 'ok') {

            } else {
                console.log(obj.mensaje);
            }
        }
    });
}

function eliminar(detalle) {
    $.ajax({
        url: detalle.url,
        type: 'post',
        data: {
            datos: JSON.stringify(detalle.datos)
        },
        success: function (res) {
            var obj = JSON.parse(res);
            if (obj.estado === 'ok') {

            } else {
                console.log(obj.mensaje);
            }
        }
    });
}

function cargarSelect(detalle) {
    var datos = {
        tipo: detalle.tipo
    };
    $.ajax({
        type: 'post',
        url: detalle.url,
        cache: false,
        data: {
            datos: JSON.stringify(datos)
        },
        success: function (res) {
            var obj = JSON.parse(res);
            if (obj.estado === 'ok') {
                $('#' + detalle.objetivo).html('');
                $('#' + detalle.objetivo).html(obj.options);
            }
        },
        error: function (a, b, c) {
            console.log(a);
            console.log(b);
            console.log(c);
        }
    });
}