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
            var CANTIDAD = 0;
            var RUTERO = null;
            var NOMARCHIVO = "";
            var CONTENIDO_EN_PROCESO = "";
            document.getElementById('archivo').onchange = function () {
                NOMARCHIVO = "";
                CANTIDAD = 0;
                ERRORES = 0;
                var contenido;
                if (TIPOOP === 'ingreso') {
                    var cont = 1;
                    var file = this.files[0];

                    NOMARCHIVO = file;
                    var reader = new FileReader();
                    reader.onload = function () {
                        ERRORES = 0;
                        MENSAJES = [];
                        var lineas = this.result.split("\n");
                        contenido = this.result;
                        var rutero = {
                            nomarchivo: NOMARCHIVO.name,
                            idcampana: $('#select-campana').val(),
                            registros: 0,
                            filas: []
                        };
                        RUTERO = rutero;
                        var da = {
                            tipo: 'valida-ins-rutero',
                            contenido: contenido
                        };

                        $.ajax({
                            url: 'RuteroController',
                            type: 'post',
                            data: {
                                datos: JSON.stringify(da)
                            },
                            success: function (resp) {
                                var obj = JSON.parse(resp);
                                if (obj.estado === "ok") {
                                    if(parseInt(obj.filasBuenas) > 0){
                                        $('#btnInsert').removeAttr("disabled");
                                        CONTENIDO_EN_PROCESO = contenido;
                                    }else{
                                        $('#btnInsert').attr("disabled", "disabled");
                                        CONTENIDO_EN_PROCESO = "";
                                    }
                                    armarTablaResultados(obj);
                                } else {
                                    console.log("Problemas en rutero de inserción");
                                }
                            },
                            error: function (a, b, c) {
                                console.log("Error:");
                                console.log(a);
                                console.log(b);
                                console.log(c);
                            }
                        });
                    };
                    reader.readAsText(file, 'UTF-8');
                } else if (TIPOOP === 'eliminacion') {
                    var cont = 1;
                    var file = this.files[0];

                    NOMARCHIVO = file;
                    var reader = new FileReader();
                    reader.onload = function () {
                        ERRORES = 0;
                        MENSAJES = [];
                        var lineas = this.result.split("\n");
                        contenido = this.result;
                        var rutero = {
                            nomarchivo: NOMARCHIVO.name,
                            idcampana: $('#select-campana').val(),
                            registros: 0,
                            filas: []
                        };
                        RUTERO = rutero;
                        var da = {
                            tipo: 'valida-del-rutero',
                            contenido: contenido
                        };

                        $.ajax({
                            url: 'RuteroController',
                            type: 'post',
                            data: {
                                datos: JSON.stringify(da)
                            },
                            success: function (resp) {
                                var obj = JSON.parse(resp);
                                if (obj.estado === "ok") {
                                    if(parseInt(obj.filasBuenas) > 0){
                                        $('#btnInsert').removeAttr("disabled");
                                        CONTENIDO_EN_PROCESO = contenido;
                                    }else{
                                        $('#btnInsert').attr("disabled", "disabled");
                                        CONTENIDO_EN_PROCESO = "";
                                    }
                                    armarTablaResultados(obj);
                                } else {
                                    console.log("Problemas en rutero eliminación");
                                }
                            },
                            error: function (a, b, c) {
                                console.log("Error:");
                                console.log(a);
                                console.log(b);
                                console.log(c);
                            }
                        });
                    };
                    reader.readAsText(file, 'UTF-8');
                } else if (TIPOOP === null) {
                    alert("Debe seleccionar el tipo de operación para la carga del rutero.");
                }
            };

            function armarTablaResultados(resultados) {
                ERRORES = parseInt(resultados.filasMalas);
                CANTIDAD = parseInt(resultados.filasBuenas);
                var tab = "<table id='tab-rutero' class='table table-sm small table-striped table-condensed table-hover'>";
                tab += "<tbody>";

                tab += "<tr>";
                tab += "<td style='font-weight: bold; text-transform: uppercase;'>Registros Procesados</td>";
                tab += "<td>" + resultados.filasProcesadas + "</td>";
                tab += "</tr>";

                tab += "<tr>";
                tab += "<td style='font-weight: bold; text-transform: uppercase;'>Registros correctos</td>";
                tab += "<td>" + resultados.filasBuenas + "</td>";
                tab += "</tr>";

                tab += "<tr>";
                tab += "<td style='font-weight: bold; text-transform: uppercase;'>Registros con errores</td>";
                tab += "<td>" + resultados.filasMalas + "</td>";
                tab += "</tr>";

                tab += "</tbody></table>";
                $('#tabla-rutero').html(tab);
            }

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
                                    nomarchivo: NOMARCHIVO.name,
                                    idusuario: parseInt(idusuario),
                                    idcampana: $('#select-campana').val(),
                                    contenido: CONTENIDO_EN_PROCESO
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
                                idcampana: $('#select-campana').val(),
                                contenido: CONTENIDO_EN_PROCESO
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

                if (CANTIDAD === 0) {
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
                CANTIDAD = 0;
                RUTERO = null;
                NOMARCHIVO = "";
                CONTENIDO_EN_PROCESO = "";
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
                <div id="tabla-rutero" class="col-sm-4">

                </div>
            </div>
        </div>
    </body>
</html>
