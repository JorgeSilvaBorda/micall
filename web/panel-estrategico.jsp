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
                cambiarTab($('#tab-resumen-venta-mes'), 'resumen-empresa-venta');
            });
            function cambiarTab(tab, nombre) {
                $('li.nav-item a.nav-link').removeClass('active');
                var a = $(tab).children('a');
                $(a).addClass('active');
                $('#contenido-panel-estrategico').html('');
                $('#contenido-panel-estrategico').load(nombre + '.jsp');
            }
        </script>
        <div class="container-fluid">
            <br />
            <br />
            <br />
            <div class="row">
                <div class="col-sm-12">
                    <h2>Panel Estratégico</h2>
                </div>
            </div>
            <div class="row">
                <div class="col-sm-12">
                    <ul class="nav nav-tabs">
                        
                        <li id="tab-resumen-venta-mes" onclick="cambiarTab(this, 'resumen-empresa-venta');" class="nav-item">
                            <a class="nav-link active" href="#">Resumen Ventas Mes</a>
                        </li>
                        <li id="tab-resumen-venta-dia" onclick="cambiarTab(this, 'resumen-empresa-dia-venta');" class="nav-item">
                            <a class="nav-link" href="#">Resumen Ventas Día</a>
                        </li>
                        <li id="tab-detalle-empresa-venta" onclick="cambiarTab(this, 'detalle-empresa-venta');" class="nav-item">
                            <a class="nav-link" href="#">Detalle Ventas</a>
                        </li>
                        <li onclick="cambiarTab(this, 'detalle-empresa');" class="nav-item">
                            <a class="nav-link" href="#">Detalle Simulaciones</a>
                        </li>
                    </ul>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12" id="contenido-panel-estrategico">

                </div>
            </div>
        </div>
    </body>
</html>
