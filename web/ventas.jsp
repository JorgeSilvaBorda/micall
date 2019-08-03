<%@include file="headjava.jsp" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    </head>
    <body>
	<script type="text/javascript">
            $(document).ready(function(){
                
                cambiarTab($('#tab-resumen'), 'resumen');
            });
	    function cambiarTab(tab, nombre){
		$('li.nav-item a.nav-link').removeClass('active');
		var a = $(tab).children('a');
		$(a).addClass('active');
		$('#contenido-ventas').html('');
		$('#contenido-ventas').load(nombre + '.jsp');
	    }
	</script>
	<div class="container-fluid">
	    <br />
            <br />
            <br />
            <div class="row">
                <div class="col-sm-12">
                    <h2>Ventas</h2>
                </div>
            </div>
	    <div class="row">
		<div class="col-sm-12">
		    <ul class="nav nav-tabs">
			<li id="tab-resumen" onclick="cambiarTab(this, 'resumen');" class="nav-item">
			    <a class="nav-link active" href="#">Actual</a>
			</li>
			<li onclick="cambiarTab(this, 'detalle');" class="nav-item">
			    <a class="nav-link" href="#">Detalle</a>
			</li>
			<li onclick="cambiarTab(this, 'simulacion');" class="nav-item">
			    <a class="nav-link" href="#">Simulación Manual</a>
			</li>
		    </ul>
		</div>
	    </div>
	    <div class="row">
		<div class="col-lg-12" id="contenido-ventas">

		</div>
	    </div>
	</div>
    </body>
</html>
