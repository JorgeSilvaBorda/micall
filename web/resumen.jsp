<%@include file="headjava.jsp" %>
<script type="text/javascript">
    $('#document').ready(function () {
        OPCIONES_DATATABLES.buttons = [];
        cargarTabla();
    });

    function cargarTabla() {
        var rutfullvendedor = '<% out.print(session.getAttribute("rutusuario") + "-" + session.getAttribute("dvusuario"));%>';
        rutfullvendedor = rutfullvendedor.replaceAll("-", "");
        var datos = {
            tipo: 'carga-tab-resumen-ventas-vendedor',
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
                var OPTS_DT = {
                    "language": {
                        "lengthMenu": "Mostrar _MENU_ registros por página",
                        "zeroRecords": "Sin ventas",
                        "info": "Mostrando página _PAGE_ de _PAGES_",
                        "infoEmpty": "Sin ventas",
                        "infoFiltered": "(filtered from _MAX_ total records)",
                        "paginate": {
                            "previous": "Anterior",
                            "next": "Siguiente"
                        },
                        "search": "Buscar"
                    },
                    "paging": true,
                    "ordering": true,
                    "drawCallback": function () {
                        $('.dataTables_paginate > .pagination').addClass('pagination-sm');
                    }
                };
                var obj = JSON.parse(res);
                if (obj.estado === 'ok') {
                    $('.dataTable').DataTable().destroy();
                    $('#cuerpo-tab-resumen').html(armarTabla(obj.registros));
                    $('#tabla-resumen').DataTable(OPTS_DT);
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
            tab += "<td>" + $(this)[0].nomempresa + "</td>";
            tab += "<td>[" + $(this)[0].codcampana + "] " + $(this)[0].nomcampana + "</td>";
            tab += "<td>[" + $(this)[0].codproducto + "] " + $(this)[0].descproducto + "</td>";
            tab += "<td>$" + formatMiles($(this)[0].montoacum) + "</td>";
            tab += "<td>" + $(this)[0].cantidad + "</td>";
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
                    <!--th>Cod. Producto</th-->

                    <th>Empresa</th>
                    <th>Campaña</th>
                    <th>Producto</th>
                    <!--th>Meta</th-->
                    <th>Acum. Mes</th>
                    <th>Cantidad</th>
                </tr>
            </thead>
            <tbody id="cuerpo-tab-resumen">

            </tbody>
        </table>
    </div>
</div>