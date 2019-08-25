<%@include file="headjava.jsp" %>
<script type="text/javascript">
    $(document).ready(function () {
        cargarResumen();
        OPCIONES_DATATABLES.buttons[0] = {title: "", extend: "excelHtml5"};
        OPCIONES_DATATABLES.buttons[0].title = "MiCall-Res-Mes-" + "<% out.print(session.getAttribute("empresa")); %>" + "-" + formatFecha(new Date());
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
            tab += "<td style='width: 38px;' >" + $(this)[0].fechafin + "</td>";
            tab += "<td>[" + $(this)[0].codcampana + "] " + $(this)[0].nomcampana + "</td>";
            tab += "<td>[" + $(this)[0].codproducto + "] " + $(this)[0].descproducto + "</td>";
            tab += "<td>$" + formatMiles($(this)[0].metaproducto) + "</td>";
            var acumprod = parseInt($(this)[0].acumproducto.replaceAll("\\.", ""));
            var metaprod = parseInt($(this)[0].metaproducto.replaceAll("\\.", ""));
            tab += "<td "  + ((acumprod < metaprod && acumprod > 0) ? "style='color: red;'" : "") + " >$" + formatMiles($(this)[0].acumproducto) + "</td>";
            tab += "<td>" + $(this)[0].porcacumprod + "%</td>";
            tab += "<td>" + $(this)[0].simulaciones + "</td>";
            tab += "<td>[" + $(this)[0].codsubproducto + "] " + $(this)[0].descsubproducto + "</td>";
            tab += "<td>$" + formatMiles($(this)[0].metasubproducto) + "</td>";
            var estiloRojo = "";
            var metaSub = parseInt($(this)[0].metasubproducto.replaceAll("\\.", ""));
            var acumSub = parseInt($(this)[0].acumsubproducto.replaceAll("\\.", ""));
            
            if(acumSub > 0 && acumSub < metaSub){
                estiloRojo = "style='color: red;'";
            }
            
            
            tab += "<td " + estiloRojo + " >$" + formatMiles($(this)[0].acumsubproducto) + "</td>";
            tab += "<td>" + $(this)[0].porcacumsubprod + "%</td>";
            tab += "<td>" + formatMiles($(this)[0].cantidadmeta) + "</td>";
            tab += "<td>" + formatMiles($(this)[0].cantidadmes) + "</td>";
            //tab += "<td>" + $(this)[0].prima + "%</td>";
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
    <div class="col-sm-4">
        <h3>Productos / Subproductos</h3>
    </div>
</div>
<div class="row">
    <div class="col-sm-12">
        <table id="tabla-resumen-empresa" style="font-size: 10px; border-collapse: collapse; border: 1px;" class="table table-sm small table-bordered table-hover table-striped">
            <thead>
                <tr>
                    <th colspan="3">Campaña</th>
                    <th colspan="5">Productos</th>
                    <th colspan="6">Subproductos</th>
                </tr>
                <tr>
                    <th>Fecha Inicio</th>
                    <th style="width: 38px;">Fecha Fin</th>
                    <th>Nombre</th>
                    <th>Nombre</th>
                    <th>$<br />Meta</th>
                    <th>$<br />Acum.</th>
                    <th>%$<br />Cump.</th>
                    <th>#<br/>Acum.</th>
                    <th>Nombre</th>
                    <th>$<br />Meta.</th>
                    <th>$<br />Acum.</th>
                    <th>%$<br />Cump.</th>
                    <th>#<br/>Meta</th>
                    <th>#<br />Acum.</th>
                    <!--th>Prima Subprod.</th-->
                </tr>
            </thead>
            <tbody id="cuerpo-tab-resumen-empresa">

            </tbody>
        </table>
    </div>
</div>
