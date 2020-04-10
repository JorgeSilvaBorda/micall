<%@include file="headjava.jsp" %>
<%    String nombres = (String) session.getAttribute("nombre") + " " + (String) session.getAttribute("appaterno");
    //int codTipoUsuario = Integer.parseInt(session.getAttribute("codtipousuario").toString());
    String MENU_ADMINISTRADOR = "<ul class='navbar-nav mr-auto'><!--li class='nav-item active'><a class='nav-link' href='#'>Inicio <span class='sr-only'>(current)</span></a></li--><li onclick='cambiar(this, \"empresa\");' class='nav-item'><a class='nav-link' href='#'>Empresas <span class='sr-only'>(current)</span></a></li><li onclick='cambiar(this, \"producto\");' class='nav-item'><a class='nav-link' href='#'>Productos <span class='sr-only'>(current)</span></a></li><li onclick='cambiar(this, \"subproducto\");' class='nav-item'><a class='nav-link' href='#'>Subproductos <span class='sr-only'>(current)</span></a></li><li onclick='cambiar(this, \"campana\");' class='nav-item'><a class='nav-link' href='#'>Campañas <span class='sr-only'>(current)</span></a></li><li onclick='cambiar(this, \"usuario\");' class='nav-item'><a class='nav-link' href='#'>Usuarios <span class='sr-only'>(current)</span></a></li></ul>";
    String MENU_VENDEDOR = "<ul class='navbar-nav mr-auto'><li onclick='cambiar(this, \"ventas\");' class='nav-item'><a class='nav-link' href='#'>Ventas <span class='sr-only'>(current)</span></a></li></ul>";
    String MENU_EMPRESA = "<ul class='navbar-nav mr-auto'><li onclick='cambiar(this, \"panel-estrategico\");' class='nav-item'><a class='nav-link' href='#'>Panel Estratégico <span class='sr-only'>(current)</span></a></li><li onclick='cambiar(this, \"panel-operativo\");' class='nav-item'><a class='nav-link' href='#'>Panel Operativo <span class='sr-only'>(current)</span></a></li><li onclick='cambiar(this, \"rutero\");' class='nav-item'><a class='nav-link' href='#'>Carga Rutero <span class='sr-only'>(current)</span></a></li></ul>";
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<script type="text/javascript">
    
    $(document).ready(function(){
        OPCIONES_FIXED.headerOffset = $('#navbar').outerHeight();
    });
    
    function cerrar() {
        window.location.href = "login.jsp";
    }

    function cambiar(li, nombre) {
        $('li').removeClass('active');
        $(li).addClass('active');
        $('#contenedor').load(nombre + '.jsp');
    }
    
    function mostrar(nombre){
        $('#contenedor').load(nombre + '.jsp');
    }
</script>
<div class="container-fluid">
    <div class="row">
        <div class="col-sm-12">
            <nav id="navbar" class="navbar small navbar-expand-sm navbar-light bg-light fixed-top"><img src='img/logo.png' height="60" width='62' />
                <a class="navbar-brand" href="#">&nbsp;&nbsp;&nbsp;&nbsp;<% if(session.getAttribute("idtipousuario").toString().equals("3")){out.print("MiCall");}else{out.print(session.getAttribute("empresa"));} %></a>
                <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#contenidoNavbar" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
                    <span class="navbar-toggler-icon"></span>
                </button>

                <div class="collapse navbar-collapse" id="contenidoNavbar">
                    <%
                        switch (Integer.parseInt(session.getAttribute("idtipousuario").toString())) {
                            case 1:
                                out.print(MENU_ADMINISTRADOR);
                                break;
                            case 2:
                                out.print(MENU_EMPRESA);
                                //out.print(MENU_EMPRESA_BETA);
                                break;
                            case 3:
                                out.print(MENU_VENDEDOR);
                                break;
                        }
                    %>
                    <ul class="navbar-nav ml-auto">
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <% out.print(nombres);%>
                            </a>
                            <div class="dropdown-menu dropdown-menu-right small" aria-labelledby="navbarDropdown">
                                <a onclick="mostrar('cambio-pass');" class="dropdown-item small" href="#">Cambiar contraseña</a>
                                <!--a class="dropdown-item" href="#">Another action</a-->
                                <div class="dropdown-divider"></div>
                                <a class="dropdown-item small" onclick="cerrar();" href="#">Cerrar sesión</a>
                            </div>
                        </li>
                    </ul>
                </div>
            </nav>
        </div>
    </div>
    <div class="row">
        <div class="container-fluid" id="contenedor"></div>
    </div>
</div>
</body>
</html>
