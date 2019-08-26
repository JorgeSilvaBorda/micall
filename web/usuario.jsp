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
                OPCIONES_DATATABLES.buttons = false;
                listarUsuarios();
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
                $('#rut').rut({
                    formatOn: 'keyup'
                });

            });

            function listarUsuarios() {
                var detalle = {
                    url: 'UsuarioController',
                    datos: {
                        tipo: 'get-usuarios'
                    },
                    bodyDestino: 'cuerpo-tab-usuario',
                    tablaObjetivo: 'tabla-usuarios'
                };
                $.ajax({
                    type: 'post',
                    url: detalle.url,
                    data: {
                        datos: JSON.stringify(detalle.datos)
                    },
                    success: function (res) {
                        var obj = JSON.parse(res);
                        if (obj.estado === 'ok') {
                            $('.dataTable').DataTable().destroy();
                            $('#cuerpo-tab-usuario').html(obj.cuerpotabla);
                            var tab = $('#tabla-usuarios').DataTable(OPCIONES_DATATABLES);
                            //new $.fn.dataTable.FixedHeader(tab, OPCIONES_FIXED);
                        } else {
                            console.log("Error");
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

            function validarCampoRut() {
                var rutfullusuario = $('#rut').val().replaceAll("\\.", "").replaceAll("-", "");
                var rutusuario = $('#rut').val().replaceAll("\\.", "").split("-")[0];
                var dvusuario = $('#rut').val().split("-")[1];
                //primero validar que sea rut válido.
                if ($.validateRut(rutfullusuario)) {
                    esNuevoRut(function (esNuevo) {
                        if (esNuevo) {
                            $('#btnInsert').removeAttr("disabled");
                            ocultarAlert();
                        } else {
                            $('#btnInsert').attr("disabled", "disabled");
                            mostrarAlert("alert-danger", "El rut ya existe en la base de datos.");
                        }
                    });
                } else {
                    mostrarAlert("alert-danger", "El rut ingresado es inválido");
                    $('#btnInsert').attr("disabled", "disabled");
                }
            }

            function modalCambiar(boton) {
                var fila = $(boton).parent().parent();
                var rutusuario = $(fila.children()[0]).text();
                $('#rutusuariocambio').val(rutusuario);
                var nombres = $(fila.children()[1]).html();
                var appaterno = $(fila.children()[2]).html();
                var apmaterno = $(fila.children()[3]).html();
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
                    url: 'UsuarioController',
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

            function esNuevoRut(callback) {
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
                                callback(true);
                            } else {
                                callback(false);
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

                    insertar(detalles, function (obj) {
                        listarUsuarios();
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
                    });
                }

            }

            function edit(boton) {
                var fila = $(boton).parent().parent();
                var idusuario = $($(fila.children()[0]).children()[0]).val();
                var idempresa = $($(fila.children()[0]).children()[1]).val();
                var rutfullusuario = $($(fila.children()[0]).children()[2]).html();
                var rutusuario = rutfullusuario.split("-")[0].replaceAll("\\.", "");
                var dvusuario = rutfullusuario.split("-")[1];
                var nombres = $(fila.children()[1]).html();
                var appaterno = $(fila.children()[2]).html();
                var apmaterno = $(fila.children()[3]).html();
                var idtipousuario = $($(fila.children()[6]).children()[0]).val();
                var usuario = {
                    idusuario: parseInt(idusuario),
                    idempresa: parseInt(idempresa),
                    rutusuario: parseInt(rutusuario),
                    dvusuario: dvusuario,
                    nombres: nombres,
                    appaterno: appaterno,
                    apmaterno: apmaterno,
                    idtipousuario: parseInt(idtipousuario)
                };
                //console.log(usuario);

                $('#select-empresa option').removeAttr("selected");
                $('#select-empresa').val(usuario.idempresa);
                $('#rut').val($.formatRut(usuario.rutusuario + "-" + usuario.dvusuario));
                $('#nombres').val(usuario.nombres);
                $('#appaterno').val(usuario.appaterno);
                $('#apmaterno').val(usuario.apmaterno);
                $('#select-tipo-usuario option').removeAttr("selected");
                $('#select-tipo-usuario').val(usuario.idtipousuario);
                $('#hidIdUsuario').val(usuario.idusuario);
                $('#edicion').removeClass('oculto');
                $('#creacion').addClass('oculto');
            }

            function save() {
                if (validarCampos()) {
                    var usuario = {
                        idusuario: $('#hidIdUsuario').val(),
                        rutusuario: $('#rut').val().split("-")[0].replaceAll("\\.", ""),
                        dvusuario: $('#rut').val().split("-")[1],
                        nombres: $('#nombres').val(),
                        appaterno: $('#appaterno').val(),
                        apmaterno: $('#apmaterno').val(),
                        idempresa: $('#select-empresa').val(),
                        idtipousuario: $('#select-tipo-usuario').val()
                    };
                    var datos = {
                        tipo: 'upd-usuario',
                        usuario: usuario
                    };

                    var detalle = {
                        url: 'UsuarioController',
                        datos: datos
                    };

                    guardar(detalle, function (obj) {
                        listarUsuarios();
                        var dets = {
                            tipo: 'carga-select-empresa',
                            url: 'EmpresaController',
                            objetivo: 'select-empresa'
                        };
                        cargarSelect(dets);
                        var det = {
                            tipo: 'carga-select-tipousuario',
                            url: 'UsuarioController',
                            objetivo: 'select-tipo-usuario'
                        };
                        cargarSelect(det);                        
                        cancelarEdicion();
                    });
                }
            }

            function limpiar() {
                $('#select-tipo-usuario option').removeAttr("selected");
                $('#select-empresa option').removeAttr("selected");
                $('#select-empresa').val('0');
                $('#select-empresa').removeAttr("disabled");
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
                $('#btnInsert').attr('disabled', 'disabled');
                $('#btnSave').attr('disabled', 'disabled');
            }

            function ocultarAlert() {
                $('#alerta').fadeOut(500);
                $('#alerta').html('');
                $('#btnInsert').removeAttr('disabled');
                $('#btnSave').removeAttr('disabled');
            }

            function del(boton) {
                if (confirm("Está seguro de que desea eliminar el usuario seleccionado?")) {
                    var fila = $(boton).parent().parent();

                    var idusuario = $($(fila.children()[0]).children()[0]).val();

                    var datos = {
                        tipo: 'del-usuario',
                        idusuario: idusuario
                    };
                    var detalle = {
                        url: 'UsuarioController',
                        datos: datos
                    };

                    eliminar(detalle, function (obj) {
                        listarUsuarios();
                        var dets = {
                            tipo: 'carga-select-empresa',
                            url: 'EmpresaController',
                            objetivo: 'select-empresa'
                        };
                        cargarSelect(dets);
                        var det = {
                            tipo: 'carga-select-tipousuario',
                            url: 'UsuarioController',
                            objetivo: 'select-tipo-usuario'
                        };
                        cargarSelect(det);
                        limpiar();
                    });
                }
            }

            function esVendedor(select) {//Validar que si es vendedor o administrador, se pueda escoger únicamente la administración interna
                if (parseInt($(select).val()) === 3 || parseInt($(select).val()) === 1) {
                    $('#select-empresa').val(1);
                    $('#select-empresa').attr("disabled", "disabled");
                } else {
                    $('#select-empresa').removeAttr("disabled");
                    $('#select-empresa').val(0);
                }
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
                        <input type="hidden" id="hidIdUsuario" value="" />
                        <div class="form-group small">
                            <label for="select-empresa">Empresa</label>
                            <select class="form-control form-control-sm" id="select-empresa">

                            </select>
                        </div>
                        <div class="form-group small">
                            <label for="rut">Rut</label>
                            <input onblur="validarCampoRut();" id="rut" type="text" class="form-control form-control-sm" /> 
                        </div>
                        <div id="alerta" class="alert oculto">

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
                            <select onchange="esVendedor(this);" class="form-control form-control-sm" id="select-tipo-usuario">

                            </select>
                        </div>
                        <div id='creacion' class="form-group small">
                            <button id="btnInsert" onclick="insert();" disabled="disabled" type="button" class="btn btn-primary btn-sm">Insertar</button>
                            <button onclick='limpiar();' type="button" class="btn btn-default btn-sm float-right">Limpiar</button>
                        </div>
                        <div id='edicion' class="form-group oculto small">
                            <button id="btnSave" onclick="save();" type="button" class="btn btn-success btn-sm">Guardar</button>
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

            </div>
        </div>
    </body>
</html>
