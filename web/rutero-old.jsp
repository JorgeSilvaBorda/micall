<%@include file="headjava.jsp" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="initial-scale=1">
    </head>
    <body>
        <script type="text/javascript">
            var TIPOOP = null;
            $(document).ready(function () {
               OPCIONES_DATATABLES.buttons = [];
                cargaSelectCampana();
                traerRuterosEmpresa();
                $('#select-campana').val('0');
            });
            var MENSAJES = [];
            var ERRORES = 0;
            var RUTERO = null;
            var NOMARCHIVO = "";
            document.getElementById('archivo').onchange = function () {
                if (TIPOOP === 'ingreso') {
                    var cont = 1;
                    var file = this.files[0];

                    NOMARCHIVO = file;
                    var reader = new FileReader();
                    reader.onload = function () { //Acá convertir a tabla
                        ERRORES = 0;
                        MENSAJES = [];
                        var lineas = this.result.split("\n");
                        var rutero = {
                            nomarchivo: NOMARCHIVO.name,
                            idcampana: $('#select-campana').val(),
                            registros: 0,
                            filas: []
                        };
                        for (var i = 1; i < lineas.length; i++) { //Comienza en 1. La primera línea es cabecera
                            if (lineas[i].length > 10) {
                                var linea = lineas[i].split(";");
                                var rutcliente = linea[0];
                                var dvcliente = linea[1];

                                var nombres = linea[2];
                                var apellidos = linea[3];
                                var genero = linea[4];
                                var fechaNacInt = linea[5].toString();
                                var fechanac = fechaNacInt;
                                var direccion = linea[6];
                                var comuna = linea[7];
                                var region = linea[8];
                                var codigopostal = linea[9];
                                var email = linea[10];
                                var montoaprobado = linea[11];
                                var fono1 = parseInt(linea[12]);
                                var fono2 = parseInt(linea[13]);
                                var fono3 = parseInt(linea[14]);

                                var filaRutero = {
                                    rutcliente: parseInt(rutcliente),
                                    dvcliente: dvcliente,
                                    nombres: nombres,
                                    apellidos: apellidos,
                                    genero: genero,
                                    fechanac: fechanac,
                                    direccion: direccion.replaceAll("'", "''"),
                                    comuna: comuna,
                                    region: region,
                                    codigopostal: parseInt(codigopostal),
                                    email: email,
                                    montoaprobado: montoaprobado,
                                    fono1: fono1,
                                    fono2: fono2,
                                    fono3: fono3,
                                    posicion: i
                                };
                                if (validarFila(filaRutero)) {
                                    rutero.filas.push(filaRutero);
                                    rutero.registros++;
                                } else {
                                    ERRORES++;
                                }
                            }
                            cont++;
                        }
                        RUTERO = rutero;
                        armarTablaRutero(rutero);
                    };
                    reader.readAsText(file, 'UTF-8');
                } else if (TIPOOP === 'eliminacion') {
                    var cont = 1;
                    var file = this.files[0];

                    NOMARCHIVO = file;
                    var reader = new FileReader();
                    reader.onload = function () { //Acá convertir a tabla
                        ERRORES = 0;
                        MENSAJES = [];
                        var lineas = this.result.split("\n");
                        var rutero = {
                            nomarchivo: NOMARCHIVO.name,
                            idcampana: $('#select-campana').val(),
                            registros: 0,
                            filas: []
                        };
                        for (var i = 1; i < lineas.length; i++) { //Comienza en 1. La primera línea es cabecera
                            if (lineas[i].length > 10) {
                                var linea = lineas[i].split(";");
                                var rutcliente = linea[0];
                                var dvcliente = linea[1];
                                var filaRutero = {
                                    rutcliente: parseInt(rutcliente),
                                    dvcliente: dvcliente,
                                    posicion: i
                                };
                                if (validarFilaEliminacion(filaRutero)) {
                                    rutero.filas.push(filaRutero);
                                    rutero.registros++;
                                } else {
                                    ERRORES++;
                                }
                            }
                            cont++;
                        }
                        RUTERO = rutero;
                        armarTablaRuteroEliminacion(rutero);
                    };
                    reader.readAsText(file, 'UTF-8');
                }else if(TIPOOP === null){
                    alert("Debe seleccionar el tipo de operación para la carga del rutero.");
                }
            };

            function traerRuterosEmpresa() {
                var datos = {
                    tipo: 'traer-ruteros-empresa',
                    rutempresa: '<% out.print(session.getAttribute("rutempresa")); %>'
                };

                $.ajax({
                    url: 'RuteroController',
                    type: 'post',
                    data: {
                        datos: JSON.stringify(datos)
                    },
                    success: function (resp) {
                        var obj = JSON.parse(resp);
                        if (obj.estado === 'ok') {
                            $('.dataTable').DataTable().destroy();
                            $('#contenido-ruteros').html(obj.tabla);
                            $('#tabla-ruteros-empresa').DataTable(OPCIONES_DATATABLES);
                        }
                    }
                });
            }

            function validarFilaEliminacion(filarutero) {
                var mensaje = [];
                var SALIDA = true;
                var rutfullcliente = filarutero.rutcliente.toString() + filarutero.dvcliente.toString();
                if (filarutero.rutcliente.length < 7 || filarutero.rutcliente.length > 8) {
                    mensaje.push("[Fila " + filarutero.posicion + "]El largo del rut no puede ser menor a 7 ni mayor que 8 dígitos.");
                    SALIDA = false;
                }
                if (isNaN(filarutero.rutcliente)) {
                    mensaje.push("[Fila " + filarutero.posicion + "]El rut debe ser numérico.");
                    SALIDA = false;
                }
                if (!$.validateRut(rutfullcliente)) {
                    mensaje.push("[Fila " + filarutero.posicion + "]El dígito verificador no corresponde al rut.");
                    SALIDA = false;
                }
                if (!SALIDA) {
                    MENSAJES.push(mensaje);
                }

                return SALIDA;
            }

            function validarFila(filarutero) {
                var mensaje = [];
                var SALIDA = true;
                var rutfullcliente = filarutero.rutcliente.toString() + filarutero.dvcliente.toString();
                if (filarutero.rutcliente.length < 7 || filarutero.rutcliente.length > 8) {
                    mensaje.push("[Fila " + filarutero.posicion + "]El largo del rut no puede ser menor a 7 ni mayor que 8 dígitos.");
                    SALIDA = false;
                }
                if (isNaN(filarutero.rutcliente)) {
                    mensaje.push("[Fila " + filarutero.posicion + "]El rut debe ser numérico.");
                    SALIDA = false;
                }
                if (!$.validateRut(rutfullcliente)) {
                    mensaje.push("[Fila " + filarutero.posicion + "]El dígito verificador no corresponde al rut.");
                    SALIDA = false;
                }
                if (filarutero.nombres.length < 2) {
                    mensaje.push("[Fila " + filarutero.posicion + "]El campo de nombres debe ser de largo al menos 2.");
                    SALIDA = false;
                }
                if (filarutero.apellidos.length < 2) {
                    mensaje.push("[Fila " + filarutero.posicion + "]El campo de apellidos debe ser de largo al menos 2.");
                    SALIDA = false;
                }
                if (isNaN(filarutero.fono1.toString())) {
                    mensaje.push("[Fila " + filarutero.posicion + "]El campo Fono1 debe ser únicamente numérico.");
                    SALIDA = false;
                }
                if (isNaN(filarutero.fono2.toString())) {
                    mensaje.push("[Fila " + filarutero.posicion + "]El campo Fono2 debe ser únicamente numérico.");
                    SALIDA = false;
                }
                if (isNaN(filarutero.fono3.toString())) {
                    mensaje.push("[Fila " + filarutero.posicion + "]El campo Fono3 debe ser únicamente numérico.");
                    SALIDA = false;
                }
                if (filarutero.fono1.toString().length !== 9) {
                    mensaje.push("[Fila " + filarutero.posicion + "]El largo del Fono1 debe ser de 9 digitos.");
                    SALIDA = false;
                }
                if (filarutero.fono2.toString().length !== 9) {
                    mensaje.push("[Fila " + filarutero.posicion + "]El largo del Fono2 debe ser de 9 digitos.");
                    SALIDA = false;
                }
                if (filarutero.fono3.toString().length !== 9) {
                    mensaje.push("[Fila " + filarutero.posicion + "]El largo del Fono3 debe ser de 9 digitos.");
                    SALIDA = false;
                }
                if (!SALIDA) {
                    MENSAJES.push(mensaje);
                }

                return SALIDA;
            }

            function armarTablaRutero(rutero) {
                var tab = "<table id='tab-rutero' class='table table-sm small table-striped table-condensed table-hover'><thead>";
                tab += "<tr>";
                tab += "<th>RUTCLIENTE</th>";
                tab += "<th>DVCLIENTE</th>";
                tab += "<th>NOMBRES</th>";
                tab += "<th>APELLIDOS</th>";
                tab += "<th>GENERO</th>";
                tab += "<th>FECHANAC</th>";
                tab += "<th>DIRECCION</th>";
                tab += "<th>COMUNA</th>";
                tab += "<th>REGION</th>";
                tab += "<th>COD. POSTAL</th>";
                tab += "<th>EMAIL</th>";
                tab += "<th>MONTOAPROBADO</th>";
                tab += "<th>FONO1</th>";
                tab += "<th>FONO2</th>";
                tab += "<th>FONO3</th>";
                tab += "</tr>";
                tab += "</thead>";
                tab += "<tbody>";
                $(rutero.filas).each(function (i) {
                    tab += "<tr>";
                    tab += "<td>" + $(this)[0].rutcliente + "</td>";
                    tab += "<td>" + $(this)[0].dvcliente + "</td>";
                    tab += "<td>" + $(this)[0].nombres + "</td>";
                    tab += "<td>" + $(this)[0].apellidos + "</td>";
                    tab += "<td>" + $(this)[0].genero + "</td>";
                    tab += "<td>" + fechaIntToString($(this)[0].fechanac) + "</td>";
                    tab += "<td>" + $(this)[0].direccion + "</td>";
                    tab += "<td>" + $(this)[0].comuna + "</td>";
                    tab += "<td>" + $(this)[0].region + "</td>";
                    tab += "<td>" + $(this)[0].codigopostal + "</td>";
                    tab += "<td>" + $(this)[0].email + "</td>";
                    tab += "<td>$ " + formatMiles($(this)[0].montoaprobado) + "</td>";
                    tab += "<td>" + $(this)[0].fono1 + "</td>";
                    tab += "<td>" + $(this)[0].fono2 + "</td>";
                    tab += "<td>" + $(this)[0].fono3 + "</td>";
                    tab += "</tr>";
                });
                tab += "</tbody></table>";

                var tabDetalle = "<table style='border: none; border-collapse: collapse;'><tbody><tr>";
                tabDetalle += "<td>Registros procesados</td>";
                tabDetalle += "<td>" + rutero.registros + "</td>";
                tabDetalle += "</tr>";
                if (ERRORES > 0) {
                    tabDetalle += "<tr>";
                    tabDetalle += "<td>Registros con problemas</td>";
                    tabDetalle += "<td>" + ERRORES + " <button class='btn btn-sm btn-warning' type='button' onclick='mostrarErrores();'>Detalle</button></td>";
                    tabDetalle += "</tr>";
                }
                tabDetalle += "</tbody></table>";
                $('.dataTable').DataTable().destroy();
                $('#tabla-rutero').html(tabDetalle + "<br />" + tab);
                $('#tab-rutero').DataTable(OPCIONES_DATATABLES);
                $('#tabla-ruteros-empresa').DataTable(OPCIONES_DATATABLES);
            }
            
            function armarTablaRuteroEliminacion(rutero) {
                var tab = "<table style='width: 200px;' id='tab-rutero' class='table table-sm small table-striped table-condensed table-hover'><thead>";
                tab += "<tr>";
                tab += "<th style='width: 50px;' >RUTCLIENTE</th>";
                tab += "<th style='width: 20px;' >DVCLIENTE</th>";
                tab += "</tr>";
                tab += "</thead>";
                tab += "<tbody>";
                $(rutero.filas).each(function (i) {
                    tab += "<tr>";
                    tab += "<td>" + $(this)[0].rutcliente + "</td>";
                    tab += "<td>" + $(this)[0].dvcliente + "</td>";
                    tab += "</tr>";
                });
                tab += "</tbody></table>";

                var tabDetalle = "<table style='border: none; border-collapse: collapse;'><tbody><tr>";
                tabDetalle += "<td>Registros procesados</td>";
                tabDetalle += "<td>" + rutero.registros + "</td>";
                tabDetalle += "</tr>";
                if (ERRORES > 0) {
                    tabDetalle += "<tr>";
                    tabDetalle += "<td>Registros con problemas</td>";
                    tabDetalle += "<td>" + ERRORES + " <button class='btn btn-sm btn-warning' type='button' onclick='mostrarErrores();'>Detalle</button></td>";
                    tabDetalle += "</tr>";
                }
                tabDetalle += "</tbody></table>";
                $('.dataTable').DataTable().destroy();
                $('#tabla-rutero').html(tabDetalle + "<br />" + tab);
                $('#tab-rutero').DataTable(OPCIONES_DATATABLES);
                $('#tabla-ruteros-empresa').DataTable(OPCIONES_DATATABLES);
            }

            function mostrarErrores() {
                var texto = "<table style='border: none; border-collapse: collapse;'><tbody>";
                for (var i = 0; i < MENSAJES.length; i++) {
                    for (var j = 0; j < MENSAJES[i].length; j++) {
                        console.log(MENSAJES[i][j]);
                        texto += "<tr><td>" + MENSAJES[i][j] + "</td></tr>";
                    }
                }
                texto += "</tbody></table>";
                $('#cuerpo-modal-errores').html(texto);
                $('#modal-errores').modal();
            }

            function insert() {
                var modo = "";
                if ($('#select-tipo').val() === '1') {
                    modo = 'ins-rutero';
                } else if ($('#select-tipo').val() === '2') {
                    modo = 'del-rutero';
                }
                if (validarInsert()) {
                    var idusuario = '<% out.print(session.getAttribute("idusuario")); %>';
                    if (ERRORES > 0) {
                        if (confirm('El rutero cargado presenta errores. Está seguro de que desea cargar únicamente los registros buenos?')) {
                            var detalle = {
                                url: 'RuteroController',
                                datos: {
                                    tipo: modo,
                                    idusuario: parseInt(idusuario),
                                    rutero: RUTERO
                                }
                            };
                            insertar(detalle, function (obj) {
                                traerRuterosEmpresa();
                                limpiar();
                            });

                        }
                    } else {
                        var detalle = {
                            url: 'RuteroController',
                            datos: {
                                tipo: modo,
                                idusuario: parseInt(idusuario),
                                rutero: RUTERO
                            }
                        };
                        insertar(detalle, function (obj) {
                            traerRuterosEmpresa();
                            limpiar();
                        });
                    }
                }
            }

            function validarInsert() {
                if ($('#select-tipo').val() === '0') {
                    alert('Debe seleccionar una operación de carga de rutero. Ingreso o eliminación.');
                    return false;
                }
                if ($('#select-campana').val() === '0' || $('#select-campana').val() === 0) {
                    alert('Debe seleccionar una campaña para cargar el rutero.');
                    return false;
                }

                var cantidad = 0;
                $('#tab-rutero tbody tr').each(function () {
                    cantidad++;
                });
                if (cantidad === 0) {
                    alert('No existen registros para insertar');
                    return false;
                }
                return true;
            }

            function cargaSelectCampana() {
                var idempresa = '<% out.print(session.getAttribute("idempresa"));%>';
                var detalle = {
                    url: 'CampanaController',
                    objetivo: 'select-campana',
                    datos: {
                        tipo: 'select-campanas',
                        idempresa: idempresa
                    }
                };
                cargarSelectParams(detalle);
            }

            function limpiar() {
                $('#tabla-rutero').html('');
                $('#select-campana').val('0');
                $('#archivo').val('');
                $('#select-tipo').val('0');
                MENSAJES = [];
                ERRORES = 0;
                RUTERO = null;
                NOMARCHIVO = "";
            }

            function habilitarCarga() {
                if (parseInt($('#select-tipo').val()) === 1) {
                    TIPOOP = 'ingreso';
                    $('#archivo').removeAttr("disabled");
                } else if (parseInt($('#select-tipo').val()) === 2) {
                    TIPOOP = 'eliminacion';
                    $('#archivo').removeAttr("disabled");
                } else if (parseInt($('#select-tipo').val()) === 0) {
                    TIPOOP = null;
                    $('#archivo').attr("disabled", "disabled");
                }
            }
        </script>
        <!-- The Modal -->
        <div class="modal" id="modal-errores">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">

                    <!-- Modal Header -->
                    <div class="modal-header">
                        <h4 class="modal-title">Informe de errores</h4>
                        <button type="button" class="close" data-dismiss="modal">&times;</button>
                    </div>

                    <!-- Modal body -->
                    <div id="cuerpo-modal-errores" class="modal-body">

                    </div>

                    <!-- Modal footer -->
                    <div class="modal-footer">
                        <button type="button" class="btn btn-danger" data-dismiss="modal">Close</button>
                    </div>

                </div>
            </div>
        </div>

        <div class="container-fluid">
            <br />
            <br />
            <br />
            <div class="row">
                <div class="col-sm-12">
                    <h2>Rutero</h2>
                </div>
            </div>
            <div class="row">
                <div class="col-sm-4">
                    <form>
                        <div class="form-group small">
                            <label for="select-campana">Campaña</label>
                            <select  id="select-campana" class="form-control form-control-sm" >
                            </select>
                        </div>
                        <div class="form-group small">
                            <label for="select-tipo">Operación</label>
                            <select onchange="habilitarCarga();" id="select-tipo" class="form-control form-control-sm" >
                                <option value='0'>Seleccione</option>
                                <option value='1'>Ingreso</option>
                                <option value='2'>Eliminación</option>
                            </select>
                        </div>
                        <div class="form-group-small">
                            <label for="archivo">Archivo rutero</label>
                            <input type="file" disabled="disabled" class="form-control form-control-sm" id="archivo" />
                        </div>

                        <br />
                        <div id='creacion' class="form-group small">
                            <button id="btnInsert" onclick="insert();" type="button" class="btn btn-primary btn-sm">Ingresar</button>
                            <button onclick='limpiar();' type="button" class="btn btn-default btn-sm float-right">Limpiar</button>
                        </div>
                    </form>
                </div>
                <div class="col-sm-8" id="contenido-ruteros">

                </div>
            </div>
            <div class="row">
                <div id="tabla-rutero" class="col-sm-12">

                </div>
            </div>
        </div>
    </body>
</html>
