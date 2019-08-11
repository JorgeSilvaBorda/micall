<%@include file="headjava.jsp" %>
<script type="text/javascript">

    function buscar() {
        if (validarCampos()) {
            var desde = $('#desde').val();
            var hasta = $('#hasta').val();
            var rutfullvendedor = '<% out.print(session.getAttribute("rutusuario") + "-" + session.getAttribute("dvusuario"));%>';
            rutfullvendedor = rutfullvendedor.replaceAll("-", "");

            var datos = {
                tipo: 'tabla-detalle-ventas-vendedor',
                desde: desde,
                hasta: hasta,
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
                        $('#cuerpo-tab-detalle').html(armarTabla(obj.ventas));
                        $('#tabla-detalle').DataTable(OPCIONES_DATATABLES);
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

    function validarCampos() {
        var desde = $('#desde').val();
        var hasta = $('#hasta').val();
        if (desde.length < 8 || hasta.length < 8) {
            alert("Debe ingresar ambas fechas del rango de búsqueda");
            return false;
        }
        if(diffFechas(desde, hasta) < 0){
            alert("La fecha de inicio no puede ser superior a la de término de la búsqueda.");
            return false;
        }
        return true;
    }

    function armarTabla(arr) {
        var tab = "";
        $.each(arr, function () {
            tab += "<tr>";
            tab += "<td>" + $(this)[0].fechasimulacion + "</td>";
            tab += "<td>" + $.formatRut($(this)[0].rutfullcliente) + "</td>";
            tab += "<td>[" + $(this)[0].codcampana + "] " + $(this)[0].nomcampana + "</td>";
            tab += "<td>[" + $(this)[0].codproducto + "] " + $(this)[0].descproducto + "</td>";
            tab += "<td>$" + formatMiles($(this)[0].monto) + "</td>";
            tab += "<td>" + $(this)[0].cuotas + "</td>";
            tab += "<td>" + $(this)[0].empresa + "</td>";
            tab += "</tr>";
        });
        return tab;
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
                        <button onclick="buscar();" id="btnBuscar" type="button" class="btn btn-success btn-sm">Buscar</button>
                    </div>
                </div>
            </div>
        </form>
    </div>
</div>
<div class="row">
    <div class="col-sm-12">
        <table id="tabla-detalle" class="table table-sm small table-borderless table-hover table-striped">
            <thead>
                <tr>
                    <th>Fecha</th>
                    <th>Rut Cliente</th>
                    <th>Campaña</th>
                    <th>Producto</th>                    
                    <th>Monto</th>
                    <th>Cuotas</th>
                    <th>Empresa</th>
                </tr>
            </thead>
            <tbody id="cuerpo-tab-detalle"></tbody>
        </table>
    </div> 
</div>