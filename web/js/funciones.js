var UF_HOY = 26672.2;
var OPCIONES_DATATABLES = {
    dom: 'Bfrtip',
    buttons: false,
    "language": {
        "lengthMenu": "Mostrar _MENU_ registros por página",
        "zeroRecords": "Nada encontrado",
        "info": "Mostrando página _PAGE_ de _PAGES_",
        "infoEmpty": "No records available",
        "infoFiltered": "(filtered from _MAX_ total records)",
        "paginate": {
            "previous": "Anterior",
            "next": "Siguiente"
        },
        "search": "Buscar"
    },
    "paging": true,
    "ordering": true,
    "drawCallback": function () {
        $('.dataTables_paginate > .pagination').addClass('pagination-sm');
    }
};

var OPCIONES_FIXED = {
    header: true,
    headerOffset: $('#navbar').outerHeight()
};

var ARR_CUOTAS = [12, 24, 36, 48];

String.prototype.replaceAll = function (search, replacement) {
    var target = this;
    return target.replace(new RegExp(search, 'g'), replacement);
};

function getDateHoy(sep) {
    var today = new Date();
    var mes = ((today.getMonth() + 1) < 10 ? '0' + (today.getMonth() + 1) : today.getMonth() + 1);
    var dia = (today.getDate() < 10 ? '0' + today.getDate() : today.getDate());
    var date = today.getFullYear() + sep + mes + sep + dia;
    return date;
}

function formatMilesInput(input) {
    input.value = input.value.toString();
    var num = input.value.replace(/\./g, "");
    if (!isNaN(num)) {
        num = num.toString().split("").reverse().join("").replace(/(?=\d*\.?)(\d{3})/g, '$1.');
        num = num.split("").reverse().join("").replace(/^[\.]/, "");
        input.value = num;
    } else {
        input.value = input.value.replace(/[^\d\.]*/g, "");
    }
}

function formatMiles(valor) {
    valor = valor.toString();
    var num = valor.replace(/\./g, "");
    if (!isNaN(num)) {
        num = num.toString().split("").reverse().join("").replace(/(?=\d*\.?)(\d{3})/g, '$1.');
        num = num.split("").reverse().join("").replace(/^[\.]/, "");
        return num;
    } else {
        console.log("No se puede formatear.");
        valor = valor.replace(/[^\d\.]*/g, "");
        return valor;
    }
}

function diffFechas(fechaini, fechafin) {
    if (fechaini.indexOf("-") !== -1) {
        fechaini = fechaini.replaceAll("-", "/");
    }
    if (fechafin.indexOf("-") !== -1) {
        fechafin = fechafin.replaceAll("-", "/");
    }
    /*
     var fecIni = new Date(fechaini.split("-")[0], fechaini.split("-")[2], fechaini.split("-")[2]);
     var fecFin = new Date(fechafin.split("-")[0], fechafin.split("-")[2], fechafin.split("-")[2]);
     */
    var fecIni = new Date(fechaini);
    var fecFin = new Date(fechafin);

    //var diffTime = Math.abs(fecFin.getTime() - fecIni.getTime());
    var diffTime = (fecFin.getTime() - fecIni.getTime());
    var diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

    return diffDays;
}

function fechaIntToString(fecha) {
    if (fecha.length < 6) {
        return "0000-00-00";
    }
    var anio = fecha.substring(0, 4);
    var mes = fecha.substring(4, 6);
    var dia = fecha.substring(6, 8);

    return (anio + "-" + mes + "-" + dia);
}

function formatFecha(date) {
    var mesInt = date.getMonth() + 1;
    var diaInt = date.getDate();
    var anioInt = date.getFullYear();

    var mesString = mesInt.toString();
    var diaString = diaInt.toString();
    var anioString = anioInt.toString();

    if (mesInt < 10) {
        mesString = '0' + mesString;
    }
    if (diaInt < 10) {
        diaString = '0' + diaString;
    }

    var fec = anioString + '-' + mesString + '-' + diaString;
    return fec;
}

function formatFechaChile(date) {
    var mesInt = date.getMonth() + 1;
    var diaInt = date.getDate();
    var anioInt = date.getFullYear();

    var mesString = mesInt.toString();
    var diaString = diaInt.toString();
    var anioString = anioInt.toString();

    if (mesInt < 10) {
        mesString = '0' + mesString;
    }
    if (diaInt < 10) {
        diaString = '0' + diaString;
    }

    var fec = diaString + '-' + mesString + '-' + anioString;
    return fec;
}

function truncDecimales(numero, decimales) {
    var numString = numero.toString();
    if (numString.indexOf(".") !== -1) {
        var num = numString.split(".")[0];
        var dec = numString.split(".")[1];
        var salida = num + "." + dec.substring(0, decimales);
        return parseFloat(salida);
    }

    if (numString.indexOf(",") !== -1) {
        var num = numString.split(",")[0];
        var dec = numString.split(",")[1];
        var salida = num + "." + dec.substring(0, decimales);
        return parseFloat(salida);
    }
}

function cme(cuotas, monto, valorcuota) {
    //var contador = 0;
    var iff = 50.0000000;
    var iff2 = 50.0000000;
    var totalActualizado = 0.0;

    while (totalActualizado !== monto) {
        totalActualizado = caeParcial(iff, cuotas, monto, valorcuota);
        iff2 = iff2 / 2;
        if (totalActualizado < monto) {
            iff = iff - iff2;
        }
        if (totalActualizado > monto) {
            iff = iff + iff2;
        }
    }
    var CME = iff;
    return CME;
}

function cae(cuotas, monto, valorcuota) {
    var iff = 50.0000000;
    var iff2 = 50.0000000;
    var totalActualizado = 0.0;

    while (totalActualizado !== monto) {
        totalActualizado = caeParcial(iff, cuotas, monto, valorcuota);
        iff2 = iff2 / 2;
        if (totalActualizado < monto) {
            iff = iff - iff2;
        }
        if (totalActualizado > monto) {
            iff = iff + iff2;
        }
    }
    var CME = iff;
    var CAE = iff * 12;
    return CAE;
}

function caeParcial(iff, contcuotas, monto, valorcuota) {
    var contador = 0;
    var total_valor_actualizado = 0.0;
    var valor_act_ini = 0.0;
    var valor_actual = 0.0;
    var fact_actual = 0.0;
    while (contador <= contcuotas) {
        fact_actual = 1 / Math.pow((1 + (iff / 100)), contador);
        if (contador === 1) {
            valor_act_ini = (valorcuota) * fact_actual;
        }
        if (contador > 1) {
            valor_actual = valorcuota * fact_actual;
        }
        contador++;
        total_valor_actualizado = valor_actual + total_valor_actualizado;
    }
    total_valor_actualizado = total_valor_actualizado + valor_act_ini;
    return parseInt(total_valor_actualizado);
}

function guardarArchivo(url) {
    var filename = url.substring(url.lastIndexOf("/") + 1).split("?")[0];
    var xhr = new XMLHttpRequest();
    xhr.responseType = 'blob';
    xhr.onload = function () {
        var a = document.createElement('a');
        a.href = window.URL.createObjectURL(xhr.response);
        a.download = filename;
        a.style.display = 'none';
        document.body.appendChild(a);
        a.click();
        delete a;
    };
    xhr.open('GET', url);
    xhr.send();
}