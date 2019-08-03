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
                $('#rutcliente').rut(
                        {
                            formatOn: 'keyup',
                            validateOn: 'blur'
                        }).on('rutInvalido', function () {
                    mostrarAlert('alert-danger', "El rut ingresado no es válido");
                }).on('rutValido', function () {
                    ocultarAlert();
                });
            });

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
                            pintarDatos(obj.campana, obj.cuerpotabla);
                        } else {
                            alert(obj.mensaje);
                        }
                    }
                });
            }

            function pintarDatos(campana, subproductos) {
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
                            <div class="row">
                                <div class="col-sm-2">
                                    <div id="alerta" class="alert oculto">

                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="form-group small">
                            <button type='button' onclick='buscar();' class='btn btn-primary btn-sm' id='btnBuscar'>Buscar</button>
                        </div>
                    </form>

                </div>

                <div class='col-sm-10'>
                    <table id='tab-detalles' class='table-sm small' style='border: none; border-collapse: collapse;'>
                        <tr>
                            <td style='font-weight: bold;'>Cod. Campaña</td>
                            <td id='codcampana'>CCCP</td>

                            <td style='font-weight: bold;'>Cod. producto</td>
                            <td id='codproducto'>Unión Soviética</td>
                            <td><br /><br /> <span style='font-weight: bold;'>Subproductos</span>
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
                            <td style='font-weight: bold;'>Tasa interés</td>
                            <td>
                                <input class='form-control form-control-sm' type='number' step='0.01' id='tasainteres' value=''/>
                            </td>

                            <td style='font-weight: bold;'>Tasa anual</td>
                            <td>
                                <input class='form-control form-control-sm' type='number' step='0.01' id='tasaanual' value=''/>
                            </td>
                        </tr>
                        <tr>
                            <td style='font-weight: bold;'>CAE</td>
                            <td>
                                <input class='form-control form-control-sm' type='number' step='0.01' id='cae' value=''/>
                            </td>

                            <td style='font-weight: bold;'>Vencimiento</td>
                            <td>
                                <input class='form-control form-control-sm' type='date' id='vencimiento' value=''/>
                            </td>
                        </tr>
                        <tr>
                            <td style='font-weight: bold;'>Costo total</td>
                            <td>
                                <input onkeyup="formatMilesInput(this);" class='form-control form-control-sm' type='text' id='costototal' value=''/>
                            </td>

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
            </div>
            <div class="row">
                <br />
                <h3>Simulaciones ingresadas</h3>
                <div class="col-sm-12">
                    <table id="tabla-simulaciones" class="table table-sm small table-borderless table-hover table-striped">
                        <thead>
                            <tr>
                                <th>Rut</th>
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
