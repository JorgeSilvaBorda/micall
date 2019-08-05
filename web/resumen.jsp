<%@include file="headjava.jsp" %>
<script type="text/javascript">
    $('#document').ready(function () {
        cargarTabla();
    });

    function cargarTabla() {
        var rutfullvendedor = '<% out.print(session.getAttribute("rutusuario") + "-" + session.getAttribute("dvusuario"));%>';
        rutfullvendedor = rutfullvendedor.replaceAll("-", "");
        var datos = {
            tipo: 'carga-tab-resumen-vendedor',
            rutfullvendedor: rutfullvendedor
        };
        $.ajax({
            url: 'ReportesController',
            type: 'post',
            cache: false,
            data: {
                datos: JSON.stringify(datos)
            },
            success: function (res) {
                var obj = JSON.parse(res);
                if (obj.estado === 'ok') {
                    $('.dataTable').DataTable().destroy();
                    $('#cuerpo-tab-resumen').html(armarTabla(obj.registros));
                    $('#tabla-resumen').DataTable(OPCIONES_DATATABLES);
                }
            },
            error: function (a, b, c) {
                console.log(a);
                console.log(b);
                console.log(b);
            }
        });
    }

    function armarTabla(arr) {
        var tab = "";
        $.each(arr, function () {
            tab += "<tr>";
            tab += "<td>" + $(this)[0].codproducto + "</td>";
            tab += "<td>" + $(this)[0].descproducto + "</td>";
            tab += "<td>" + $(this)[0].codcampana + "</td>";
            tab += "<td>" + $(this)[0].nomcampana + "</td>";
            tab += "<td>$" + formatMiles($(this)[0].meta) + "</td>";
            tab += "<td>$" + formatMiles($(this)[0].montoacum) + "</td>";
            tab += "<td>" + $(this)[0].porcacum + "%</td>";
            tab += "</tr>";
        });
        return tab;
    }

</script>
<br />
<div class="row">
    <div class="col-sm-12">
        <table id="tabla-resumen" class="table table-sm small table-borderless table-hover table-striped">
            <thead>
                <tr>
                    <th>Cod. Producto</th>
                    <th>Producto</th>
                    <th>Cod. campaña</th>
                    <th>campaña</th>
                    <th>Meta</th>
                    <th>Acum. Mes</th>
                    <th>% Acum. Mes</th>
                </tr>
            </thead>
            <tbody id="cuerpo-tab-resumen">
                
            </tbody>
        </table>
    </div>
</div>