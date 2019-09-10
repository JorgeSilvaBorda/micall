function simular(montosolicitado, cuotas, tasainteres, primaseguro, comision, topeuf) {
    var MONTOTOPE = montotope(getUf(), topeuf);
    var TASAIMPUESTO = tasaimpuesto(cuotas);
    var TASASEGURO = tasaseguro(primaseguro);
    var MONTOASEGURADO = montoasegurado(montosolicitado, TASASEGURO, TASAIMPUESTO, MONTOTOPE);
    var MONTOSEGURO = montoseguro(MONTOASEGURADO, TASASEGURO);
    var MONTOAFECTO = montoafecto(montosolicitado, TASASEGURO, TASAIMPUESTO, MONTOSEGURO, MONTOASEGURADO);
    var MONTONOAFECTO = montonoafecto(montosolicitado, MONTOAFECTO);
    var IMPUESTOALCREDITO = impuestoalcredito(MONTOASEGURADO, TASAIMPUESTO, MONTONOAFECTO, MONTOAFECTO);
    var MONTOSAVACAPITALIZAR = montosavacapitalizar(MONTOAFECTO, TASASEGURO, MONTONOAFECTO, TASAIMPUESTO);
    var VALORCUOTA = valorcuota(MONTOSAVACAPITALIZAR, tasainteres, cuotas);
    var simulacion = {
        montosolicitado: montosolicitado,
        cuotas: cuotas,
        tasainteresmensual: tasainteres,
        comision: comision,
        tasainteresanual: (tasainteres * 12),
        tasaimpuesto: TASAIMPUESTO,
        impuestoalcredito: IMPUESTOALCREDITO,
        montoafecto: MONTOAFECTO,
        montonoafecto: MONTONOAFECTO,
        montosavacapitalizar: MONTOSAVACAPITALIZAR,
        costototal: (VALORCUOTA * cuotas),
        cme: cme(cuotas, montosolicitado, VALORCUOTA),
        cae: cae(cuotas, montosolicitado, VALORCUOTA),
        ufmomento: getUf(),
        seguro: []
    };
    if (this.primaseguro > 0) {
        simulacion.seguro = {
            topeuf: 50,
            montotope: MONTOTOPE,
            montoasegurado: MONTOASEGURADO,
            montoseguro: MONTOSEGURO,
            tasaseguro: TASASEGURO,
            primaseguro: primaseguro
        };
    }
    return simulacion;
}

function tasaseguro(prima) {
    return (prima / 100);
}

function topedinero(uf, topeuf) {
    return (uf * topeuf);
}

function tasaimpuesto(cuotas) {
    if ((cuotas + 1) > 12) {
        return 0.008;
    } else {
        return ((cuotas + 1) * 0.00066);
    }
}

function montoasegurado(montosolicitado, tasaseguro, tasaimpuesto, montotope) {
    if (montosolicitado / (1 - tasaseguro - tasaimpuesto) > montotope) {
        return montotope;
    } else {
        return (montosolicitado / (1 - tasaseguro - tasaimpuesto) > montotope);
    }
}
function montoseguro(montoasegurado, tasaseguro) {
    return (montoasegurado * tasaseguro);
}

function montoafecto(montosolicitado, tasaseguro, tasaimpuesto, montoseguro, montoasegurado) {
    if (montosolicitado / (1 - tasaseguro - tasaimpuesto) > montoseguro) {
        return (montoasegurado - montoseguro - (montoasegurado * tasaimpuesto));
    } else {
        return montosolicitado;
    }
}

function montonoafecto(montosolicitado, montoafecto) {
    return (montosolicitado - montoafecto);
}

function impuestoalcredito(montoasegurado, tasaimpuesto, montonoafecto, montoafecto) {
    return (montoasegurado * tasaimpuesto) + (montonoafecto / (1 - tasaimpuesto) - montoafecto);
}

function montosavacapitalizar(montoafecto, tasaseguro, montonoafecto, tasaimpuesto) {
    return (montoafecto * (1 / (1 - tasaseguro - tasaimpuesto)) + montonoafecto * (1 / (1 - tasaimpuesto)));
}

function valorcuota(montosavacapitalizar, tasainteres, cuotas) {
    return (((montosavacapitalizar) * (tasainteres / 100) / (1 - Math.pow((1 + (tasainteres / 100)), -cuotas))));
}

function montotope(uf, topeuf) {
    return (uf * topeuf);
}

function getUf() {
    return 26672.2;
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
    return cme(cuotas, monto, valorcuota) * 12;
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