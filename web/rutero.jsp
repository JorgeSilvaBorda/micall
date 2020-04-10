<%@include file="headjava.jsp" %>
<%    session.removeAttribute("nombreArchivo"); //Limpiar el nombre del archivo en caso de que haya sido usado anteriormente
%>
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
            var FILAS_TOTALES = 0;
            $(document).ready(function () {
                OPCIONES_DATATABLES.buttons = [];
                cargaSelectCampana();
                traerRuterosEmpresa();
                $('#select-campana').val('0');
                $('#upload-form').submit(function (event) {
                    var arch = $('#archivo');
                    var nomarchivo = arch[0].files[0].name;

                    if (!(nomarchivo.indexOf(" ") === -1)) {//Si hay espacios en el nombre, rechazar.
                        alert("El nombre del archivo cargado no puede contener espacios.");
                        $('#archivo').val('');
                        return false;
                    }

                    if (nomarchivo.length < 5) {//Nombre de archivo no puede ser menor a 5, Ej: '1.csv'
                        alert("Nombre de archivo incorrecto.");
                        $('#archivo').val('');
                        return false;
                    }

                    if ((nomarchivo.substring(nomarchivo.length - 4, nomarchivo.length) !== '.csv')) { //Nombre de archivo debe finalizar como '.csv'
                        alert("El archivo debe contener extensión '.csv'");
                        $('#archivo').val('');
                        return false;
                    }

                    $('#titulo-modal').html("Analizando archivo...");
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
                            FILAS_TOTALES = 0;
                            //ocultarModalCarga();
                            console.log(response);
                            var obj = JSON.parse(response);
                            if (obj.estado === 'ok') {
                                FILAS_TOTALES = obj.filasTotales;
                                //armarRespuesta(obj);
                                if (parseInt(obj.filasMalas) > 0) {
                                    if (confirm("El rutero ingresado contiene " + obj.filasMalas + " registros malos, que no serán ingresados. Está seguro que desea continuar?")) {
                                        //RUTERO CON MAS DE 0 FILAS MALAS ----------------------
                                        $('#titulo-modal').html("Ingresando rutero. Por favor espere...");

                                        var datos = {
                                            idrutero: obj.idrutero,
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
                                                    traerRuterosEmpresa();
                                                    alert("Rutero ingresado correctamente, ver cantidad de errores abajo.");
                                                } else if (obj.estado === 'error') {
                                                    ocultarModalCarga();
                                                    alert(obj.mensaje);
                                                    traerRuterosEmpresa();
                                                }
                                                //ocultarModalCarga();
                                            },
                                            error: function (a, b, c) {
                                                console.log(a);
                                                console.log(b);
                                                console.log(c);
                                                ocultarModalCarga();
                                            }
                                        });
                                        //ocultarModalCarga();
                                        limpiar();
                                    } else {
                                        //NO SE INGRESA RUTERO CON MAS DE 0 FILAS MALAS --------------
                                        //Eliminar archivo analizado----------------------------------
                                        deleteArchivoProceso(nomarchivo);
                                        ocultarModalCarga();
                                        traerRuterosEmpresa();
                                        alert("Abajo se muestra el detalle de la cantidad de registros procesados. No se han ingresado.");
                                    }
                                } else {
                                    //RUTERO CON 0 FILAS MALAS-------------------
                                    $('#titulo-modal').html("Ingresando rutero. Por favor espere...");

                                    var datos = {
                                        idrutero: obj.idrutero,
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
                                            var obj = JSON.parse(response);
                                            if (obj.estado === 'error') {
                                                alert(obj.mensaje);
                                                ocultarModalCarga();
                                                traerRuterosEmpresa();
                                                return false;
                                            } else {
                                                console.log(obj);
                                                alert("Rutero ingresado correctamente.");
                                                ocultarModalCarga();
                                                limpiar();
                                                return false;
                                            }
                                            ocultarModalCarga();
                                            limpiar();
                                            console.log(response);
                                            alert("Rutero ingresado correctamente");
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
                            } else {
                                console.log(obj);
                                alert(obj.mensaje);
                                ocultarModalCarga();
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

            function getIdNewRutero() {
                var datos = {
                    tipo: 'get-new-idrutero'
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

                        }
                    },
                    error: function (a, b, c) {
                        console.log(a);
                        console.log(b);
                        console.log(c);
                    }
                });
            }

            function traerLog(nomarchivo) {
                jQuery.download = function (url, key, data) {
                    // Build a form
                    var form = $('<form></form>').attr('action', 'DownloadServlet').attr('method', 'post');
                    // Add the one key/value
                    form.append($("<input></input>").attr('type', 'hidden').attr('name', 'nomarchivo').attr('value', nomarchivo));
                    //send request
                    form.appendTo('body').submit().remove();
                };

                $.download();
            }

            function deleteArchivoProceso(nombre) {
                var dat = {
                    tipo: 'del-archivo-proceso',
                    nomarchivo: nombre
                };
                $.ajax({
                    type: 'post',
                    url: 'RuteroController',
                    data: {
                        datos: JSON.stringify(dat)
                    },
                    success: function (resp) {
                        var obj = JSON.parse(resp);
                        if (obj.estado === 'ok') {
                            console.log(obj.mensaje);
                        }
                    },
                    error: function (a, b, c) {
                        console.log(a);
                        console.log(b);
                        console.log(c);
                    }
                });
            }


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
                //Insertar icono de carga para la espera
                $('#contenido-ruteros').html("<div class='spinner-border' style='width: 2rem; height: 2rem; text-align: center;' role='status'><span class='sr-only'>Buscando Ruteros...</span></div><label>Buscando Ruteros...</label>");
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
                            OPCIONES_DATATABLES.order = [[0, "desc"]];
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
                FILAS_TOTALES = 0;
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
                        <h4 class="modal-title" id="titulo-modal">Analizando archivo...</h4>
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
                        <div class="form-group-small">
                            <div id="tabla-rutero" class="col-sm-12">

                            </div>
                        </div>
                    </form>
                </div>
                <div class="col-sm-8" id="contenido-ruteros">

                </div>
            </div>
        </div>
    </body>
</html>
