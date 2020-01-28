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
                $('#upload-form').submit(function (event) {
                    var arch = $('#archivo');
                    var nomarchivo = arch[0].files[0].name;
                    
                    if(!(nomarchivo.indexOf(" ") === -1)){//Si hay espacios en el nombre, rechazar.
                        alert("El nombre del archivo cargado no puede contener espacios.");
                        $('#archivo').val('');
                        return false;
                    }
                    
                    if(nomarchivo.length < 5){//Nombre de archivo no puede ser menor a 5, Ej: '1.csv'
                        alert("Nombre de archivo incorrecto.");
                        $('#archivo').val('');
                        return false;
                    }
                    
                    if((nomarchivo.substring(nomarchivo.length - 4, nomarchivo.length) !== '.csv')){ //Nombre de archivo debe finalizar como '.csv'
                        alert("El archivo debe contener extensión '.csv'");
                        $('#archivo').val('');
                        return false;
                    }
                    
                    mostrarModalCarga();
                    event.preventDefault();
                    var form = $("#upload-form")[0];
                    var data = new FormData(form);

                    $.ajax({
                        url: "UploadServlet",
                        type: "post",
                        data: data,
                        contentType: false,
                        encType: "multipart/form-data",
                        cache: false,
                        processData: false,
                        success: function (response) {
                            ocultarModalCarga();
                            console.log(response);
                            var obj = JSON.parse(response);
                            if (obj.estado === 'ok') {
                                //armarRespuesta(obj);
                                if (parseInt(obj.filasMalas) > 0) {
                                    if (confirm("El rutero ingresado contiene " + obj.filasMalas + " registros malos, que no serán ingresados. Está seguro que desea continuar?")) {
                                        //RUTERO CON MAS DE 0 FILAS MALAS ----------------------
                                        var datos = {
                                            idcampana: $('#select-campana').val(),
                                            tipooperacion: $('#select-tipo').val(),
                                            tipo: 'ins-rutero'
                                        };
                                        $.ajax({
                                            url: "RuteroController",
                                            type: "post",
                                            data: {
                                                datos: JSON.stringify(datos)
                                            },
                                            success: function (response) {
                                                console.log(response);
                                                var obj = JSON.parse(response);
                                                if (obj.estado === 'ok') {
                                                    ocultarModalCarga();
                                                    alert("Rutero ingresado correctamente, ver cantidad de errores abajo.");
                                                    traerRuterosEmpresa();
                                                }
                                                ocultarModalCarga();
                                            },
                                            error: function (a, b, c) {
                                                console.log(a);
                                                console.log(b);
                                                console.log(c);
                                                ocultarModalCarga();
                                            }
                                        });
                                        ocultarModalCarga();
                                        limpiar();
                                    } else {
                                        //NO SE INGRESA RUTERO CON MAS DE 0 FILAS MALAS --------------
                                        ocultarModalCarga();
                                        
                                        alert("Abajo se muestra el detalle de la cantidad de registros procesados. No se han ingresado.");
                                    }
                                } else {
                                    //RUTERO CON 0 FILAS MALAS-------------------
                                    var datos = {
                                        idcampana: $('#select-campana').val(),
                                        tipooperacion: $('#select-tipo').val(),
                                        tipo: 'ins-rutero'
                                    };
                                    $.ajax({
                                        url: "RuteroController",
                                        type: "post",
                                        data: {
                                            datos: JSON.stringify(datos)
                                        },
                                        success: function (response) {
                                            ocultarModalCarga();
                                            limpiar();
                                            console.log(response);
                                            alert("Rutero ingresado correctamente");
                                            traerRuterosEmpresa();

                                        },
                                        error: function (a, b, c) {
                                            ocultarModalCarga();
                                            console.log(a);
                                            console.log(b);
                                            console.log(c);
                                        }
                                    });
                                }
                                armarRespuesta(obj);
                                limpiar();
                            }
                        },

                        error: function (a, b, c) {
                            console.log(a);
                            console.log(b);
                            console.log(c);
                            ocultarModalCarga();
                        }

                    });
                    //ocultarModalCarga();
                });
                //ocultarModalCarga();
            });

            function ocultarModalCarga() {
                $('#modal-carga').modal('hide');
                $('body').removeClass('modal-open');
                $('.modal-backdrop').remove();
            }

            function mostrarModalCarga() {
                $('#modal-carga').modal('show');
            }

            function armarRespuesta(obj) {
                var tab = "<table id='tab-rutero' class='table table-sm small table-striped table-condensed table-hover'>";
                tab += "<tbody>";
                tab += "<tr>";
                tab += "<td style='font-weight: bold;'>Registros Procesados</td>";
                tab += "<td>" + formatMiles(obj.filasProcesadas) + "</td>";
                tab += "</tr>";

                tab += "<tr>";
                tab += "<td style='font-weight: bold;'>Registros Buenos</td>";
                tab += "<td>" + formatMiles(obj.filasBuenas) + "</td>";
                tab += "</tr>";

                tab += "<tr>";
                tab += "<td style='font-weight: bold;'>Registros Malos</td>";
                tab += "<td>" + formatMiles(obj.filasMalas) + "</td>";
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
                        $('#modal-carga').modal({
                            show: false
                        });
                    }
                });
                $('#modal-carga').modal({
                    show: false
                });
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
                //$('#tabla-rutero').html('');
                $('#select-campana').val('0');
                $('#archivo').val('');
                $('#select-tipo').val('0');
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
        <div class="modal" id="modal-carga">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">

                    <!-- Modal Header -->
                    <div class="modal-header">
                        <h4 class="modal-title">Analizando archivo...</h4>
                        <!-- button type="button" class="close" data-dismiss="modal">&times;</button-->
                    </div>

                    <!-- Modal body -->
                    <div id="cuerpo-modal-carga" class="modal-body">
                        <div class="spinner-border" style="width: 3rem; height: 3rem;" role="status">
                            <span class="sr-only">Leyendo...</span>
                        </div>
                    </div>

                    <!-- Modal footer -->
                    <!--div class="modal-footer">
                        <button type="button" class="btn btn-danger" data-dismiss="modal">Close</button>
                    </div-->
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
                    <form id="upload-form" action="UploadServlet" enctype="multipart/form-data" method="post">
                        <input type="hidden" name="operacion" id="operacion" value="procesar-archivo" />
                        <div class="form-group small">
                            <label for="select-campana">Campaña</label>
                            <select  id="select-campana" name="select-campana" class="form-control form-control-sm" >
                            </select>
                        </div>
                        <div class="form-group small">
                            <label for="select-tipo">Operación</label>
                            <select onchange="habilitarCarga();" id="select-tipo" name="select-tipo" class="form-control form-control-sm" >
                                <option value='0'>Seleccione</option>
                                <option value='1'>Ingreso</option>
                                <option value='2'>Eliminación</option>
                            </select>
                        </div>
                        <div class="form-group-small">
                            <label for="archivo">Archivo rutero</label>
                            <input type="file" disabled="disabled" class="form-control form-control-sm" id="archivo" name="archivo" />
                        </div>

                        <br />
                        <div id='creacion' class="form-group small">
                            <input id="btnInsert" type="submit" class="btn btn-primary btn-sm" />
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
