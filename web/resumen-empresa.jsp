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
        $.each(arr, function () {
            tab += "<tr>";
            tab += "<td>" + $(this)[0].fechaini + "</td>";
            tab += "<td>" + $(this)[0].fechafin + "</td>";
            tab += "<td>[" + $(this)[0].codcampana + "] " + $(this)[0].nomcampana + "</td>";
            tab += "<td>[" + $(this)[0].codproducto + "] " + $(this)[0].descproducto + "</td>";
            tab += "<td>$" + formatMiles($(this)[0].metaproducto) + "</td>";
            tab += "<td>$" + formatMiles($(this)[0].acumproducto) + "</td>";
            tab += "<td>" + $(this)[0].porcacumprod + "%</td>";
            tab += "<td>" + $(this)[0].simulaciones + "</td>";
            tab += "<td>[" + $(this)[0].codsubproducto + "] " + $(this)[0].descsubproducto + "</td>";
            tab += "<td>$" + formatMiles($(this)[0].metasubproducto) + "</td>";
            tab += "<td>$" + formatMiles($(this)[0].acumsubproducto) + "</td>";
            tab += "<td>" + $(this)[0].porcacumsubprod + "%</td>";
            tab += "<td>" + formatMiles($(this)[0].cantidadmeta) + "</td>";
            tab += "<td>" + formatMiles($(this)[0].cantidadmes) + "</td>";
            tab += "<td>" + $(this)[0].prima + "%</td>";
            tab += "</tr>";
        });
        return tab;
    }

    /*
     function pintarResumen(ventasDia, ventasMes) {
        $('#totalDia').html("$" + formatMiles(ventasDia));
        $('#totalMes').html("$" + formatMiles(ventasMes));
     }
     */
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
                    <th>Producto</th>
                    <th>$ Meta Prod.</th>
                    <th>$ Acumulado<br />Mes Prod.</th>
                    <th>% Cumplimiento<br />Meta Mes Prod.</th>
                    <th>Cant.<br />Simulaciones</th>
                    <th>Subproducto</th>
                    <th>$ Meta Subprod.</th>
                    <th>$ Acumulado<br />Mes Subprod.</th>
                    <th>% Cumplimiento<br />Meta Mes Subrod.</th>
                    <th>Cant. Meta<br />Subprod.</th>
                    <th>Cumplimiento. Meta<br />Cant. Subprod.</th>
                    <th>Prima Subprod.</th>
                </tr>
            </thead>
            <tbody id="cuerpo-tab-resumen-empresa">

            </tbody>
        </table>
    </div>
</div>
