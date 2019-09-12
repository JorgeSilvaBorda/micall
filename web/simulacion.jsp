<%-- 
    Document   : simulacion
    Created on : 02-08-2019, 9:34:53
    Author     : jsilvab
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <script src="funciones/simulador.js" type="text/javascript"></script>
        <title>Simulacion</title>
    </head>
    <body>
        <script type="text/javascript">
            var SIMULACION = null;
            var UF_INDICADOR = 0.00;
            $(document).ready(function () {
                
                OPCIONES_DATATABLES.buttons = [];
                //cargarSimulaciones(); //Quitado para no buscar al inicio.
                cargaSelectEmpresa();
                $('#rutcliente').rut(
                        {
                            formatOn: 'keyup',
                            validateOn: 'blur'
                        }).on('rutInvalido', function () {
                    mostrarAlert('alert-danger', "Rut no válido");
                }).on('rutValido', function () {
                    ocultarAlert();
                });
            });

            function marcarme(idsimulacion, operacion) {
                switch (operacion) {
                    case "vender":
                        vender(idsimulacion);
                        break;
                    case "quitar":
                        quitar(idsimulacion);
                        break;
                }
            }

            function vender(idsimulacion) {
                var datos = {
                    tipo: 'ins-venta',
                    idsimulacion: idsimulacion,
                    rutcliente: $('#rutcliente').val().split("-")[0].replaceAll("\\.", "")
                };

                $.ajax({
                    url: "VentaController",
                    type: 'post',
                    data: {
                        datos: JSON.stringify(datos)
                    },
                    success: function (response) {
                        var obj = JSON.parse(response);
                        if (obj.estado === 'ok') {
                            $('.dataTable').DataTable().destroy();
                            $('#cuerpo-tab-simulacion').html(obj.cuerpotabla);
                            $('#tabla-simulaciones').DataTable(OPCIONES_DATATABLES);
                        }
                    },
                    error: function (a, b, c) {
                        console.log(a);
                        console.log(b);
                        console.log(c);
                    }
                });
            }

            function quitar(idventa) {
                var datos = {
                    tipo: 'del-venta',
                    idventa: idventa,
                    rutcliente: $('#rutcliente').val().split("-")[0].replaceAll("\\.", "")
                };

                $.ajax({
                    url: "VentaController",
                    type: 'post',
                    data: {
                        datos: JSON.stringify(datos)
                    },
                    success: function (response) {
                        var obj = JSON.parse(response);
                        if (obj.estado === 'ok') {
                            $('.dataTable').DataTable().destroy();
                            $('#cuerpo-tab-simulacion').html(obj.cuerpotabla);
                            $('#tabla-simulaciones').DataTable(OPCIONES_DATATABLES);
                        }
                    },
                    error: function (a, b, c) {
                        console.log(a);
                        console.log(b);
                        console.log(c);
                    }
                });
            }

            function cargaSelectEmpresa() {
                var det = {
                    tipo: 'carga-select-empresa',
                    url: 'EmpresaController',
                    objetivo: 'select-empresa'
                };
                cargarSelect(det);
            }

            function cargarSimulaciones() {
                $('#cuerpo-tab-simulacion').html("");
                var rutcliente = $('#rutcliente').val().split("-")[0].replaceAll("\\.", "");
                var detalle = {
                    url: 'SimulacionController',
                    bodyDestino: 'cuerpo-tab-simulacion',
                    datos: {
                        tipo: 'get-simulaciones-rutvendedor-rutcliente',
                        rutcliente: rutcliente,
                        rutvendedor: parseInt('<% out.print(session.getAttribute("rutusuario")); %>')
                    }
                };
                traerListado(detalle, function (cuerpotabla) {
                    $('.dataTable').DataTable().destroy();
                    $('#cuerpo-tab-simulacion').html(cuerpotabla);
                    $('#tabla-simulaciones').DataTable(OPCIONES_DATATABLES);
                });
            }

            function armarModalCampanas(campanas) {

                var tab = "<table id='tab-sel-campana' class='table small table-sm table-striped'><thead>";
                tab += "<tr>";
                tab += "<th>Rut Empresa</th>";
                tab += "<th>Cod. Campaña</th>";
                tab += "<th>Nom. Campaña</th>";
                tab += "<th>Nom. Empresa</th>";
                tab += "<th>Cod. Producto</th>";
                tab += "<th>Desc. Producto</th>";
                tab += "<th>Seleccionar</th>";
                tab += "</tr>";
                tab += "</thead><tbody>";
                $(campanas).each(function () {
                    var rutcliente = $(this)[0].rutcliente;
                    var rutempresa = $(this)[0].rutempresa;
                    var dvempresa = $(this)[0].dvempresa;
                    var nomcampana = $(this)[0].nomcampana;
                    var codcampana = $(this)[0].codcampana;
                    var nomempresa = $(this)[0].nomempresa;
                    var codproducto = $(this)[0].codproducto;
                    var descproducto = $(this)[0].descproducto;
                    var idcampana = $(this)[0].idcampana;
                    var idempresa = $(this)[0].idempresa;

                    tab += "<tr>";
                    tab += "<td>" + $.formatRut(rutempresa + "-" + dvempresa) + "</td>";
                    tab += "<td>" + codcampana + "</td>";
                    tab += "<td>" + nomcampana + "</td>";
                    tab += "<td>" + nomempresa + "</td>";
                    tab += "<td>" + codproducto + "</td>";
                    tab += "<td>" + descproducto + "</td>";
                    tab += "<td><button onclick='seleccionarCampana(" + idcampana + ", " + idempresa + ");' type='button' class='btn btn-sm btn-default'>Seleccionar</button></td>";
                    tab += "</tr>";
                });
                tab += "</tbody></table>";
                $('#cuerpo-modal').html(tab);
                $('#modal-campanas').modal();
            }

            function seleccionarCampana(idcampana, idempresa) {
                var datos = {
                    tipo: 'get-camapana-idcampana-idempresa',
                    idcampana: idcampana,
                    idempresa: idempresa,
                    rutcliente: $('#rutcliente').val().split("-")[0].replaceAll("\\.", "")
                };
                $.ajax({
                    url: 'CampanaController',
                    type: 'post',
                    data: {
                        datos: JSON.stringify(datos)
                    },
                    success: function (res) {
                        var obj = JSON.parse(res);
                        if (obj.estado === 'ok') {
                            pintarDatos(obj.campana, obj.cuerpotabla);
                            cargarSimulaciones();
                            $('#montoaprobado').focus();
                            $('#btnCerrarModal').click();
                        } else {
                            console.log(obj.estado);
                        }
                    }
                });

            }

            function buscar() {
                if ($('#select-empresa').val() === '0') {
                    alert("Debe seleccionar la empresa para la que se desea simular.");
                    return false;
                }
                var idempresa = $('#select-empresa').val();
                var rutcliente = $('#rutcliente').val().split("-")[0].replaceAll("\\.", "");
                var datos = {
                    tipo: 'get-campana-empresa-rutcliente',
                    idempresa: idempresa,
                    rutcliente: rutcliente.split("-")[0].replaceAll("\\.", "")
                };

                $.ajax({
                    url: 'CampanaController',
                    type: 'post',
                    data: {
                        datos: JSON.stringify(datos)
                    },
                    success: function (res) {
                        var obj = JSON.parse(res);
                        if (obj.estado === 'ok') {
                            if (obj.campanas.length > 1) {
                                //Son varias campañas para el rut. Escoger...
                                armarModalCampanas(obj.campanas);
                                //Las simulaciones para el rut en este caso, se cargan en: seleccionarCampana()
                            } else {
                                pintarDatos(obj.campanas[0], obj.cuerpotabla);
                                $('#montoaprobado').focus();
                                cargarSimulaciones(); //Cuando es campaña única, se cargan las simulaciones hechas previamente al rut
                            }

                        } else {
                            alert(obj.mensaje);
                        }
                    }
                });
            }

            function validarCampos() {
                calcTasaAnual();
                var simulacion = {
                    idcampana: $('#hidIdCampana').val(),
                    rutvendedor: '<% out.print(session.getAttribute("rutusuario")); %>',
                    dvvendedor: '<% out.print(session.getAttribute("dvusuario"));%>',
                    rutcliente: $('#rutcliente').val().split("-")[0].replaceAll("\\.", ""),
                    dvcliente: $('#rutcliente').val().split("-")[1],
                    monto: parseInt($('#montoaprobado').val().replaceAll("\\.", "")),
                    cuotas: $('#cuotas').val().replaceAll("\\.", ""),
                    valorcuota: $('#valorcuota').val().replaceAll("\\.", ""),
                    tasainteres: $('#tasainteres').val(),
                    tasaanual: $('#tasaanual').val(),
                    cae: $('#cae').val(),
                    vencimiento: $('#vencimiento').val(),
                    costototal: parseInt($('#costototal').val().replaceAll("\\.", "")),
                    comision: $('#comision').val().replaceAll("\\.", ""),
                    subproductos: []
                };
                $('#tab-subproductos tbody tr').each(function (t) {
                    var fila = $(this)[0];
                    var celdas = $(fila.cells);
                    var celda_0 = $(celdas[0]);
                    var check = $(celda_0).children('input');
                    if (check[0].checked) { //Si el check de subproducto se encuentra marcado, mapear los subproductos
                        var celda_1 = $(celdas[1]);
                        var hidden = $(celda_1).children('input')[1];
                        var idsubproducto = $(hidden).val();
                        simulacion.subproductos.push(idsubproducto);
                    }
                });
                if (simulacion.idcampana === '' ||
                        simulacion.cae === '' ||
                        simulacion.comision === '' ||
                        simulacion.costototal === '' ||
                        simulacion.cuotas === '' ||
                        simulacion.dvcliente === '' ||
                        simulacion.dvvendedor === '' ||
                        simulacion.idcampana === '' ||
                        simulacion.monto === '' ||
                        simulacion.rutcliente === '' ||
                        simulacion.rutvendedor === '' ||
                        simulacion.tasainteres === '' ||
                        simulacion.tasaanual === '' ||
                        simulacion.valorcuota === '' ||
                        simulacion.vencimiento === '') {

                    alert("No ha ingresado todos los campos.");
                    return false;
                }
                var hoy = getDateHoy('-');
                if (diffFechas(hoy, simulacion.vencimiento) < 30) {
                    alert('La fecha de vencimiento debe ser de por lo menos 30 días a contar de hoy.');
                    return false;
                }

                var montoAprobado = $('#hidMontoAprobado').val();
                if (simulacion.monto > montoAprobado) {
                    alert('El monto de la simulación no puede ser superior al monto aprobado ($' + formatMiles(montoAprobado) + ')');
                    return false;
                }
                if (simulacion.costototal <= simulacion.monto) {
                    alert("El costo total debe ser mayor que el monto.");
                    return false;
                }

                var costocuotas = parseInt(simulacion.valorcuota) * parseInt(simulacion.cuotas);
                //20190825 - Se valida contra el monto simulado (No contra el monto aprobado).
                if (!(costocuotas > simulacion.monto)) {
                    alert("El valor cuota multiplicado por la cantidad de cuotas ($" + formatMiles(costocuotas) + "), debe ser mayor al monto simulado ($" + formatMiles(simulacion.monto) + ")");
                    return false;
                }
                if ((costocuotas > simulacion.costototal)) {
                    alert("El valor cuota multiplicado por la cantidad de cuotas ($" + formatMiles(costocuotas) + "), debe ser menor o igual al costo total ($" + formatMiles(simulacion.costototal) + ")");
                    return false;
                }
                var tasa = parseFloat($('#tasainteres').val().replaceAll(",", "."));
                if (tasa < 0.01) {
                    alert("Debe ingresar una tasa de interés válida");
                    return false;
                }

                var tasaAnual = parseFloat($('#tasaanuual').val());
                if (tasaAnual < 0.001) {
                    alert("La tasa anual no pede ser menor a 0.001");
                    return false;
                }
                SIMULACION = simulacion;
                return true;
            }

            function calcularTodo() {
                if ($('#cuotas').val() !== '' && $('#cuotas').val() !== 0 && $('#montoaprobado').val().replaceAll("\\.", "") !== '' && $('#tasainteres').val() !== '') {
                    calcValores();
                }
            }

            function calcValores() {
                var UF = 26672.2;
                var topeUF = 50;
                var topeDinero = topeUF * UF;
                var simulacion = {
                    cuotas: parseInt($('#cuotas').val()),
                    valorcuota: 0,
                    costototal: 0,
                    monto: parseInt($('#montoaprobado').val().replaceAll("\\.", "")),
                    montoaprobado: parseInt($('#hidMontoAprobado').val()),
                    tasainteres: parseFloat($('#tasainteres').val()),
                    tasaanual: (parseFloat($('#tasainteres').val()) * 12),
                    tasaimpuesto: 0.0,
                    montoasegurado: 0,
                    montoseguro: 0,
                    tasaseguro: 0.0,
                    impuestoalcredito: 0,
                    montoafecto: 0,
                    montonoafecto: 0,
                    montoacapitalizar: 0,
                    subproductos: []
                };
                $('#tab-subproductos tbody tr').each(function (t) {
                    var fila = $(this)[0];
                    var celdas = $(fila.cells);
                    var celda_0 = $(celdas[0]);
                    var check = $(celda_0).children('input');
                    if (check[0].checked) { //Si el check de subproducto se encuentra marcado, mapear los subproductos
                        var celda_1 = $(celdas[1]);
                        var celda_3 = $(celdas[3]);
                        var hidden = $(celda_1).children('input')[1];
                        var idsubproducto = $(hidden).val();
                        var prima = parseFloat($(celda_3).text());
                        var sub = {idsubproducto: idsubproducto, prima: prima};
                        simulacion.subproductos.push(sub);
                    }
                });

                var impuesto = 0;
                if (simulacion.cuotas + 1 > 12) {
                    impuesto = 0.008;
                } else {
                    impuesto = 0.00066 * (simulacion.cuotas + 1);
                }
                simulacion.tasaimpuesto = impuesto;
                //Trabajar solo con el primer seguro
                if (simulacion.subproductos.length > 0) {
                    var subproducto = simulacion.subproductos[0];
                    simulacion.tasaseguro = subproducto.prima / 100;
                    var tasaSeguro = (subproducto.prima / 100);
                    var montoAsegurado;
                    if ((simulacion.monto / (1 - tasaSeguro - simulacion.tasaimpuesto)) > topeDinero) {
                        montoAsegurado = topeDinero;
                    } else {
                        montoAsegurado = simulacion.monto / (1 - tasaSeguro - simulacion.tasaimpuesto);
                    }
                    simulacion.montoasegurado = parseInt(montoAsegurado);
                    simulacion.montoseguro = parseInt(simulacion.montoasegurado * tasaSeguro);
                } else {
                    var tasaSeguro = 0;
                    if ((simulacion.monto / (1 - tasaSeguro - simulacion.tasaimpuesto)) > topeDinero) {
                        montoAsegurado = topeDinero;
                    } else {
                        montoAsegurado = simulacion.monto / (1 - tasaSeguro - simulacion.tasaimpuesto);
                    }
                    simulacion.montoasegurado = parseInt(montoAsegurado);
                    simulacion.montoseguro = parseInt(simulacion.montoasegurado * tasaSeguro);
                }


                var montoAfecto = 0;
                if ((simulacion.monto / (1 - simulacion.tasaseguro - simulacion.tasaimpuesto)) > topeDinero) {
                    montoAfecto = topeDinero;
                } else {
                    montoAfecto = (simulacion.monto / (1 - simulacion.tasaseguro - simulacion.tasaimpuesto));
                }
                simulacion.montoafecto = montoAfecto;
                simulacion.montonoafecto = simulacion.monto - simulacion.montoafecto;
                var impuestoAlCredito = (simulacion.montoasegurado * simulacion.tasaimpuesto) + (simulacion.montonoafecto / (1 - simulacion.tasaimpuesto) - simulacion.montonoafecto);
                simulacion.impuestoalcredito = parseInt(impuestoAlCredito);
                var montoACapitalizar = 0;
                montoACapitalizar = simulacion.montoafecto * (1 / (1 - simulacion.tasaseguro - simulacion.tasaimpuesto)) + simulacion.montonoafecto * (1 / (1 - simulacion.tasaimpuesto));
                simulacion.montoacapitalizar = parseInt(montoACapitalizar);
                var valorCuota = (((simulacion.montoacapitalizar) * (simulacion.tasainteres / 100) / (1 - Math.pow((1 + (simulacion.tasainteres / 100)), -simulacion.cuotas))));
                simulacion.valorcuota = parseInt(valorCuota);
                simulacion.costototal = parseInt(simulacion.valorcuota * simulacion.cuotas);

                $('#valorcuota').val(formatMiles(simulacion.valorcuota.toString()));
                $('#costototal').val(formatMiles(simulacion.costototal.toString()));
                $('#impuesto').val(formatMiles(parseInt(simulacion.impuestoalcredito).toString()));

                $('#cae').val(truncDecimales(cae(simulacion.cuotas, simulacion.monto, simulacion.valorcuota), 2));
                simulacion.cae = truncDecimales(cae(simulacion.cuotas, simulacion.monto, simulacion.valorcuota), 2);
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

            function insert() {
                if (validarCampos()) {
                    var simulacion = {
                        idcampana: $('#hidIdCampana').val(),
                        rutvendedor: '<% out.print(session.getAttribute("rutusuario")); %>',
                        dvvendedor: '<% out.print(session.getAttribute("dvusuario"));%>',
                        rutcliente: $('#rutcliente').val().split("-")[0].replaceAll("\\.", ""),
                        dvcliente: $('#rutcliente').val().split("-")[1],
                        monto: $('#montoaprobado').val().replaceAll("\\.", ""),
                        cuotas: $('#cuotas').val().replaceAll("\\.", ""),
                        valorcuota: $('#valorcuota').val().replaceAll("\\.", ""),
                        tasainteres: $('#tasainteres').val(),
                        tasaanual: $('#tasaanual').val(),
                        cae: $('#cae').val(),
                        vencimiento: $('#vencimiento').val(),
                        costototal: $('#costototal').val().replaceAll("\\.", ""),
                        comision: $('#comision').val().replaceAll("\\.", ""),
                        impuesto: $('#impuesto').val().replaceAll("\\.", ""),
                        subproductos: []
                    };
                    $('#tab-subproductos tbody tr').each(function (t) {
                        var fila = $(this)[0];
                        var celdas = $(fila.cells);
                        var celda_0 = $(celdas[0]);
                        var check = $(celda_0).children('input');
                        if (check[0].checked) { //Si el check de subproducto se encuentra marcado, mapear los subproductos
                            var celda_1 = $(celdas[1]);
                            var hidden = $(celda_1).children('input')[1];
                            var idsubproducto = $(hidden).val();
                            simulacion.subproductos.push({idsubproducto: idsubproducto});
                        }
                    });
                    var detalle = {
                        url: 'SimulacionController',
                        datos: {
                            tipo: 'ins-simulacion',
                            simulacion: simulacion
                        }
                    };
                    insertar(detalle, function (obj) {
                        limpiar();
                        cargarSimulaciones();
                    });
                    cargarSimulaciones();
                }
            }

            function calcTasaAnual() {
                var valido = false;
                /**
                 * Inicializar en '0.0'.
                 * Cualquier error no controlado la dejará por defecto en cero.
                 * Validador debe controlar que sea mayor a 0.01
                 */

                var tasainteres = $('#tasainteres').val().toString();
                if (tasainteres.indexOf(".") === -1 && tasainteres.indexOf(",") === -1) {
                    //validar isNaN
                    if (isNaN(tasainteres)) {//##1
                        //console.log("Tasa interés no numérica");
                        $('#tasaanual').val(0.0); //
                    } else {
                        var tasaA = parseFloat(tasainteres) * 12;
                        tasaA = Number((parseFloat(tasaA)).toFixed(2)); //Incorporados como redondeo
                        $('#tasaanual').val(tasaA);
                        valido = true;
                    }
                } else {
                    if (tasainteres.indexOf(",") !== -1) {
                        tasainteres = tasainteres.relaceAll(",", ".");
                    }

                    var tasaA = parseFloat(tasainteres) * 12;
                    tasaA = Number((parseFloat(tasaA)).toFixed(2)); //Incorporados como redondeo
                    $('#tasaanual').val(tasaA);
                    valido = true;
                }
                if (!valido) {
                    $('#tasaanual').val(0.0);
                }
            }

            function verSubproductosVendidos(idsimulacion) {
                var datos = {
                    tipo: 'get-subproductos-simulacion',
                    idsimulacion: idsimulacion
                };

                $.ajax({
                    type: 'post',
                    url: 'SimulacionController',
                    data: {
                        datos: JSON.stringify(datos)
                    },
                    success: function (resp) {
                        var obj = JSON.parse(resp);
                        if (obj.estado === 'ok') {
                            //pintar popup
                            $('#cuerpo-modal-subproductos').html(armarTablaSubproductos(obj.subproductos));
                            $('#modal-subproductos').modal();
                        }
                    }
                });
            }

            function armarTablaSubproductos(subproductos) {
                var tab = "<table id='tab-subproductos' class='table-sm small' style='border: none; border-collapse: collapse;'><thead>";
                tab += "<tr>";
                tab += "<th>Subproducto</th>";
                tab += "<th>% Prima</th>";
                tab += "<th>$ Prima</th>";
                tab += "</tr></thead><tbody>";
                $(subproductos).each(function () {
                    tab += "<tr>";
                    tab += "<td>[" + $(this)[0].codsubproducto + "] " + $(this)[0].descsubproducto + "</td>";
                    tab += "<td>" + $(this)[0].prima + " %</td>";
                    tab += "<td>$ " + $(this)[0].montoseguro + "</td>";
                    tab += "</tr>";
                });
                tab += "</tbody></table>";
                return tab;
            }

            function pintarDatos(campana, subproductos) {
                //console.log(campana);
                $('#hidIdCampana').val(campana.idcampana);
                $('#hidMontoAprobado').val(campana.montoaprobado);
                $('#cuerpo-subproductos').html(subproductos);
                $('#codcampana').html(campana.codcampana);
                $('#codproducto').html(campana.codproducto);
                $('#nomcampana').html(campana.nomcampana);
                $('#descproducto').html(campana.descproducto);
                $('#fechaini').html(campana.fechaini);
                $('#nomcliente').html(campana.nomcliente);
                $('#fechafin').html(campana.fechafin);
                $('#apellidoscliente').html(campana.apellidoscliente);
                $('#montometa').html(campana.montometa);
                $('#direccion').html(campana.direccion);
                $('#montoaprobado').val(formatMiles(campana.montoaprobado));
                $('#montometa').html(formatMiles(campana.meta));
            }

            function limpiar() {
                $('#hidIdCampana').val('');
                $('#hidMontoAprobado').val('');
                $('#cuerpo-subproductos').html('');
                $('#codcampana').html('');
                $('#codproducto').html('');
                $('#nomcampana').html('');
                $('#descproducto').html('');
                $('#fechaini').html('');
                $('#nomcliente').html('');
                $('#fechafin').html('');
                $('#apellidoscliente').html('');
                $('#montometa').html('');
                $('#direccion').html('');
                $('#montoaprobado').val('');
                $('#montometa').html('');
                //$('#rutcliente').val(''); //No limpiar RutCliente 

                //Limpieza de inputs
                $('#valorcuota').val('');
                $('#tasaanual').val('');
                $('#cuotas').val('');
                $('#tasainteres').val('');
                $('#cae').val('');
                $('#costototal').val('');
                $('#vencimiento').val('');
                $('#comision').val('');
                $('#impuesto').val('');
                $('#select-empresa').val('0');
                SIMULACION = null;
            }

            function mostrarAlert(clase, mensaje) {
                $('#alerta').addClass(clase);
                $('#alerta').html('<strong>Error!</strong> <span>' + mensaje + '</span>');
                $('#mensaje-alerta').html(mensaje);
                $('#alerta').fadeIn(500);
                $('#alerta').removeClass('oculto');
            }

            function ocultarAlert() {
                $('#alerta').fadeOut(500);
                $('#alerta').html('');
            }

            // -- Test Simulador--------------------------------------------------

            function generar() {
                var montosolicitado = parseInt($('#montoaprobado').val().replaceAll("\\.", ""));
                var cuotas = parseInt($('#cuotas').val());
                var tasainteres = parseFloat($('#tasainteres').val());
                var PRIMA = 0.0;
                var comision = parseInt($('#comision').val().replaceAll("\\.", ""));
                var topeUf = 50;
                var simulacion = simular(montosolicitado, cuotas, tasainteres, PRIMA, comision, topeUf);
                
                var tabla = document.getElementById('tab-subproductos');
                var trs = tabla.getElementsByTagName("tr");
                for(var i = 0; i < trs.length; i++){
                    var tds = trs[i].getElementsByTagName("td");
                    for(var x = 0; x < tds.length; x ++){
                        console.log(tds[x].innerHTML);
                    }
                }
                
                /*
                $('#tab-subproductos tbody tr').each(function (t) {
                    var fila = $(this)[0];
                    var celdas = $(fila.cells);
                    var celda_0 = $(celdas[0]);
                    var check = $(celda_0).children('input');
                    if (check[0].checked) { //Si el check de subproducto se encuentra marcado, mapear los subproductos
                        var celda_1 = $(celdas[1]);
                        var celda_3 = $(celdas[3]);
                        var hidden = $(celda_1).children('input')[1];
                        var idsubproducto = $(hidden).val();
                        var prima = parseFloat($(celda_3).text());
                        var sub = {idsubproducto: idsubproducto, prima: prima};
                        if (parseFloat($(celda_3).text()) > 0) {
                            simulacion = simular(montosolicitado, cuotas, tasainteres, parseFloat($(celda_3).text()), comision, topeUf);
                        }
                    }
                });
                */
                console.log(simulacion);
                //console.log(montosolicitado + "  " + cuotas + "  " + tasainteres + "  " + PRIMA + "  " + comision + "  " + topeUf);
            }

            function getPrima(callback) {

            }
        </script>
        <div class="container-fluid">
            <!-- The Modal -->
            <div class="modal fade" id="modal-campanas">
                <div class="modal-dialog modal-lg">
                    <div class="modal-content">

                        <!-- Modal Header -->
                        <div class="modal-header">
                            <h4 class="modal-title">Campañas</h4>
                            <button type="button" class="close" data-dismiss="modal">&times;</button>
                        </div>

                        <!-- Modal body -->
                        <div class="modal-body" id='cuerpo-modal'>

                        </div>

                        <!-- Modal footer -->
                        <div class="modal-footer">
                            <p>El rut seleccionado se ha cargado para más de una campaña. Por favor seleccione una</p>
                            <button type="button" id='btnCerrarModal' class="btn btn-secondary" data-dismiss="modal">Cerrar</button>
                        </div>

                    </div>
                </div>
            </div>

            <div class="modal fade" id="modal-subproductos">
                <div class="modal-dialog modal-lg" >
                    <div class="modal-content">

                        <!-- Modal Header -->
                        <div class="modal-header">
                            <h4 class="modal-title">Subproductos</h4>
                            <button type="button" class="close" data-dismiss="modal">&times;</button>
                        </div>

                        <!-- Modal body -->
                        <div class="modal-body" id='cuerpo-modal-subproductos'>

                        </div>

                        <!-- Modal footer -->
                        <div class="modal-footer">
                            <button type="button" id='btnCerrarModal' class="btn btn-secondary btn-sm" data-dismiss="modal">Cerrar</button>
                        </div>

                    </div>
                </div>
            </div>

            <input type='hidden' id='hidIdCampana' value='' />
            <input type='hidden' id='hidMontoAprobado' value='' />
            <br />
            <br />
            <br />
            <div class="row">
                <div class="col-sm-12">
                    <h2>Simulación manual</h2>
                </div>
            </div>
            <div class="row">
                <div class="col-sm-2">
                    <form>
                        <div class="form-group small">
                            <label for="rutcliente">Rut</label>
                            <input id="rutcliente" type="text" class="form-control form-control-sm" placeholder="Indique el rut del cliente" />

                            <div id="alerta" class="alert oculto">

                            </div>

                        </div>
                        <div class="form-group small">
                            <label for="select-empresa">Empresa</label>
                            <select class="form-control form-control-sm" id="select-empresa">

                            </select>
                        </div>
                        <div class="form-group small">
                            <button type='button' onclick='buscar();' class='btn btn-primary btn-sm' id='btnBuscar'>Buscar</button>
                        </div>
                    </form>

                </div>
                <div class='col-sm-6'>
                    <table id='tab-detalles' class='table-sm small' style='border: none; border-collapse: collapse;'>
                        <tr>
                            <td style='font-weight: bold;'>Cod. Campaña</td>
                            <td id='codcampana'></td>

                            <td style='font-weight: bold;'>Cod. producto</td>
                            <td id='codproducto'></td>
                            <td>
                            </td>
                        </tr>
                        <tr>
                            <td style='font-weight: bold;'>Nom. Campaña</td>
                            <td id='nomcampana'></td>
                            <td style='font-weight: bold;'>Desc. producto</td>
                            <td id='descproducto'></td>
                        </tr>
                        <tr>
                            <td style='font-weight: bold;'>Fecha ini</td>
                            <td id='fechaini'></td>

                            <td style='font-weight: bold;'>Nombre cliente</td>
                            <td id='nomcliente'></td>

                        </tr>
                        <tr>
                            <td style='font-weight: bold;'>Fecha fin</td>
                            <td id='fechafin'></td>

                            <td style='font-weight: bold;'>Apellidos cliente</td>
                            <td id='apellidoscliente'></td>
                        </tr>
                        <tr>
                            <td style='font-weight: bold;'>Dirección</td>
                            <td id='direccion'></td>
                        </tr>
                        <tr>
                            <td style='font-weight: bold;'>Monto aprobado</td>
                            <td>
                                <input onkeyup="formatMilesInput(this);
                                        calcularTodo();" class='form-control form-control-sm cambiante' type='text' id='montoaprobado' value=''/>
                            </td>

                            <td style='font-weight: bold;'>Cuotas</td>
                            <td>
                                <input onkeyup="calcularTodo();" class='form-control form-control-sm cambiante' type='text' id='cuotas' value=''/>
                            </td>
                        </tr>
                        <tr>
                            <td style='font-weight: bold;'>Valor cuota</td>
                            <td>
                                <input disabled="disabled" onchange="formatMilesInput(this);" class='form-control form-control-sm' type='text' id='valorcuota' value=''/>
                            </td>

                            <td style='font-weight: bold;'>Tasa interés</td>
                            <td>
                                <input class='form-control form-control-sm' onkeyup="calcTasaAnual();
                                        calcularTodo();" type='number' step='0.01' id='tasainteres' value=''/>
                            </td>
                        </tr>
                        <tr>
                            <td style='font-weight: bold;'>Tasa anual</td>
                            <td>
                                <input class='form-control form-control-sm' disabled="disabled" type='number' step='0.01' id='tasaanual' value=''/>
                            </td>
                            <td style='font-weight: bold;'>CAE</td>
                            <td>
                                <input disabled="disabled" class='form-control form-control-sm' type='number' step='0.01' id='cae' value=''/>
                            </td> 
                        </tr>
                        <tr>
                            <td style='font-weight: bold;'>Vencimiento</td>
                            <td>
                                <input class='form-control form-control-sm' type='date' id='vencimiento' value=''/>
                            </td>
                            <td style='font-weight: bold;'>Costo total</td>
                            <td>
                                <input disabled="disabled" onchange="formatMilesInput(this);" class='form-control form-control-sm' type='text' id='costototal' value=''/>
                            </td>
                        </tr>
                        <tr>
                            <td style='font-weight: bold;'>Comisión</td>
                            <td>
                                <input onkeyup="formatMilesInput(this);" class='form-control form-control-sm' type='text' id='comision' value=''/>
                            </td>
                            <td style='font-weight: bold;'>Impuesto</td>
                            <td>
                                <input disabled="disabled" onchange="formatMilesInput(this);" class='form-control form-control-sm' type='text' id='impuesto' value=''/>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <button onclick="insert();" type="button" class="btn btn-primary btn-sm">Simular</button>
                            </td>
                            <td>
                                <button onclick='limpiar();' type="button" class="btn btn-default btn-sm">Limpiar</button>
                            </td>
                            <td colspan="2" ></td>
                        </tr>
                    </table>
                </div>
                <div class='col-sm-4'>
                    <span style='font-weight: bold;'>Subproductos</span>
                    <table id='tab-subproductos' class='table-sm small' style='border: none; border-collapse: collapse;'>
                        <thead>
                            <tr>
                                <th>Sel</th>
                                <th>Código</th>
                                <th>Descripcion</th>
                                <th>Prima</th>
                                <!-- th>Monto meta</th -->
                                <!-- th>Cant. meta</th -->
                            </tr>
                        </thead>
                        <tbody id='cuerpo-subproductos'>

                        </tbody>

                    </table>
                </div>
            </div>
            <div class="row">
                <br />
                <h3>Simulaciones Ingresadas Del Día</h3>
                <div class="col-sm-12" id="listado">
                    <table id="tabla-simulaciones" class="table table-sm small table-borderless table-hover table-striped">
                        <thead>
                            <tr>
                                <th>Producto</th>
                                <th>Monto</th>
                                <th>#<br />Cuotas</th>
                                <th>$<br />Cuota</th>
                                <th>$<br />Impuesto al crédito</th>
                                <th>$<br />CTC</th>
                                <th>%<br />Tasa</th>
                                <th>%<br />CAE</th>
                                <th>Subproductos</th>
                                <th>Venta</th>
                            </tr>
                        </thead>
                        <tbody id="cuerpo-tab-simulacion">

                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </body>
</html>
