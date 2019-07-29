<%@include file="headjava.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link href="css/bootstrap.css?=<% out.print(modelo.Util.generaRandom(10000, 99999)); %>" rel="stylesheet" type="text/css"/>
        <link href="css/estilos.css?=<% out.print(modelo.Util.generaRandom(10000, 99999)); %>" rel="stylesheet" type="text/css"/>
        <link href="js/datatables/datatables.css?=<% out.print(modelo.Util.generaRandom(10000, 99999)); %>" rel="stylesheet" type="text/css"/>
        <link href="js/datatables/jquery-ui.css?=<% out.print(modelo.Util.generaRandom(10000, 99999)); %>" rel="stylesheet" type="text/css"/>
        
	<script src="js/jquery-3.4.1.min.js?=<% out.print(modelo.Util.generaRandom(10000, 99999)); %>" type="text/javascript"></script>
        <script src="js/datatables/jquery-ui.js?=<% out.print(modelo.Util.generaRandom(10000, 99999)); %>" type="text/javascript"></script>
        <script src="js/popper.min.js?=<% out.print(modelo.Util.generaRandom(10000, 99999)); %>" type="text/javascript"></script>
        <script src="js/bootstrap.js?=<% out.print(modelo.Util.generaRandom(10000, 99999)); %>" type="text/javascript"></script>
        <script src="js/funciones.js?=<% out.print(modelo.Util.generaRandom(10000, 99999)); %>" type="text/javascript"></script>
        <script src="funciones/modelo.js?=<% out.print(modelo.Util.generaRandom(10000, 99999)); %>" type="text/javascript"></script>
        <script src="funciones/operaciones.js?=<% out.print(modelo.Util.generaRandom(10000, 99999)); %>" type="text/javascript"></script>
        <script src="js/jquery.rut.js?=<% out.print(modelo.Util.generaRandom(10000, 99999)); %>" type="text/javascript"></script>
        <script src="js/datatables/datatables.min.js?=<% out.print(modelo.Util.generaRandom(10000, 99999)); %>" type="text/javascript"></script>
	
        <title>TTS-WebPanel</title>
    </head>
    <body>
        <script type="text/javascript">
	    $(document).ready(function(){
		$('#contenido').load('main.jsp');
	    });
	</script>
        <div class="container-fluid" id="contenido">
            
        </div>
    </body>
</html>
