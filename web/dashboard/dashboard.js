function traerMil(callback) {
    var datos = {
        tipo: 'repo'
    };
    $.ajax({
        url: 'DashboardController',
        type: 'post',
        data: {
            datos: JSON.stringify(datos)
        },
        success: function (resp) {
            var obj = JSON.parse(resp);
            callback(obj);
        },
        error: function (a, b, c) {
            var error = {
                error1: a,
                error2: b,
                error3: c
            };
            callback(error);
        }
    });
}

function traerActual() {
    var datos = {
        tipo: 'repo-snapshot'
    };
    $.ajax({
        url: 'DashboardController',
        type: 'post',
        data: {
            datos: JSON.stringify(datos)
        },
        success: function (resp) {
            var obj = JSON.parse(resp);
            callback(obj);
        },
        error: function (a, b, c) {
            var error = {
                error1: a,
                error2: b,
                error3: c
            };
            callback(error);
        }
    });
}

