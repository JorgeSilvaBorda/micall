

function traerListado(detalle, callback) {
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
                callback(obj.cuerpotabla);
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

function insertar(detalle, callback) {
    $.ajax({
        type: 'post',
        url: detalle.url,
        data: {
            datos: JSON.stringify(detalle.datos)
        },
        success: function (res) {
            var obj = JSON.parse(res);
            if (obj.estado === 'ok') {
                callback(obj);
                alert('Registros ingresados correctamente.');
            }
        }
    });
}

function guardar(detalle, callback) {
    $.ajax({
        type: 'post',
        url: detalle.url,
        data: {
            datos: JSON.stringify(detalle.datos)
        },
        success: function (res) {
            var obj = JSON.parse(res);
            if (obj.estado === 'ok') {
                callback(obj);
            } else {
                console.log(obj.mensaje);
            }
        },
        error: function(a, b, c){
            console.log(a);
            console.log(b);
            console.log(c);
        }
    });
}

function eliminar(detalle, callback) {
    $.ajax({
        url: detalle.url,
        type: 'post',
        data: {
            datos: JSON.stringify(detalle.datos)
        },
        success: function (res) {
            var obj = JSON.parse(res);
            if (obj.estado === 'ok') {
                callback(obj);
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
    
    //var datos = detalle.datos;
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

/**
 * 
 * @param {type} detalle
 * @param {type} paramSelect
 * @returns {undefined}
 */
function cargarSelectUnParam(detalle){
    /**
     * var detalle debe contener el parámetro "paramselect".
     * Cuyo tipo y valor debe ser incluido en la raiz del arreglo y, 
     * que además debe ser parseado y validado también por el controlador.
     * Ej:
     * var detalle = {
     *      tipo: 'carga-select-objeto',
     *      url: ObjetoController,
     *      objetivo: select-objeto,
     *      paramselect: [parámetro] //!Important
     * };
     * 
     * Donde [parámetro] será utilizado por la consulta a BD en Controlador.
     */
    $.ajax({
        type: 'post',
        url: detalle.url,
        cache: false,
        data: {
            datos: JSON.stringify(detalle.datos, paramSelect)
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

function cargarSelectParams(detalle) {
    $.ajax({
        type: 'post',
        url: detalle.url,
        cache: false,
        data: {
            datos: JSON.stringify(detalle.datos)
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

function traerJson(detalle){
    var salida;
    $.ajax({
        url: detalle.url,
        type: 'post',
        async: false,
        data: {
            datos: JSON.stringify(detalle.datos)
        },
        success: function(res){
            var obj = JSON.parse(res);
            if(obj.estado === 'ok'){
                console.log(obj.json);
                salida = obj.json;
            }
        }
        
    });
    return salida;
}