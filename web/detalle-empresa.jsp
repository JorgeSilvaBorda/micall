<%@include file="headjava.jsp" %>
<script type="text/javascript">
    $(document).ready(function () {
        //cargarDetalle();
        var buttonCommon = {
            exportOptions: {
                format: {
                    body: function (data, row, column, node) {
                        //return column === 7 ? formatExcelColCuota(data) : data;
                        return formatCol(column, data);
                    }
                }
            }
        };
        var OPCIONES_EXCEL = [
            $.extend(true, {}, buttonCommon, {
                extend: 'excelHtml5',
                title: "MiCall-Det-" + "<% out.print(session.getAttribute("empresa")); %>" + "-" + formatFecha(new Date())
            })
                    /*
                     {
                     extend: 'excelHtml5',
                     title: "MiCall-Det-" + "<% out.print(session.getAttribute("empresa")); %>" + "-" + formatFecha(new Date())
                     }
                     */
        ];
        OPCIONES_DATATABLES.buttons = OPCIONES_EXCEL;
    });
    // Funciones para manejo de campos excel ---------------------------------------------------------
    function formatColCuota(dato) {
        console.log("Entra: " + dato);
        dato = dato.replaceAll("\\.", "");
        dato = dato.replaceAll("\\$", "");
        dato = dato.replaceAll(" ", "");
        dato = dato.replaceAll("\$", "");
        dato = dato.split("$")[1];
        dato = dato.toString().trim();
        return "$ " + formatMiles(dato);
    }
    
    function formatColMonto(dato) {
        dato = dato.replaceAll("\\.", "");
        dato = dato.replaceAll("\\$", "");
        dato = dato.replaceAll(" ", "");
        dato = dato.replaceAll("\$", "");
        dato = dato.split("$")[1];
        dato = dato.toString().trim();
        return "$ " + formatMiles(dato);
    }
    
    function limpiaCampoSubs(dato){
        var span = $('<span></span>');
        $(span).html(dato);
        $(span).children().remove();
        return $(span).text().trim();
    }

    function formatCol(num, dato) {
        switch (num) {
            case 0:
                return dato;
                break;
            case 1:
                return dato;
                break;
            case 2:
                return dato;
                break;
            case 3:
                return dato;
                break;
            case 4:
                return dato;
                break;
            case 5:
                return formatColMonto(dato);
                break;
            case 6:
                return dato;
                break;
            case 7:
                return formatColCuota(dato);
                break;
            case 8:
                return limpiaCampoSubs(dato);
                break;
            default:
                break;
        }
    }

    // /Funciones para manejo de campos excel ---------------------------------------------------------
    function cargarDetalle() {
        if (validarCampos()) {
            var datos = {
                tipo: 'tabla-detalle-ventas-empresa',
                rutusuario: '<% out.print(session.getAttribute("rutusuario"));%>',
                desde: $('#desde').val(),
                hasta: $('#hasta').val()
            };
            $.ajax({
                type: 'post',
                url: 'ReportesController',
                data: {
                    datos: JSON.stringify(datos)
                },
                cache: false,
                success: function (res) {
                    var obj = JSON.parse(res);
                    if (obj.estado === 'ok') {
                        $('.dataTable').DataTable().destroy();
                        $('#cuerpo-tab-detalle-empresa').html(armarTabla(obj.ventas));
                        $('#tabla-detalle-empresa').DataTable(OPCIONES_DATATABLES);
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

    function armarTabla(arr) {
        var tab = "";
        $.each(arr, function () {
            tab += "<tr>";
            tab += "<td>" + $(this)[0].fechasimulacion + "</td>";
            //tab += "<td>" + $(this)[0].codcampana + "</td>";
            tab += "<td>[" + $(this)[0].codcampana + "] " + $(this)[0].nomcampana + "</td>";
            //tab += "<td>" + $(this)[0].codproducto + "</td>";
            tab += "<td>[" + $(this)[0].codproducto + "] " + $(this)[0].descproducto + "</td>";
            //tab += "<td>$" + formatMiles($(this)[0].meta) + "</td>";
            tab += "<td>" + $.formatRut($(this)[0].rutfullvendedor) + "</td>";
            tab += "<td>" + $.formatRut($(this)[0].rutfullcliente) + "</td>";
            tab += "<td>$" + formatMiles($(this)[0].monto) + "</td>";


            tab += "<td>" + $(this)[0].cuotas + "</td>";
            tab += "<td>$" + formatMiles($(this)[0].valorcuota) + "</td>";
            var tdSubs = "<td>" + $(this)[0].subproductos + "</td>";
            if (parseInt($(this)[0].subproductos) > 0) {
                tdSubs = "<td>" + $(this)[0].subproductos + " <a href='#' onclick='verSubproductosVendidos(" + $(this)[0].idsimulacion + ");'>Detalle</a></td>";
            }
            tab += tdSubs;
            tab += "</tr>";
        });
        return tab;
    }

    function verSubproductosVendidos(idsimulacion) {
        var datos = {
            tipo: 'get-subproductos-simulacion',
            idsimulacion: idsimulacion
        };

        $.ajax({
            type: 'post',
            url: 'SimulacionController',
            data: {
                datos: JSON.stringify(datos)
            },
            success: function (resp) {
                var obj = JSON.parse(resp);
                console.log(obj);
                if (obj.estado === 'ok') {
                    //pintar popup
                    $('#cuerpo-modal-subproductos').html(armarTablaSubproductos(obj.subproductos));
                    $('#modal-subproductos').modal();
                }
            }
        });
    }

    function armarTablaSubproductos(subproductos) {
        var tab = "<table id='tab-subproductos' class='table-sm small' style='border: none; border-collapse: collapse;'><thead>";
        tab += "<tr>";
        tab += "<th>Subproducto</th>";
        tab += "<th>Prima</th>";
        //tab += "<th>Meta Monto</th>";
        //tab += "<th>Meta Cantidad</th>";
        tab += "</tr></thead><tbody>";
        $(subproductos).each(function () {
            tab += "<tr>";
            tab += "<td>[" + $(this)[0].codsubproducto + "] " + $(this)[0].descsubproducto + "</td>";
            tab += "<td>" + $(this)[0].prima + "</td>";
            //tab += "<td>$" + formatMiles($(this)[0].montometa) + "</td>";
            //tab += "<td>" + formatMiles($(this)[0].cantidadmeta) + "</td>";
            tab += "</tr>";
        });
        tab += "</tbody></table>";
        return tab;
    }

    function validarCampos() {
        var desde = $('#desde').val();
        var hasta = $('#hasta').val();
        if (desde.length < 8 || hasta.length < 8) {
            alert('Debe ingresar la fecha desde y hasta para la búsqueda.');
            return false;
        }
        return true;
    }
</script>
<br />
<div class="modal fade" id="modal-subproductos">
    <div class="modal-dialog">
        <div class="modal-content">

            <!-- Modal Header -->
            <div class="modal-header">
                <h4 class="modal-title">Subproductos</h4>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>

            <!-- Modal body -->
            <div class="modal-body" id='cuerpo-modal-subproductos'>

            </div>

            <!-- Modal footer -->
            <div class="modal-footer">
                <button type="button" id='btnCerrarModal' class="btn btn-secondary btn-sm" data-dismiss="modal">Cerrar</button>
            </div>

        </div>
    </div>
</div>
<div class="row">
    <div class="col-sm-5">
        <form>
            <div class="row">
                <div class="col small">
                    <div class="form-group small">
                        <label for="desde">Desde</label>
                        <input type="date" id="desde" class="form-control form-control-sm"/> 
                    </div>
                </div>
                <div class="col small">
                    <div class="form-group small">
                        <label for="hasta">Hasta</label>
                        <input type="date" id="hasta" class="form-control form-control-sm"/> 
                    </div>
                </div>
                <div class="col small">
                    <div class="form-group small">
                        <br />
                        <label for="btnBuscar">&nbsp;</label>
                        <button onclick="cargarDetalle();" id="btnBuscar" type="button" class="btn btn-success btn-sm">Buscar</button>
                    </div>
                </div>
            </div>
        </form>
    </div>
</div>
<div class="row">
    <div class="col-sm-12">
        <table id="tabla-detalle-empresa" class="table table-sm small table-borderless table-hover table-striped">
            <thead>
                <tr>
                    <th>Fecha</th>
                    <!--th>Cod. Campaña</th-->
                    <th>Campaña</th>
                    <!--th>Cod. Producto</th-->
                    <th>Producto</th>
                    <!--th>Meta</th-->
                    <th>Rut Vendedor</th>
                    <th>Rut Cliente</th>
                    <th>Monto</th>


                    <th>Cuotas</th>
                    <th>Valor Cuota</th>
                    <th>Subproductos</th>
                </tr>
            </thead>
            <tbody id="cuerpo-tab-detalle-empresa">

            </tbody>
        </table>
    </div>
</div>
