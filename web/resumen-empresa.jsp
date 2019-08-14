<%@include file="headjava.jsp" %>
<script type="text/javascript">
    $(document).ready(function () {
        cargarResumen();
    });
    function cargarResumen() {
        var datos = {
            tipo: 'tabla-resumen-ventas-empresa',
            rutusuario: '<% out.print(session.getAttribute("rutusuario"));%>'
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
                    $('#cuerpo-tab-resumen-empresa').html(armarTabla(obj.registros));
                    $('#tabla-resumen-empresa').DataTable(OPCIONES_DATATABLES);
                }
            },
            error: function (a, b, c) {
                console.log(a);
                console.log(b);
                console.log(c);
            }
        });
    }

    function armarTabla(arr) {
        var tab = "";
        var ventasDia = 0;
        var ventasMes = 0;
        $.each(arr, function () {
            tab += "<tr>";
            tab += "<td>" + $(this)[0].fechaini + "</td>";
            tab += "<td>" + $(this)[0].fechafin + "</td>";
            tab += "<td>[" + $(this)[0].codcampana + "] " + $(this)[0].nomcampana + "</td>";
            //tab += "<td>" + $(this)[0].codproducto + "</td>";
            tab += "<td>[" + $(this)[0].codproducto + "] " + $(this)[0].descproducto + "</td>";
            tab += "<td>$" + formatMiles($(this)[0].meta) + "</td>";
            tab += "<td>$" + formatMiles($(this)[0].montoacum) + "</td>";
            tab += "<td>" + $(this)[0].porcacum + "%</td>";
            tab += "<td>" + $(this)[0].cantidad + "</td>";
            tab += "</tr>";
            ventasDia += parseInt($(this)[0].acumdia);
            ventasMes += parseInt($(this)[0].montoacum);
        });
        pintarResumen(ventasDia, ventasMes);
        return tab;
    }

    function pintarResumen(ventasDia, ventasMes) {
        $('#totalDia').html("$" + formatMiles(ventasDia));
        $('#totalMes').html("$" + formatMiles(ventasMes));
    }
</script>
<br />
<div class="row">
    <div class="col-sm-12">
        <table id="tabla-resumen-empresa" class="table table-sm small table-borderless table-hover table-striped">
            <thead>
                <tr>
                    <th>Fecha Inicio</th>
                    <th>Fecha Fin</th>
                    <th>Campaña</th>
                    <!--th>Cod. Producto</th-->
                    <th>Producto</th>
                    <th>Meta</th>
                    <th>Acumulado<br />Mes</th>                         
                    <th>% Cumplimiento<br />Meta Mes</th>
                    <th>TRX Acumuladas<br />Mes</th>
                </tr>
            </thead>
            <tbody id="cuerpo-tab-resumen-empresa">

            </tbody>
        </table>
    </div>
</div>
<div class="row">

    <div class="col-sm-12">
        <br />
        <br />
        <br />
        <h4>Total acumulado</h4>
    </div>
    <div class="col-sm-3">
        <table id="tabla-total-empresa" class="table table-sm small table-borderless table-hover table-striped">
            <thead>
                <tr>
                    <th>Total día</th>
                    <th>Total mes</th>
                </tr>
            </thead>
            <tbody id="cuerpo-tab-total-empresa">
                <tr>
                    <td id="totalDia"></td>
                    <td id="totalMes"></td>
                </tr>
            </tbody>
        </table>
    </div>
</div>
