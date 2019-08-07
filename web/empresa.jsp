<%@include file="headjava.jsp" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    </head>
    <body>
        <script type="text/javascript">
            $(document).ready(function () {
                var detalle = {
                    url: 'EmpresaController',
                    datos: {
                        tipo: 'get-empresas'
                    },
                    bodyDestino: 'cuerpo-tab-empresa',
                    tablaObjetivo: 'tabla-empresas'
                };
                traerListado(detalle);
                $('.dataTable').DataTable().destroy();
                $('#' + detalle.tablaObjetivo).DataTable(OPCIONES_DATATABLES);
                $('#rut').rut(
                        {
                            formatOn: 'keyup',
                            validateOn: 'blur'
                        }).on('rutInvalido', function () {
                    mostrarAlert('alert-danger', "El rut ingresado no es válido");
                }).on('rutValido', function () {
                    ocultarAlert();
                });

            });

            function insert() {
                if (validarCampos()) {
                    var rutfull = $('#rut').val().replaceAll('\\.', '');
                    var rut = rutfull.split("-")[0];
                    var dv = $('#rut').val().split('-')[1];
                    var detalle = {
                        url: 'EmpresaController',
                        datos: {
                            tipo: 'ins-empresa',
                            empresa: {
                                rutempresa: rut,
                                dvempresa: dv,
                                nomempresa: $('#nombre').val(),
                                direccion: $('#direccion').val(),
                                creacion: '',
                                ultmodificacion: ''
                            }
                        }
                    };
                    insertar(detalle, function (obj) {
                        var det = {
                            url: 'EmpresaController',
                            datos: {
                                tipo: 'get-empresas'
                            },
                            bodyDestino: 'cuerpo-tab-empresa',
                            tablaObjetivo: 'tabla-empresas'
                        };
                        traerListado(det);
                        $('.dataTable').DataTable().destroy();
                        $('#' + det.tablaObjetivo).DataTable(OPCIONES_DATATABLES);
                        limpiar();
                    });
                }
            }

            function save() {
                if (validarCampos()) {
                    var rut = $('#rut').val().split("-")[0].replaceAll("\\.", "");
                    var dv = $('#rut').val().split("-")[1];
                    var nombre = $('#nombre').val();
                    var direccion = $("#direccion").val();
                    var idEmpresa = $('#hidIdEmpresa').val();

                    var datos = {
                        tipo: 'upd-empresa',
                        empresa: {
                            idempresa: idEmpresa,
                            nombre: nombre,
                            rut: rut,
                            dv: dv,
                            direccion: direccion
                        }
                    };

                    var detalle = {
                        datos: datos,
                        url: 'EmpresaController'
                    };

                    guardar(detalle, function (obj) {
                        var det = {
                            url: 'EmpresaController',
                            datos: {
                                tipo: 'get-empresas'
                            },
                            bodyDestino: 'cuerpo-tab-empresa',
                            tablaObjetivo: 'tabla-empresas'
                        };
                        traerListado(det);
                        $('.dataTable').DataTable().destroy();
                        $('#' + det.tablaObjetivo).DataTable(OPCIONES_DATATABLES);
                        cancelarEdicion();
                    });

                }
            }

            function del(boton) {
                var fila = $(boton).parent().parent();
                if (confirm("Está seguro de que desea eliminar la empresa?")) {
                    var idEmpresa = $($(fila.children()[0]).children()[0]).val();
                    var detalle = {
                        url: 'EmpresaController',
                        datos: {
                            tipo: 'del-empresa',
                            idempresa: idEmpresa
                        }
                    };

                    eliminar(detalle, function (obj) {
                        var det = {
                            url: 'EmpresaController',
                            datos: {
                                tipo: 'get-empresas'
                            },
                            bodyDestino: 'cuerpo-tab-empresa',
                            tablaObjetivo: 'tabla-empresas'
                        };
                        traerListado(det);
                        $('.dataTable').DataTable().destroy();
                        $('#' + det.tablaObjetivo).DataTable(OPCIONES_DATATABLES);
                        limpiar();
                    });
                }
            }

            function editar(boton) {
                var fila = $(boton).parent().parent();
                var rut = $($(fila.children()[0]).children()[1]).html();
                var idEmpresa = $($(fila.children()[0]).children()[0]).val();
                $('#hidIdEmpresa').val(idEmpresa);
                $('#rut').val($.formatRut(rut));
                $('#nombre').val($(fila.children()[1]).html());
                $('#direccion').val($(fila.children()[2]).html());
                $('#edicion').removeClass('oculto');
                $('#creacion').addClass('oculto');
                $('#rut').attr("disabled", "disabled");
            }

            function cancelarEdicion() {
                $('#creacion').removeClass('oculto');
                $('#edicion').addClass('oculto');
                $('#rut').removeAttr("disabled");
                limpiar();
            }

            function limpiar() {
                $('#rut').val('');
                $('#nombre').val('');
                $('#direccion').val('');
                $('#hidIdEmpresa').val('');
            }

            function validarCampos() {
                var rut = $('#rut').val();
                var nombre = $('#nombre').val();
                var direccion = $('#direccion').val();
                if (rut.length < 2 || nombre.length < 2 || direccion.length < 2) {
                    alert('Debe ingresar todos los campos.');
                    return false;
                }
                return true;
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
                    <h2>Empresas</h2>
                </div>
            </div>
            <div class="row">
                <div class="col-sm-3">
                    <form>
                        <div class="form-group small">
                            <label for="rut">Rut</label>
                            <input type="hidden" id="hidIdEmpresa" value='' />
                            <input type="text" id="rut" maxlength="12" class="form-control form-control-sm" />
                        </div>
                        <div class="form-group small">
                            <label for="nombre">Nombre</label>
                            <input type="text" id="nombre" class="form-control form-control-sm" />
                        </div>
                        <div class="form-group small">
                            <label for="direccion">Dirección</label>
                            <input type="text" id="direccion" class="form-control form-control-sm" />
                        </div>
                        <div id='creacion' class="form-group small">
                            <button onclick="insert();" type="button" class="btn btn-primary btn-sm">Insertar</button>
                            <button onclick='limpiar();' type="button" class="btn btn-default btn-sm float-right">Limpiar</button>
                        </div>
                        <div id='edicion' class="form-group oculto small">
                            <button onclick="save();" type="button" class="btn btn-success btn-sm">Guardar</button>
                            <button onclick='cancelarEdicion();' type="button" class="btn btn-default btn-sm">Cancelar</button>
                        </div>
                    </form>
                </div>
                <!-- Contenedor de listado de empresas -->
                <div class="col-sm-9">
                    <table class="table table-sm small table-borderless table-hover table-striped" id="tabla-empresas">
                        <thead>
                            <tr>
                                <th>Rut</th>
                                <th>Nombre</th>
                                <th>Dirección</th>
                                <th>Creada</th>
                                <th>Modificada</th>
                                <th>Acción</th>
                            </tr>
                        </thead>
                        <tbody id="cuerpo-tab-empresa"></tbody>
                    </table>
                </div>
            </div>
            <div class="row">
                <div class="col-sm-3">
                    <div id="alerta" class="alert oculto">

                    </div>
                </div>
            </div>
        </div>
    </body>
</html>
