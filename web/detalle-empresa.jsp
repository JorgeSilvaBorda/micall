<%@include file="headjava.jsp" %>
<script type="text/javascript">
    $(document).ready(function () {
        //cargarDetalle();
    });
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
            tab += "<td>" + $(this)[0].subproductos + "</td>";
            tab += "</tr>";
        });
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
