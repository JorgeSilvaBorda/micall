function simular(montosolicitado, cuotas, tasainteres, primaseguro, comision, topeuf) {

    this.montotope = function () {
        return (parseInt(getUf()) * topeuf);
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
        var montoAsegurado;
        if ((montosolicitado / (1 - this.tasaseguro() - this.tasaimpuesto())) > this.montotope) {
            montoAsegurado = this.montotope;
        } else {
            montoAsegurado = montosolicitado / (1 - this.tasaseguro() - this.tasaimpuesto());
        }
        return montoAsegurado;
        /*
         if ((montosolicitado / (1 - this.tasaseguro() - this.tasaimpuesto())) > this.montotope()) {
         return this.montotope();
         } else {
         return (montosolicitado / (1 - this.tasaseguro() - this.tasaimpuesto()));
         }
         */
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
        var impuestoAlCredito = (this.montoasegurado() * this.tasaimpuesto()) + (this.montonoafecto() / (1 - this.tasaimpuesto() - this.montoafecto()));
        return impuestoAlCredito;
        //return ((this.montoasegurado() * this.tasaimpuesto()) + (this.montonoafecto() / (1 - this.tasaimpuesto() - this.montoafecto())));
    };
    this.montosavacapitalizar = function () {
        return (this.montoafecto() * (1 / (1 - this.tasaseguro() - this.tasaimpuesto())) + this.montonoafecto() * (1 / (1 - this.tasaimpuesto())));
    };
    this.valorcuota = function () {
        return (((this.montosavacapitalizar()) * (tasainteres / 100) / (1 - Math.pow((1 + (tasainteres / 100)), -cuotas))));
    };
    var simulacion = {
        idcampana: null,
        rutvendedor: null,
        dvvendedor: null,
        rutcliente: null,
        dvcliente: null,
        vencimiento: null,
        idgrupo: null,
        monto: montosolicitado,
        cuotas: cuotas,
        tasainteres: tasainteres,
        comision: comision,
        tasaanual: (tasainteres * 12),
        tasaimpuesto: this.tasaimpuesto(),
        impuesto: this.impuestoalcredito(),
        montoafecto: this.montoafecto(),
        montonoafecto: this.montonoafecto(),
        montosavacapitalizar: this.montosavacapitalizar(),
        valorcuota: this.valorcuota(),
        costototal: (this.valorcuota() * cuotas),
        cae: cae(cuotas, montosolicitado, this.valorcuota()),
        ufmomento: getUf(),
        subproductos: [],
        seguro: []
    };
    if (primaseguro > 0) {
        var montoTopeSeguro = this.montotope();
        var montoAseguradoSeguro = this.montoasegurado();
        var montoSeguro = this.montoseguro();
        var tasaSeguro = this.tasaseguro();
        simulacion.seguro = {
            topeuf: topeuf,
            montotope: montoTopeSeguro,
            montoasegurado: montoAseguradoSeguro,
            montoseguro: montoSeguro,
            tasaseguro: tasaSeguro,
            primaseguro: primaseguro
        };
    }

    return simulacion;
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

function getUf() {
    return UF_HOY;
}

