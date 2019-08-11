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
        <title>Simulacion</title>
    </head>
    <body>
        <script type="text/javascript">
            $(document).ready(function () {
                cargarSimulaciones();
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

            function cargarSimulaciones() {
                var detalle = {
                    url: 'SimulacionController',
                    bodyDestino: 'cuerpo-tab-simulacion',
                    datos: {
                        tipo: 'get-simulaciones-rutvendedor',
                        rutvendedor: parseInt('<% out.print(session.getAttribute("rutusuario")); %>')
                    }
                };

                traerListado(detalle);
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
                    //console.log(campanas);
                });

                tab += "</tbody></table>";
                $('#cuerpo-modal').html(tab);
                $('#modal-campanas').modal();
            }

            function seleccionarCampana(idcampana, idempresa) {
                var datos = {
                    tipo: 'get-camapana-idcampana-idempresa',
                    idcampana: idcampana,
                    idempresa: idempresa
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
                            $('#montoaprobado').focus();
                            $('#btnCerrarModal').click();
                        } else {
                            console.log(obj.estado);
                        }
                    }
                });

            }

            function buscar() {
                var idempresa = '<% out.print(session.getAttribute("idempresa"));%>';
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
                            } else {
                                pintarDatos(obj.campanas[0], obj.cuerpotabla);
                                $('#montoaprobado').focus();
                            }

                        } else {
                            alert(obj.mensaje);
                        }
                    }
                });
            }

            function validarCampos() {
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
                if(simulacion.costototal <= simulacion.monto){
                    alert("El costo total debe ser mayor que el monto.");
                    return false;
                }
                
                var costocuotas = parseInt(simulacion.valorcuota) * parseInt(simulacion.cuotas);
                if(!(costocuotas > montoAprobado)){
                    alert("El valor cuota multiplicado por la cantidad de cuotas ($" + formatMiles(costocuotas) + "), debe ser mayor al monto aprobado ($" + formatMiles(montoAprobado) + ")");
                    return false;
                }
                if(!(costocuotas <= simulacion.costototal)){
                    alert("El valor cuota multiplicado por la cantidad de cuotas ($" + formatMiles(costocuotas) + "), debe ser menor o igual al costo total ($" + formatMiles(simulacion.costototal) + ")");
                    return false;
                }
                
                return true;
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
                }
            }
            
            function calcTasaAnual(){
                var tasa = parseFloat($('#tasainteres').val().replaceAll(",", "."));
                var tasaAnual = (tasa * 12).toString();
                var decimales = "";
                var enteros = "";
                if(tasaAnual.indexOf(",") !== -1){
                   decimales = tasaAnual.split(",")[1];
                   enteros = tasaAnual.split(",")[0];
                }
                if(tasaAnual.indexOf(".") !== -1){
                   decimales = tasaAnual.split(".")[1];
                   enteros = tasaAnual.split(".")[0];
                }
                
                decimales = decimales.substring(0, 2);
                $('#tasaanual').val(enteros + "." + decimales);
            }

            function pintarDatos(campana, subproductos) {
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
                $('#rutcliente').val('');
                
                //Limpieza de inputs
                $('#valorcuota').val('');
                $('#tasaanual').val('');
                $('#cuotas').val('');
                $('#tasainteres').val('');
                $('#cae').val('');
                $('#costototal').val('');
                $('#vencimiento').val('');
                $('#comision').val('');
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
                            <td style='font-weight: bold;'>Meta</td>
                            <td id='montometa'></td>

                            <td style='font-weight: bold;'>Dirección</td>
                            <td id='direccion'></td>
                        </tr>
                        <tr>
                            <td style='font-weight: bold;'>Monto aprobado</td>
                            <td>
                                <input onkeyup="formatMilesInput(this);" class='form-control form-control-sm' type='text' id='montoaprobado' value=''/>
                            </td>

                            <td style='font-weight: bold;'>Cuotas</td>
                            <td>
                                <input class='form-control form-control-sm' type='text' id='cuotas' value=''/>
                            </td>
                        </tr>
                        <tr>
                            <td style='font-weight: bold;'>Valor cuota</td>
                            <td>
                                <input onkeyup="formatMilesInput(this);" class='form-control form-control-sm' type='text' id='valorcuota' value=''/>
                            </td>

                            <td style='font-weight: bold;'>Tasa interés</td>
                            <td>
                                <input class='form-control form-control-sm' onkeyup="calcTasaAnual();" type='number' step='0.01' id='tasainteres' value=''/>
                            </td>
                            <!--td style='font-weight: bold;'>Tasa anual</td>
                            <td>
                                <input class='form-control form-control-sm' type='number' step='0.01' id='tasaanual' value=''/>
                            </td-->
                        </tr>
                        <tr>
                            <td style='font-weight: bold;'>Tasa anual</td>
                            <td>
                                <input class='form-control form-control-sm' disabled="disabled" type='number' step='0.01' id='tasaanual' value=''/>
                            </td>
                            <!--td style='font-weight: bold;'>Tasa interés</td>
                            <td>
                                <input class='form-control form-control-sm' type='number' step='0.01' id='tasainteres' value=''/>
                            </td-->
                            <td style='font-weight: bold;'>CAE</td>
                            <td>
                                <input class='form-control form-control-sm' type='number' step='0.01' id='cae' value=''/>
                            </td> 
                        </tr>
                        <tr>
                            <td style='font-weight: bold;'>Vencimiento</td>
                            <td>
                                <input class='form-control form-control-sm' type='date' id='vencimiento' value=''/>
                            </td>
                            <td style='font-weight: bold;'>Costo total</td>
                            <td>
                                <input onkeyup="formatMilesInput(this);" class='form-control form-control-sm' type='text' id='costototal' value=''/>
                            </td>

                        </tr>
                        <tr>
                            <td style='font-weight: bold;'>Comisión</td>
                            <td>
                                <input onkeyup="formatMilesInput(this);" class='form-control form-control-sm' type='text' id='comision' value=''/>
                            </td>
                        </tr>
                    </table>
                    <div class='col-sm-2'>
                        <div id='creacion' class="form-group small">
                            <button onclick="insert();" type="button" class="btn btn-primary btn-sm">Insertar</button>
                            <button onclick='limpiar();' type="button" class="btn btn-default btn-sm float-right">Limpiar</button>
                        </div>
                    </div>

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
                                <th>Monto meta</th>
                                <th>Cant. meta</th>
                            </tr>
                        </thead>
                        <tbody id='cuerpo-subproductos'>

                        </tbody>

                    </table>
                </div>
            </div>
            <div class="row">
                <br />
                <h3>Simulaciones ingresadas</h3>
                <div class="col-sm-12" id="listado">
                    <table id="tabla-simulaciones" class="table table-sm small table-borderless table-hover table-striped">
                        <thead>
                            <tr>
                                <th>Fecha</th>
                                <th>Rut cliente</th>
                                <th>Nombres</th>
                                <th>Código producto</th>
                                <th>Producto</th>
                                <th>Monto</th>
                                <th>Cuotas</th>
                                <th>Subproductos</th>
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
