<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    </head>
    <body>
        <script type="text/javascript">
            $(document).ready(function () {
                cambiarTab($('#tab-resumen'), 'resumen-empresa');
            });
            function cambiarTab(tab, nombre) {
                $('li.nav-item a.nav-link').removeClass('active');
                var a = $(tab).children('a');
                $(a).addClass('active');
                $('#contenido-panel-empresa').html('');
                $('#contenido-panel-empresa').load(nombre + '.jsp');
            }
        </script>
        <div class="container-fluid">
            <br />
            <br />
            <br />
            <div class="row">
                <div class="col-sm-12">
                    <h2>Estado Ventas</h2>
                </div>
            </div>
            <div class="row">
                <div class="col-sm-12">
                    <ul class="nav nav-tabs">
                        <li id="tab-resumen" onclick="cambiarTab(this, 'resumen-empresa');" class="nav-item">
                            <a class="nav-link active" href="#">Resumen Mes</a>
                        </li>
                        <li id="tab-resumen" onclick="cambiarTab(this, 'resumen-empresa-dia');" class="nav-item">
                            <a class="nav-link active" href="#">Resumen Día</a>
                        </li>
                        <li onclick="cambiarTab(this, 'detalle-empresa');" class="nav-item">
                            <a class="nav-link" href="#">Detalle</a>
                        </li>
                    </ul>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12" id="contenido-panel-empresa">

                </div>
            </div>
        </div>
    </body>
</html>
