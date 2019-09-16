function simular(montosolicitado, cuotas, tasainteres, primaseguro, comision, topeuf) {


    this.montotope = function () {
        return (getUf() * topeuf);
    };
    this.tasaseguro = function () {
        return (primaseguro / 100);
    };
    this.tasaimpuesto = function () {
        if ((cuotas + 1) > 12) {
            return 0.008;
        } else {
            return ((cuotas + 1) * 0.00066);
        }
    };
    this.montoasegurado = function () {
        if (montosolicitado / (1 - this.tasaseguro() - this.tasaimpuesto()) > montotope) {
            return montotope;
        } else {
            return (montosolicitado / (1 - this.tasaseguro() - this.tasaimpuesto()) > montotope);
        }
    };
    this.montoseguro = function () {
        return (this.montoasegurado() * this.tasaseguro());
    };
    this.montoafecto = function () {
        if (montosolicitado / (1 - this.tasaseguro() - this.tasaimpuesto()) > this.montoseguro()) {
            return (this.montoasegurado() - this.montoseguro() - (this.montoasegurado() * this.tasaimpuesto()));
        } else {
            return montosolicitado;
        }
    };
    this.montonoafecto = function () {
        return (montosolicitado - this.montoafecto());
    };
    this.impuestoalcredito = function () {
        return (this.montoasegurado() * this.tasaimpuesto()) + (this.montonoafecto() / (1 - this.tasaimpuesto()) - this.montoafecto());
    };
    this.montosavacapitalizar = function () {
        return (this.montoafecto() * (1 / (1 - this.tasaseguro() - this.tasaimpuesto())) + this.montonoafecto() * (1 / (1 - this.tasaimpuesto())));
    };
    this.valorcuota = function () {
        return (((this.montosavacapitalizar()) * (tasainteres / 100) / (1 - Math.pow((1 + (tasainteres / 100)), -cuotas))));
    };
    var simulacion = {
        montosolicitado: montosolicitado,
        cuotas: cuotas,
        tasainteresmensual: tasainteres,
        comision: comision,
        tasainteresanual: (tasainteres * 12),
        tasaimpuesto: this.tasaimpuesto(cuotas),
        impuestoalcredito: this.impuestoalcredito(this.montoasegurado(), this.tasaimpuesto(), this.montonoafecto(), this.montoafecto()),
        montoafecto: this.montoafecto(),
        montonoafecto: this.montonoafecto(),
        montosavacapitalizar: this.montosavacapitalizar(),
        costototal: (this.valorcuota() * cuotas),
        cme: cme(cuotas, montosolicitado, this.valorcuota()),
        cae: cae(cuotas, montosolicitado, this.valorcuota()),
        ufmomento: getUf(),
        seguro: []
    };
    if (primaseguro > 0) {
        simulacion.seguro = {
            topeuf: 50,
            montotope: this.montotope(),
            montoasegurado: this.montoasegurado(),
            montoseguro: this.montoseguro(),
            tasaseguro: this.tasaseguro(),
            primaseguro: primaseguro
        };
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
        return UF_HOY;
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
}