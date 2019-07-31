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
                //cargar select empresa
                llenarSelectEmpresa()
            });

            function traerCampanas() {

            }

            function llenarSelectEmpresa() {

                var det = {
                    tipo: 'carga-select-empresa',
                    url: 'EmpresaController',
                    objetivo: 'select-empresa'
                };
                cargarSelect(det);
            }

            function cargaSelectProducto() {
                if ($('#select-empresa').val() !== '0') {
                    var datos = {
                        tipo: 'carga-datos-producto',
                        idempresa: $('#select-empresa').val()
                    };
                    var detalle = {
                        url: 'ProductoController',
                        objetivo: 'select-producto',
                        datos: datos
                    };

                    cargarSelectParams(detalle);
                    //Meter acá la carga de subproductos

                    var detSubs = {
                        url: 'SubProductoController',
                        bodyDestino: 'cuerpo-tab-subproducto',
                        datos: {
                            tipo: 'get-subproductos-readonly',
                            idempresa: $('#select-empresa').val()
                        }
                    };
                    $('#cuerpo-tab-subproductos').html('');
                    traerListado(detSubs);
                } else {
                    $('#select-producto').html('');
                }
            }

            function cargarTabla() {
                var datos = {
                    tipo: 'carga-tabla-campana'
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
                            $('.dataTable').DataTable().destroy();
                            $('#cuerpo-tab-campanas').html(armarTabla(obj.campanas));
                            $('#tabla-campanas').DataTable(OPCIONES_DATATABLES);
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
                var codcampana = $('#codcampana').val();
                var nomcampana = $('#nomcampana').val();
                var idempresa = $('#select-empresa').val(); //solo efectos de validación
                var idproducto = $('#select-producto').val();
                var desde = $('#desde').val();
                var hasta = $('#hasta').val();
                var meta = $('#meta').val();

                var campana = {
                    codcampana: codcampana,
                    nomcampana: nomcampana,
                    idproducto: parseInt(idproducto),
                    fechaini: desde,
                    fechafin: hasta,
                    meta: parseInt(meta),
                    subproductos: []
                };

                //recorrer tabla subproductos
                var tabla = $('#tabla-subproductos');
                $('#cuerpo-tab-subproducto tr').each(function (i) {
                    var celdas = $(this).children();
                    var idsubproducto = $($(this).children()[0]).children(0).val();
                    var montometa = $($(this).children()[3]).children(0).val();
                    var cantmeta = $($(this).children()[3]).children(0).val();

                    var subproducto = {
                        idsubproducto: idsubproducto,
                        montometa: montometa,
                        cantmeta: cantmeta
                    };

                    campana.subproductos.push(subproducto);
                });

                console.log(campana);
            }

            function save() {
                if (validarCampos()) {
                    var codprod = $('#select-producto').val();
                    var fechaini = $('#desde').val();
                    var fechafin = $('#hasta').val();
                    var meta = $('#meta').val();
                    meta = meta.replaceAll("\\.", ""); //Quitar los puntos del formateador de miles en la meta.
                    CAMPANA_ANTERIOR.meta = CAMPANA_ANTERIOR.meta.replaceAll("\\.", "");
                    var datos = {
                        tipo: 'guardar-campana',
                        codprod: codprod,
                        fechaini: fechaini,
                        fechafin: fechafin,
                        meta: meta,
                        codprodAnterior: CAMPANA_ANTERIOR.codigo,
                        fechainiAnterior: CAMPANA_ANTERIOR.desde,
                        fechafinAnterior: CAMPANA_ANTERIOR.hasta,
                        metaAnterior: CAMPANA_ANTERIOR.meta
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

            function edit(boton) {
                var fila = $(boton).parent().parent();
                $('#select-empresa').val($(fila.children()[0]).html().replaceAll("\\.", ""));
                cargaSelectProducto($(fila.children()[2]).html());

                $('#desde').val($(fila.children()[4]).html());
                $('#hasta').val($(fila.children()[5]).html());
                $('#meta').val($(fila.children()[6]).html());
                $('#meta').keyup(); //Para aplicar el formateo de miles...
                //$('#select-producto').val($(fila.children()[2]).html());
                $('#creacion').addClass('oculto');
                $('#edicion').removeClass('oculto');

                //Ajustar datos anteriores fijos
                CAMPANA_ANTERIOR = {
                    codigo: $(fila.children()[2]).html(),
                    desde: $(fila.children()[4]).html(),
                    hasta: $(fila.children()[5]).html(),
                    meta: $(fila.children()[6]).html()
                };
            }

            function limpiar() {
                $('#select-empresa option').removeAttr('selected');
                $('#select-producto option').removeAttr('selected');
                $('#select-empresa').val('0');
                $('#select-producto').html('');
                $('#desde').val('');
                $('#hasta').val('');
                $('#meta').val('');
                //$('#codCampana').val('');
                //$('#nomCampana').val('');
                CAMPANA_ANTERIOR = null;
            }

            function cancelarEdicion() {
                $('#edicion').addClass('oculto');
                $('#creacion').removeClass('oculto');
                limpiar();
            }

            function validarCampos() {
                var rutEmpresa = $('#select-empresa').val();
                var codProd = $('#select-producto').val();
                //var codCampana = $('#codCampana').val();
                //var nomCampana = $('#nomCampana').val();
                var desde = $('#desde').val();
                var hasta = $('#hasta').val();
                var meta = $('#meta').val();
                meta = meta.replaceAll("\\.", ""); //Quitar los puntos del formateador de miles

                if (rutEmpresa === '0' || codProd < 1 || desde.length < 2 || hasta.length < 2 || meta.length < 2) {
                    alert('Debe ingresar todos los campos.');
                    return false;
                }
                return true;
            }

            function checkCampos(check) {
                var fila = $(check).parent().parent();
                if (check.checked) {
                    $($(fila).children()[3]).children(0).removeClass("oculto");
                    $($(fila).children()[4]).children(0).removeClass("oculto");
                }else{
                    $($(fila).children()[3]).children(0).addClass("oculto");
                    $($(fila).children()[4]).children(0).addClass("oculto");
                }
            }
        </script>
        <div class="container-fluid">
            <br />
            <br />
            <br />
            <div class="row">
                <div class="col-sm-12">
                    <h2>Campañas</h2>
                </div>
            </div>
            <div class="row">
                <div class="col-sm-4">
                    <form>
                        <div class="form-group small">
                            <label for="codcampana">Código</label>
                            <input id="codcampana" type="text" class="form-control form-control-sm" />
                        </div>
                        <div class="form-group small">
                            <label for="nomcampana">Nombre</label>
                            <input id="nomcampana" type="text" class="form-control form-control-sm" />
                        </div>
                        <div class="form-group small">
                            <label for="select-empresa">Empresa</label>
                            <select onchange="cargaSelectProducto();" class="form-control form-control-sm" id="select-empresa">
                            </select>
                        </div>
                        <div class="form-group small">
                            <label for="select-producto">Producto</label>
                            <select class="form-control form-control-sm" id="select-producto">

                            </select>
                        </div>
                        <div class="form-group small">
                            <div class="form-row">
                                <div class="col">
                                    <label for="desde">Desde</label>
                                    <input id="desde" type="date" class="form-control form-control-sm" />
                                </div>
                                <div class="col">
                                    <label for="hasta">Hasta</label>
                                    <input id="hasta" type="date" class="form-control form-control-sm" />
                                </div>
                            </div>
                        </div>
                        <label class="small" for="meta">Meta</label>
                        <div class="input-group mb-2 input-group-sm">
                            <div class="input-group-prepend">
                                <span class="input-group-text">$</span>
                            </div>
                            <input id="meta" type="text" onkeyup="formatMilesInput(this);" class="form-control form-control-sm" aria-label="Valor en pesos">
                        </div>
                    </form>
                    <div id='creacion' class="form-group small">
                        <button onclick="insert();" type="button" class="btn btn-primary btn-sm">Insertar</button>
                        <button onclick='limpiar();' type="button" class="btn btn-default btn-sm float-right">Limpiar</button>
                    </div>
                    <div id='edicion' class="form-group oculto small">
                        <button onclick="save();" type="button" class="btn btn-success btn-sm">Guardar</button>
                        <button onclick='cancelarEdicion();' type="button" class="btn btn-default btn-sm">Cancelar</button>
                    </div>
                </div>
                <div class="col-sm-8">
                    <h3>Subproductos</h3>
                    <table id="tabla-subproductos" class="table table-sm small table-borderless table-hover table-striped">
                        <thead>
                            <tr>
                                <th>Código</th>
                                <th>Descripción</th>
                                <th>Prima</th>
                                <th>Monto Meta</th>
                                <th>Cant. Meta</th>
                                <th>Seleccionar</th>
                            </tr>
                        </thead>
                        <tbody id="cuerpo-tab-subproducto">

                        </tbody>
                    </table>
                </div>
            </div>
            <div class="row">
                <div class="col-sm-8">
                    <table id="tabla-campanas" class="table table-sm small table-borderless table-hover table-striped">
                        <thead>
                            <tr>
                                <th>Rut</th>
                                <th>Empresa</th>
                                <th>Código</th>
                                <th>Nombre</th>
                                <th>Desde</th>
                                <th>Hasta</th>
                                <th>Meta</th>
                                <th>Subproductos</th>
                                <th>Acción</th>
                            </tr>
                        </thead>
                        <tbody id="cuerpo-tab-campanas">

                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </body>
</html>
