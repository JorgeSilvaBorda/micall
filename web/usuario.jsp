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
                //cargarSelectTipoUsuario();
                //cargarSelectEmpresa();
                //cargarTabla();
                var detalle = {
                    url: 'UsuarioController',
                    datos: {
                        tipo: 'get-usuarios'
                    },
                    bodyDestino: 'cuerpo-tab-usuario',
                    tablaObjetivo: 'tabla-usuarios'
                };
                traerListado(detalle);
                var det = {
                    tipo: 'carga-select-empresa',
                    url: 'EmpresaController',
                    objetivo: 'select-empresa'
                };
                cargarSelect(det);
                det = {
                    tipo: 'carga-select-tipousuario',
                    url: 'UsuarioController',
                    objetivo: 'select-tipo-usuario'
                };
                cargarSelect(det);
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

            function modalCambiar(boton) {
                var fila = $(boton).parent().parent();
                $('#rutusuariocambio').val($(fila.children()[0]).html());
                var nombres = $(fila.children()[1]).html();
                var apmaterno = $(fila.children()[2]).html();
                var appaterno = $(fila.children()[3]).html();
                $('#nombrescambio').html(nombres + ' ' + appaterno + ' ' + apmaterno);
                $('#modal-reset').modal();
            }

            function cambiarPass() {
                var rutAdmin = '<% out.print(session.getAttribute("rutusuario"));%>';
                var rutUsuario = $('#rutusuariocambio').val().replaceAll("\\.", "").replaceAll("-", "");
                var nuevaPass = $('#nuevapass').val();

                var datos = {
                    tipo: 'reset-pass-usuario',
                    rutadmin: rutAdmin,
                    rutfullusuario: rutUsuario,
                    nuevapass: nuevaPass
                };

                $.ajax({
                    type: 'post',
                    url: 'Dispatcher',
                    cache: false,
                    data: {
                        datos: JSON.stringify(datos)
                    },
                    success: function (res) {
                        var obj = JSON.parse(res);
                        if (obj.estado === 'ok') {
                            alert(obj.mensaje);
                            $('#btnCerrarModal').click();
                        }
                    },
                    error: function (a, b, c) {
                        console.log(a);
                        console.log(b);
                        console.log(c);
                    }
                });
            }

            function existeUsuario() {
                var rutusuario = $('#rut').val().split("-")[0].replaceAll("\\.", "");
                var datos = {
                    tipo: 'existe-usuario',
                    rutusuario: rutusuario
                };

                $.ajax({
                    url: 'UsuarioController',
                    type: 'post',
                    data: {
                        datos: JSON.stringify(datos)
                    },
                    success: function (res) {
                        var obj = JSON.parse(res);
                        if (obj.estado === 'ok') {
                            if (parseInt(obj.cantidad) === 0) {
                                $('#btnInsert').removeAttr("disabled");
                            } else {
                                alert("El rut de usuario que intenta ingresar ya existe.");
                                $('#btnInsert').attr("disabled", "disabled");
                            }
                        }

                    },
                    error: function (a, b, c) {
                        console.log(a);
                        console.log(b);
                        console.log(c);
                    }
                });
            }

            function insert() {
                if (validarCampos()) {
                    var usuario = {
                        idempresa: $('#select-empresa').val(),
                        idtipousuario: $('#select-tipo-usuario').val(),
                        rutusuario: $('#rut').val().split("-")[0].replaceAll("\\.", ""),
                        dvusuario: $('#rut').val().split("-")[1],
                        nombres: $('#nombres').val(),
                        appaterno: $('#appaterno').val(),
                        apmaterno: $('#apmaterno').val()
                    };
                    var detalles = {
                        
                        url: 'UsuarioController',
                        datos: {
                            tipo: 'ins-usuario',
                            usuario: usuario
                        }
                    };

                    insertar(detalles);
                }
                var detalle = {
                    url: 'UsuarioController',
                    datos: {
                        tipo: 'get-usuarios'
                    },
                    bodyDestino: 'cuerpo-tab-usuario',
                    tablaObjetivo: 'tabla-usuarios'
                };
                traerListado(detalle);
                var det = {
                    tipo: 'carga-select-empresa',
                    url: 'EmpresaController',
                    objetivo: 'select-empresa'
                };
                cargarSelect(det);
                det = {
                    tipo: 'carga-select-tipousuario',
                    url: 'UsuarioController',
                    objetivo: 'select-tipo-usuario'
                };
                cargarSelect(det);
                limpiar();
            }

            function edit(boton) {
                var fila = $(boton).parent().parent();
                $('#select-empresa option').removeAttr("selected");
                $('#select-empresa').val($(fila.children()[4]).html().replaceAll("\\.", ""));
                $('#rut').val($(fila.children()[0]).html());
                $('#nombres').val($(fila.children()[1]).html());
                $('#appaterno').val($(fila.children()[2]).html());
                $('#apmaterno').val($(fila.children()[3]).html());
                var textTipoUsuario = $(fila.children()[6]).html();
                $('#select-tipo-usuario option').removeAttr("selected");
                $('#select-tipo-usuario option').filter(function () {
                    return this.text === textTipoUsuario;
                }).attr('selected', 'selected');

                $('#edicion').removeClass('oculto');
                $('#creacion').addClass('oculto');
                $('#rut').attr("disabled", "disabled");

            }

            function save() {
                if (validarCampos()) {
                    var usuario = {
                        rut: $('#rut').val().replaceAll("\\.", "").replaceAll("-", ""),
                        nombres: $('#nombres').val(),
                        appaterno: $('#appaterno').val(),
                        apmaterno: $('#apmaterno').val(),
                        rutEmpresa: $('#select-empresa').val().replaceAll("\\.", "").replaceAll("-", ""),
                        codTipoUsuario: $('#select-tipo-usuario').val()
                    };
                    var datos = {
                        tipo: 'upd-usuario',
                        usuario: usuario
                    };

                    console.log(datos);

                    $.ajax({
                        type: 'post',
                        url: 'Dispatcher',
                        cache: false,
                        data: {
                            datos: JSON.stringify(datos)
                        },
                        success: function (res) {
                            var obj = JSON.parse(res);
                            if (obj.estado === 'ok') {
                                cargarTabla();
                                cancelarEdicion();
                            }
                        },
                        error: function (a, b, c) {
                            console.log(a);
                            console.log(b);
                            console.log(c);
                        }
                    });
                }

            }

            function limpiar() {
                $('#select-tipo-usuario option').removeAttr("selected");
                $('#select-empresa option').removeAttr("selected");
                $('#select-empresa').val('0');
                $('#select-tipo-usuario').val('0');
                $('#nombres').val('');
                $('#rut').val('');
                $('#appaterno').val('');
                $('#apmaterno').val('');
                $('#btnInsert').attr("disabled", "disabled");
                $('#descripcion').val('');
            }

            function cancelarEdicion() {
                $('#rut').removeAttr("disabled");
                $('#edicion').addClass('oculto');
                $('#creacion').removeClass('oculto');
                limpiar();
            }

            function validarCampos() {
                var rutEmpresa = $('#select-empresa').val();
                var codTipoUsuario = $('#select-tipo-usuario').val();
                var rut = $('#rut').val();
                var nombres = $('#nombres').val();
                var appaterno = $('#appaterno').val();
                var apmaterno = $('#apmaterno').val();

                if (rutEmpresa === '0' || codTipoUsuario === '0' || rut.length < 2 || nombres.length < 2 || appaterno.length < 2 || apmaterno.length < 2) {
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

            function del() {

            }

        </script>
        <!-- Modal reset pass -->
        <div class="modal fade" id="modal-reset">
            <div class="modal-dialog">
                <div class="modal-content">

                    <!-- Modal Header -->
                    <div class="modal-header">
                        <h4 class="modal-title">Resetear contraseña usuario:</h4>
                        <button type="button" class="close" data-dismiss="modal">&times;</button>
                    </div>

                    <!-- Modal body -->
                    <div class="modal-body">
                        <div class="row">
                            <div class="col-sm-4"></div>
                            <div class="col-sm-4">
                                <form>
                                    <span class="strong" id="nombrescambio"></span>
                                    <div class="form-group small">
                                        <label for="rutusuariocambio">Rut:</label>
                                        <input type="text" id="rutusuariocambio" class="form-control form-control-sm" disabled="disabled" />
                                    </div>
                                    <div class="form-group small">
                                        <label for="nuevapass">Nueva contraseña</label>
                                        <input type="password" id="nuevapass" class="form-control form-control-sm" />
                                    </div>
                                    <div class="form-group small">
                                        <button onclick="cambiarPass();" type="button" class="btn btn-primary btn-sm">Enviar</button>
                                    </div>
                                </form>
                            </div>
                            <div class="col-sm-4"></div>
                        </div>
                    </div>

                    <!-- Modal footer -->
                    <div class="modal-footer">
                        <button type="button" id="btnCerrarModal" class="btn btn-danger btn-sm" data-dismiss="modal">Cerrar</button>
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
                    <h2>Usuario</h2>
                </div>
            </div>
            <div class="row">
                <div class="col-sm-3">
                    <form>
                        <div class="form-group small">
                            <label for="select-empresa">Empresa</label>
                            <select class="form-control form-control-sm" id="select-empresa">

                            </select>
                        </div>
                        <div class="form-group small">
                            <label for="rut">Rut</label>
                            <input id="rut" type="text" onblur="existeUsuario();" class="form-control form-control-sm" /> 
                        </div>
                        <div class="form-group small">
                            <label for="nombres">Nombres</label>
                            <input id="nombres" type="text" class="form-control form-control-sm" /> 
                        </div>
                        <div class="form-group small">
                            <label for="appaterno">Apellido Paterno</label>
                            <input id="appaterno" type="text" class="form-control form-control-sm" /> 
                        </div>
                        <div class="form-group small">
                            <label for="apmaterno">Apellido Materno</label>
                            <input id="apmaterno" type="text" class="form-control form-control-sm" /> 
                        </div>
                        <div class="form-group small">
                            <label for="select-tipo-usuario">Tipo Usuario</label>
                            <select class="form-control form-control-sm" id="select-tipo-usuario">

                            </select>
                        </div>
                        <div id='creacion' class="form-group small">
                            <button id="btnInsert" onclick="insert();" disabled="disabled" type="button" class="btn btn-primary btn-sm">Insertar</button>
                            <button onclick='limpiar();' type="button" class="btn btn-default btn-sm float-right">Limpiar</button>
                        </div>
                        <div id='edicion' class="form-group oculto small">
                            <button onclick="save();" type="button" class="btn btn-success btn-sm">Guardar</button>
                            <button onclick='cancelarEdicion();' type="button" class="btn btn-default btn-sm">Cancelar</button>
                        </div>
                    </form>
                </div>
                <div class="col-sm-9">

                    <table id="tabla-usuarios" class="table table-sm small table-borderless table-hover table-striped">
                        <thead>
                            <tr>
                                <th>Rut</th>
                                <th>Nombres</th>
                                <th>Ap. Paterno</th>
                                <th>Ap. Materno</th>                         
                                <th>Rut Empresa</th>
                                <th>Empresa</th>
                                <th>Tipo Usuario</th>
                                <th>Acción</th>
                            </tr>
                        </thead>
                        <tbody id="cuerpo-tab-usuario">

                        </tbody>
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
