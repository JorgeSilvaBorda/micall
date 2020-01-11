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
                //cambiarTab($('#tab-resumen-venta-mes'), 'resumen-empresa-venta');
            });
            
            function cambiarTab(tab, nombre) {
                $('li.nav-item a.nav-link').removeClass('active');
                var a = $(tab).children('a');
                $(a).addClass('active');
                $('#contenido-panel-operativo').html('');
                $('#contenido-panel-operativo').load('panel-operativo/' + nombre + '.jsp');
            }
        </script>
        <div class="container-fluid">
            <br />
            <br />
            <br />
            <div class="row">
                <div class="col-sm-12">
                    <h2>Panel Operativo</h2>
                </div>
            </div>
            <div class="row">
                <div class="col-sm-12">
                    <ul class="nav nav-tabs">                        
                        <li id="bbdd" onclick="cambiarTab(this, 'bbdd');" class="nav-item">
                            <a class="nav-link" href="#">BBDD</a>
                        </li>

                        <li id="ejecutivos" onclick="cambiarTab(this, 'ejecutivos');" class="nav-item">
                            <a class="nav-link" href="#">Ejecutivos</a>
                        </li>
                        <li id="resultante" onclick="cambiarTab(this, 'resultante');" class="nav-item">
                            <a class="nav-link" href="#">Resultante</a>
                        </li>
                        <li id="grabaciones" onclick="cambiarTab(this, 'grabaciones');" class="nav-item">
                            <a class="nav-link" href="#">Grabaciones</a>
                        </li>
                    </ul>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12" id="contenido-panel-operativo">

                </div>
            </div>
        </div>
    </body>
</html>
