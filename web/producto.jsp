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
                    url: 'ProductoController',
                    datos: {
                        tipo: 'get-productos'
                    },
                    bodyDestino: 'cuerpo-tab-producto',
                    tablaObjetivo: 'tabla-productos'
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

            function insert() {
                if (validarCampos()) {
                    var idempresa = $('#select-empresa').val();
                    var codigo = $('#codigo').val();
                    var descripcion = $('#descripcion').val();
                    var producto = {
                        idempresa: idempresa,
                        codproducto: codigo,
                        descproducto: descripcion
                    };
                    var detalle = {
                        url: 'ProductoController',
                        datos: {
                            tipo: 'ins-producto',
                            producto: producto
                        }
                    };

                    insertar(detalle);
                    var det = {
                        url: 'ProductoController',
                        datos: {
                            tipo: 'get-productos'
                        },
                        bodyDestino: 'cuerpo-tab-producto',
                        tablaObjetivo: 'tabla-productos'
                    };
                    traerListado(det);
                    $('.dataTable').DataTable().destroy();
                    $('#' + det.tablaObjetivo).DataTable(OPCIONES_DATATABLES);
                    limpiar();
                }
            }

            function existeProducto() {
                if ($('#hidIdProducto').val() === '') {
                    var producto = {
                        codproducto: $('#codigo').val(),
                        idempresa: $('#select-empresa').val()
                    };

                    var datos = {
                        tipo: 'existe-producto',
                        producto: producto
                    };

                    $.ajax({
                        type: 'post',
                        url: 'ProductoController',
                        data: {
                            datos: JSON.stringify(datos)
                        },
                        success: function (res) {
                            var obj = JSON.parse(res);
                            if (obj.estado === 'ok') {
                                if (parseInt(obj.cantidad) > 0) {
                                    alert('El producto de código: ' + producto.codigo + ' ya existe para la empresa seleccionada.');
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
                var codproducto = $($(fila.children()[0]).children()[2]).html();
                var descproducto = $(fila.children()[1]).html();
                var idproducto = $($(fila.children()[0]).children()[0]).val();
                var idempresa = $($(fila.children()[0]).children()[1]).val();
                $('#hidIdProducto').val(idproducto);
                $('#hidIdEmpresa').val(idempresa);
                $('#select-empresa').val(idempresa);
                $('#nombre').val(descproducto);
                $('#codigo').val(codproducto);
                $('#descripcion').val(descproducto);
                $('#edicion').removeClass('oculto');
                $('#creacion').addClass('oculto');
            }

            function save() {
                if (validarCampos()) {
                    var producto = {
                        idproducto: $('#hidIdProducto').val(),
                        idempresa: $('#hidIdEmpresa').val(),
                        codproducto: $('#codigo').val(),
                        descproducto: $('#descripcion').val()
                    };
                    var datos = {
                        tipo: 'upd-producto',
                        producto: producto
                    };

                    var detalle = {
                        url: "ProductoController",
                        datos: datos
                    };
                    //console.log(detalle);
                    guardar(detalle);
                }
                var det = {
                    url: 'ProductoController',
                    datos: {
                        tipo: 'get-productos'
                    },
                    bodyDestino: 'cuerpo-tab-producto',
                    tablaObjetivo: 'tabla-productos'
                };
                traerListado(det);
                $('.dataTable').DataTable().destroy();
                $('#' + det.tablaObjetivo).DataTable(OPCIONES_DATATABLES);
                limpiar();
            }

            function limpiar() {
                $('#select-empresa option').removeAttr("selected");
                $('#select-empresa').val('0');
                $('#codigo').val('');
                $('#descripcion').val('');
                $('#btnInsert').attr("disabled", "disabled");
                $('#hidIdProducto').val('');
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
                var idproducto = $($(fila.children()[0]).children()[0]).val();

                if (confirm('Está seguro que desea eliminar el producto seleccionado?')) {
                    var detalle = {
                        url: 'ProductoController',
                        datos: {
                            tipo: 'del-producto',
                            idproducto: idproducto
                        }
                    };
                    eliminar(detalle);
                    var det = {
                        url: 'ProductoController',
                        datos: {
                            tipo: 'get-productos'
                        },
                        bodyDestino: 'cuerpo-tab-producto',
                        tablaObjetivo: 'tabla-productos'
                    };
                    traerListado(det);
                    $('.dataTable').DataTable().destroy();
                    $('#' + det.tablaObjetivo).DataTable(OPCIONES_DATATABLES);
                }
            }

            function traerProductos() {
                var det = {
                    url: 'ProductoController',
                    datos: {
                        tipo: 'get-productos'
                    },
                    bodyDestino: 'cuerpo-tab-producto',
                    tablaObjetivo: 'tabla-productos'
                };
                traerListado(det);
                $('.dataTable').DataTable().destroy();
                $('#' + det.tablaObjetivo).DataTable(OPCIONES_DATATABLES);
            }
        </script>
        <div class="container-fluid">
            <br />
            <br />
            <br />
            <div class="row">
                <div class="col-sm-12">
                    <h2>Producto</h2>
                </div>
            </div>
            <div class="row">
                <div class="col-sm-4">
                    <form>
                        <input type='hidden'id='hidIdProducto' value='' />
                        <input type='hidden'id='hidIdEmpresa' value='' />
                        <div class="form-group small">
                            <label for="select-empresa">Empresa</label>
                            <select onchange="traerProductos();" class="form-control form-control-sm" id="select-empresa">

                            </select>
                        </div>
                        <div class="form-group small">
                            <label for="codigo">Código</label>
                            <input onblur="existeProducto();" id="codigo" type="text" class="form-control form-control-sm" /> 
                        </div>
                        <div class="form-group small">
                            <label for="descripcion">Descripción</label>
                            <input id="descripcion" type="text" class="form-control form-control-sm" /> 
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

                    <table id="tabla-productos" class="table table-sm small table-borderless table-hover table-striped">
                        <thead>
                            <tr>
                                <th>Código</th>
                                <th>Descripción</th>
                                <th>Empresa</th>
                                <th>Rut</th>                         
                                <th>Acción</th>
                            </tr>
                        </thead>
                        <tbody id="cuerpo-tab-producto">

                        </tbody>
                    </table>

                </div>
            </div>
        </div>
    </body>
</html>
