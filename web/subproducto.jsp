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
                    url: 'SubProductoController',
                    datos: {
                        tipo: 'get-subproductos'
                    },
                    bodyDestino: 'cuerpo-tab-subproducto',
                    tablaObjetivo: 'tabla-subproductos'
                };
                traerListado(detalle);
                $('.dataTable').DataTable().destroy();
                $('#' + detalle.tablaObjetivo).DataTable(OPCIONES_DATATABLES);

                var det = {
                    tipo: 'carga-select-empresa',
                    url: 'EmpresaController',
                    objetivo: 'select-empresa'
                };
                cargarSelect(det);
            });

            function traerSubProductos() {
                var detalle = {
                    url: 'SubProductoController',
                    datos: {
                        tipo: 'get-subproductos',
                        idempresa: '<% out.print(session.getAttribute("idempresa"));%>'
                    },
                    bodyDestino: 'cuerpo-tab-subproducto',
                    tablaObjetivo: 'tabla-subproductos'
                };
                traerListado(detalle);
                $('.dataTable').DataTable().destroy();
                $('#' + detalle.tablaObjetivo).DataTable(OPCIONES_DATATABLES);
            }
            function insert() {
                if (validarCampos()) {
                    var idempresa = $('#select-empresa').val();
                    var codigo = $('#codigo').val();
                    var descripcion = $('#descripcion').val();
                    var prima = $('#prima').val();
                    if (prima === '' || prima === '0' || prima == 0 || prima === null || prima === undefined) {
                        prima = 0.0;
                    }
                    var subproducto = {
                        idempresa: idempresa,
                        codsubproducto: codigo,
                        descsubproducto: descripcion,
                        prima: prima
                    };
                    var detalle = {
                        url: 'SubProductoController',
                        datos: {
                            tipo: 'ins-subproducto',
                            subproducto: subproducto
                        }
                    };

                    insertar(detalle, function (obj) {
                        var det = {
                            url: 'SubProductoController',
                            datos: {
                                tipo: 'get-subproductos'
                            },
                            bodyDestino: 'cuerpo-tab-subproducto',
                            tablaObjetivo: 'tabla-subproductos'
                        };
                        traerListado(det);
                        $('.dataTable').DataTable().destroy();
                        $('#' + det.tablaObjetivo).DataTable(OPCIONES_DATATABLES);
                        limpiar();
                    });

                }
            }

            function existeSubProducto() {
                if ($('#hidIdSubProducto').val() === '') {
                    var subproducto = {
                        codsubproducto: $('#codigo').val(),
                        idempresa: $('#select-empresa').val()
                    };

                    var datos = {
                        tipo: 'existe-subproducto',
                        subproducto: subproducto
                    };

                    $.ajax({
                        type: 'post',
                        url: 'SubProductoController',
                        data: {
                            datos: JSON.stringify(datos)
                        },
                        success: function (res) {
                            var obj = JSON.parse(res);
                            if (obj.estado === 'ok') {
                                if (parseInt(obj.cantidad) > 0) {
                                    alert('El subproducto de código: ' + subproducto.codsubproducto + ' ya existe para la empresa seleccionada.');
                                    $('#btnInsert').attr("disabled", "disabled");
                                } else {
                                    $('#btnInsert').removeAttr("disabled");
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
            }

            function edit(boton) {
                var fila = $(boton).parent().parent();
                var codsubproducto = $($(fila.children()[0]).children()[2]).html();
                var descsubproducto = $(fila.children()[1]).html();
                var prima = $(fila.children()[4]).html();
                var idsubproducto = $($(fila.children()[0]).children()[0]).val();
                var idempresa = $($(fila.children()[0]).children()[1]).val();
                $('#hidIdSubProducto').val(idsubproducto);
                $('#hidIdEmpresa').val(idempresa);
                $('#select-empresa').val(idempresa);
                $('#nombre').val(descsubproducto);
                $('#prima').val(prima);
                $('#codigo').val(codsubproducto);
                $('#descripcion').val(descsubproducto);
                $('#edicion').removeClass('oculto');
                $('#creacion').addClass('oculto');
            }

            function save() {
                if (validarCampos()) {
                    var prima = $('#prima').val();
                    if (prima === '' || prima === null || prima === undefined) {
                        prima = 0;
                    }
                    var subproducto = {
                        idsubproducto: $('#hidIdSubProducto').val(),
                        idempresa: $('#hidIdEmpresa').val(),
                        codsubproducto: $('#codigo').val(),
                        descsubproducto: $('#descripcion').val(),
                        prima: prima
                    };
                    var datos = {
                        tipo: 'upd-subproducto',
                        subproducto: subproducto
                    };

                    var detalle = {
                        url: "SubProductoController",
                        datos: datos
                    };
                    //console.log(detalle);
                    guardar(detalle, function (obj) {
                        var det = {
                            url: 'SubProductoController',
                            datos: {
                                tipo: 'get-subproductos'
                            },
                            bodyDestino: 'cuerpo-tab-subproducto',
                            tablaObjetivo: 'tabla-subproductos'
                        };
                        traerListado(det);
                        $('.dataTable').DataTable().destroy();
                        $('#' + det.tablaObjetivo).DataTable(OPCIONES_DATATABLES);
                        limpiar();
                    });
                }
            }

            function limpiar() {
                $('#select-empresa option').removeAttr("selected");
                $('#select-empresa').val('0');
                $('#codigo').val('');
                $('#descripcion').val('');
                $('#prima').val('');
                $('#btnInsert').attr("disabled", "disabled");
                $('#hidIdSubProducto').val('');
                $('#hidIdEmpresa').val('');
                $('#edicion').addClass('oculto');
                $('#creacion').removeClass('oculto');
            }

            function cancelarEdicion() {
                $('#edicion').addClass('oculto');
                $('#creacion').removeClass('oculto');
                limpiar();
            }

            function validarCampos() {
                var idempresa = $('#select-empresa').val();
                var codigo = $('#codigo').val();
                var descripcion = $('#descripcion').val();

                if (idempresa === '0' || codigo.length < 2 || descripcion.length < 2) {
                    alert('Debe ingresar todos los campos.');
                    $('#btnInsert').attr("disabled", "disabled");
                    return false;
                }
                $('#btnInsert').removeAttr("disabled");
                return true;
            }

            function del(boton) {
                var fila = $(boton).parent().parent();
                var idsubproducto = $($(fila.children()[0]).children()[0]).val();

                if (confirm('Está seguro que desea eliminar el subproducto seleccionado?')) {
                    var detalle = {
                        url: 'SubProductoController',
                        datos: {
                            tipo: 'del-subproducto',
                            idsubproducto: idsubproducto
                        }
                    };
                    eliminar(detalle, function (obj) {
                        var det = {
                            url: 'SubProductoController',
                            datos: {
                                tipo: 'get-subproductos'
                            },
                            bodyDestino: 'cuerpo-tab-subproducto',
                            tablaObjetivo: 'tabla-subproductos'
                        };
                        traerListado(det);
                        $('.dataTable').DataTable().destroy();
                        $('#' + detalle.tablaObjetivo).DataTable(OPCIONES_DATATABLES);
                    });

                }
            }

        </script>
        <div class="container-fluid">
            <br />
            <br />
            <br />
            <div class="row">
                <div class="col-sm-12">
                    <h2>Sub Producto</h2>
                </div>
            </div>
            <div class="row">
                <div class="col-sm-4">
                    <form>
                        <input type='hidden'id='hidIdSubProducto' value='' />
                        <input type='hidden'id='hidIdEmpresa' value='' />
                        <div class="form-group small">
                            <label for="select-empresa">Empresa</label>
                            <select class="form-control form-control-sm" id="select-empresa">

                            </select>
                        </div>
                        <div class="form-group small">
                            <label for="codigo">Código</label>
                            <input onblur="existeSubProducto();" id="codigo" type="text" class="form-control form-control-sm" /> 
                        </div>
                        <div class="form-group small">
                            <label for="descripcion">Descripción</label>
                            <input id="descripcion" type="text" class="form-control form-control-sm" /> 
                        </div>
                        <div class="form-group small">
                            <label for="prima">Prima</label>
                            <input id="prima" type="number" step="0.01" min="0.00" max="100.00" class="form-control form-control-sm" /> 
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
                <div class="col-sm-8">

                    <table id="tabla-subproductos" class="table table-sm small table-borderless table-hover table-striped">
                        <thead>
                            <tr>
                                <th>Código</th>
                                <th>Descripción</th>
                                <th>Empresa</th>
                                <th>Rut</th>                         
                                <th>Prima</th>
                                <th>Acción</th>
                            </tr>
                        </thead>
                        <tbody id="cuerpo-tab-subproducto">

                        </tbody>
                    </table>

                </div>
            </div>
        </div>
    </body>
</html>
