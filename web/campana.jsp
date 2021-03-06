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
            $(document).ready(function () {
                OPCIONES_DATATABLES.buttons = [];
                //cargar select empresa
                llenarSelectEmpresa();
                cargaSelectTipoCampana();
                traerCampanas();
                $('#meta').attr("disabled", "disabled");
            });

            function traerCampanas() {
                var detalle = {
                    url: 'CampanaController',
                    bodyDestino: 'cuerpo-tab-campanas',
                    datos: {
                        tipo: 'get-campanas'
                    }
                };
                traerListado(detalle, function (resp) {
                    $('.dataTable').DataTable().destroy();
                    $('#cuerpo-tab-campanas').html(resp);
                    var tab = $('#tabla-campanas').DataTable(OPCIONES_DATATABLES);
                });
            }

            function llenarSelectEmpresa() {

                var det = {
                    tipo: 'carga-select-empresa',
                    url: 'EmpresaController',
                    objetivo: 'select-empresa'
                };
                cargarSelect(det);
            }

            function cargaSelectTipoCampana() {
                var datos = {
                    tipo: 'select-tipo-campana'
                };
                $.ajax({
                    type: 'post',
                    url: 'TipoCampanaController',
                    data: {
                        datos: JSON.stringify(datos)
                    },
                    success: function (resp) {
                        var obj = JSON.parse(resp);
                        if (obj.estado === 'ok') {
                            $('#select-tipo-campana').html(obj.options);
                        } else {
                            console.log("Error al traer los tipos de campaña.");
                            console.log("Mensaje");
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
                    var idtipocampana = parseInt($('#select-tipo-campana').val());
                    if (idtipocampana === 3) {
                        traerListado(detSubs, function (resp) {

                        });
                    }

                } else {
                    $('#select-producto').html('');
                }
            }

            function changeTipoCampana() {
                var idtipocampana = parseInt($('#select-tipo-campana').val());
                if (idtipocampana === 0 || idtipocampana === 1 || idtipocampana === 2) {
                    desactivarCampos();
                } else {
                    activarCampos();
                }
            }

            function desactivarCampos() {
                $('#meta').attr("disabled", "disabled");
            }

            function activarCampos() {
                $('#meta').removeAttr("disabled");
            }

            function insert() {
                var codcampana = $('#codcampana').val();
                var nomcampana = $('#nomcampana').val();
                //var idempresa = $('#select-empresa').val(); //solo efectos de validación
                var idproducto = $('#select-producto').val();
                var idtipocampana = $('#select-tipo-campana').val();
                var desde = $('#desde').val();
                var hasta = $('#hasta').val();
                var meta = $('#meta').val();
                if (idtipocampana === 3) {
                    meta = parseInt(meta.replaceAll("\\.", ""));
                } else {
                    meta = -1;
                }
                var campana = {
                    codcampana: codcampana,
                    nomcampana: nomcampana,
                    idtipocampana: idtipocampana,
                    idproducto: parseInt(idproducto),
                    fechaini: desde,
                    fechafin: hasta,
                    meta: meta,
                    subproductos: []
                };

                //recorrer tabla subproductos
                $('#cuerpo-tab-subproducto tr').each(function (i) {
                    var idsubproducto = $($(this).children()[0]).children(0).val();
                    var montometa = $($(this).children()[2]).children(0).val();
                    var cantmeta = $($(this).children()[3]).children(0).val();
                    var check = $($(this).children()[4]).children()[0];
                    if (check.checked) {
                        var subproducto = {
                            idsubproducto: parseInt(idsubproducto),
                            montometa: parseInt(montometa.replaceAll("\\.", "")),
                            cantmeta: parseInt(cantmeta.replaceAll("\\.", ""))
                        };
                        campana.subproductos.push(subproducto);
                    }
                });


                if (validar(campana)) {
                    var detalle = {
                        url: 'CampanaController',
                        datos: {
                            tipo: 'ins-campana',
                            campana: campana
                        }
                    };

                    insertar(detalle, function (obj) {
                        limpiar();
                        traerCampanas();
                    });

                }

            }

            function validar(campana) {
                if (campana.idtipocampana === 0 || campana.idtipocampana === '' || campana.idtipocampana === undefined || campana.idtipocampana === null) {
                    alert("Debe seleccionar el tipo de campaña que desea crear.");
                    return false;
                }
                if (campana.codcampana === '' || campana.codcampana === null || campana.codcampana === undefined) {
                    alert('Debe ingresar el código de la campaña.');
                    return false;
                }
                if (campana.nomcampana === '' || campana.nomcampana === null || campana.nomcampana === undefined) {
                    alert('Debe ingresar el nombre de la campaña.');
                    return false;
                }
                if (campana.idproducto === '' || campana.idproducto === null || campana.idproducto === undefined || campana.idproducto === 0 || campana.idproducto === '0' || isNaN(campana.idproducto)) {
                    alert('Debe seleccionar el producto para la campaña.');
                    return false;
                }
                if (campana.fechaini === '' || campana.fechaini === null || campana.fechaini === undefined) {
                    alert('Debe ingresar la fecha de inicio para la campaña.');
                    return false;
                }
                var fecIni = new Date(campana.fechaini);
                var fecFin = new Date(campana.fechafin);

                if (fecFin <= fecIni) {
                    alert('La fecha de inicio de la campaña no puede ser posterior a la fecha de término.');
                    return false;
                }
                if (campana.fechafin === '' || campana.fechafin === null || campana.fechafin === undefined) {
                    alert('Debe ingresar la fecha de término para la campaña.');
                    return false;
                }

                var idtipocampana = $('#select-tipo-campana').val();
                if (parseInt(idtipocampana) === 3) {
                    if (campana.meta === '' || campana.meta === null || campana.meta === undefined || campana.meta === 0 || campana.meta === '0' || isNaN(campana.meta)) {
                        alert('Debe indicar el monto de la meta para la campaña.');
                        return false;
                    }
                }
                if (campana.subproductos.length > 0) {
                    $(campana.subproductos).each(function (i) {
                        var montometa = $(this)[0].montometa;
                        var cantmeta = $(this)[0].cantmeta;
                        if (montometa === '' || montometa === 0 || montometa === null || montometa === undefined || isNaN(montometa) || montometa <= 2) {
                            alert('Debe ingresar un monto de meta para los subproductos seleccionados.');
                            return false;
                        }
                        if (cantmeta === '' || cantmeta === 0 || cantmeta === null || cantmeta === undefined || isNaN(cantmeta) || cantmeta <= 2) {
                            alert('Debe ingresar una cantidad de meta para los subproductos seleccionados.');
                            return false;
                        }

                    });
                }
                //Validar que la fecha de inicio de la campaña no pueda ser inferior al primer día del mes en curso.
                var fechaPrimerDia = new Date();
                fechaPrimerDia.setDate(1);
                var fec = formatFecha(fechaPrimerDia);
                if (diffFechas(fec, $('#desde').val()) < 1) {
                    alert('La fecha de inicio de la campaña no puede ser anterior al primer día del mes en curso.');
                    return false;
                }
                return true;
            }

            function limpiar() {
                $('#select-empresa option').removeAttr('selected');
                $('#select-producto option').removeAttr('selected');
                $('#select-tipo-campana option').removeAttr('selected');
                $('#select-empresa').val('0');
                $('#select-tipo-campana').val('0');
                $('#select-producto').html('');
                $('#cuerpo-tab-subproducto').html('');
                $('#desde').val('');
                $('#hasta').val('');
                $('#meta').val('');
                $('#codcampana').val('');
                $('#nomcampana').val('');
            }

            function checkCampos(check) {
                var fila = $(check).parent().parent();
                if (check.checked) {
                    $($(fila).children()[2]).children(0).removeClass("oculto");
                    $($(fila).children()[3]).children(0).removeClass("oculto");
                } else {
                    $($(fila).children()[2]).children(0).addClass("oculto");
                    $($(fila).children()[3]).children(0).addClass("oculto");
                }
            }

            function del(idcampana) {
                if (confirm("Está seguro que desea eliminar la campaña seleccionada?")) {
                    var detalle = {
                        url: 'CampanaController',
                        datos: {
                            tipo: 'del-campana',
                            idcampana: idcampana
                        }
                    };
                    eliminar(detalle, function (obj) {
                        traerCampanas();
                    });
                }

            }

            function verSubs(idcampana) {
                var detalle = {
                    url: 'CampanaController',
                    bodyDestino: 'cuerpo-detalle-subproducto',
                    datos: {
                        tipo: 'detalle-subproducto',
                        idcampana: idcampana
                    }
                };
                traerListado(detalle);
                $('#modal-detalle').modal();
                var filas = $('#tabla-detalle-subproductos tbody tr');
                for (var i = 0; i < filas.length; i++) {
                    console.log($(this));
                }
            }

            function setFechaHasta() {
                var fechaDesde = new Date($('#desde').val());
                fechaDesde.setDate(fechaDesde.getDate() + 1);
                var hastaString = formatFecha(fechaDesde);

                $('#hasta').val(hastaString);
            }
        </script>

        <!-- Modal detalle -->
        <div class="modal fade" id="modal-detalle">
            <div class="modal-dialog">
                <div class="modal-content">

                    <!-- Modal Header -->
                    <div class="modal-header">
                        <h4 class="modal-title">Detalle Subproductos:</h4>
                        <button type="button" class="close" data-dismiss="modal">&times;</button>
                    </div>

                    <!-- Modal body -->
                    <div class="modal-body">
                        <div class="row">
                            <div class="col-sm-12">
                                <h5>Subproductos empresa</h5>
                                <br />
                                <table id='tab-detalle-subproductos' class="table table-sm small table-striped table-borderless">
                                    <thead>
                                        <tr>
                                            <!--td>Código</td-->
                                            <td>Subproducto</td>
                                            <td>Prima</td>
                                            <td>Monto Meta</td>
                                            <td>Cant. Meta</td>
                                        </tr>
                                    </thead>
                                    <tbody id='cuerpo-detalle-subproducto'>

                                    </tbody>
                                </table>
                            </div>
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
                    <h2>Campañas</h2>
                </div>
            </div>
            <div class="row">
                <div class="col-sm-4">
                    <form>
                        <div class="form-group small">
                            <label for="select-tipo-campana">Tipo Campaña</label>
                            <select onchange="changeTipoCampana();" class="form-control form-control-sm" id="select-tipo-campana">
                            </select>
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
                            <label for="codcampana">Código</label>
                            <input id="codcampana" type="text" maxlength="50" class="form-control form-control-sm" />
                        </div>
                        <div class="form-group small">
                            <label for="nomcampana">Nombre</label>
                            <input id="nomcampana" type="text" maxlength="100" class="form-control form-control-sm" />
                        </div>


                        <div class="form-group small">
                            <div class="form-row">
                                <div class="col">
                                    <label for="desde">Desde</label>
                                    <input onblur="setFechaHasta();" onchange="setFechaHasta();" id="desde" type="date" class="form-control form-control-sm" />
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
                </div>
                <div class="col-sm-8">
                    <h3>Subproductos Empresa Seleccionada</h3>
                    <table id="tabla-subproductos" class="table table-sm small table-borderless table-hover table-striped">
                        <thead>
                            <tr>
                                <!--th>Código</th-->
                                <th>Subproducto</th>
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
                <br />
                <h3>Campañas registradas</h3>
                <div class="col-sm-12">
                    <table id="tabla-campanas" class="table table-sm small table-borderless table-hover table-striped">
                        <thead>
                            <tr>
                                <th>Rut</th>
                                <th>Empresa</th>
                                <th>Tipo</th>
                                <th>Código</th>
                                <th>Nombre</th>
                                <th>Producto</th>
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
