<%
    session.invalidate();
%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="initial-scale=1">
        <link href="css/bootstrap.css" rel="stylesheet" type="text/css"/>

        <script src="js/jquery-3.4.1.min.js?=<% out.print(modelo.Util.generaRandom(10000, 99999)); %>" type="text/javascript"></script>
        <script src="js/popper.min.js?=<% out.print(modelo.Util.generaRandom(10000, 99999)); %>" type="text/javascript"></script>
        <script src="js/bootstrap.js?=<% out.print(modelo.Util.generaRandom(10000, 99999));%>" type="text/javascript"></script>
        <script src="js/jquery.rut.js" type="text/javascript"></script>
        <script src="js/funciones.js" type="text/javascript"></script>
    </head>
    <body>  
        <script type="text/javascript">
            $(document).ready(function(){

            });
            $(document).on('keyup', function (e) {
                
                if (e.keyCode === 13) {
                    $('#btnLogin').click();
                }
                $('#usuario').rut(
                        {
                            formatOn: 'keyup',
                            validateOn: 'blur'
                        }).on('rutInvalido', function () {
                    mostrarAlert('alert-danger', "El rut ingresado no es válido");
                }).on('rutValido', function () {
                    ocultarAlert();
                });
            });

            function login() {
                if (validarCampos()) {
                    var datos = {
                        tipo: 'login',
                        credenciales: {
                            rutusuario: $('#usuario').val().split("-")[0].replaceAll("\\.", ""),
                            password: $('#password').val()
                        }
                    };
                    $.ajax({
                        url: 'UsuarioController',
                        data: {
                            datos: JSON.stringify(datos)
                        },
                        cache: false,
                        type: 'post',
                        success: function (res) {
                            var obj = JSON.parse(res);
                            if (obj.estado === 'no-valido') {
                                alert(obj.mensaje);
                            }
                            window.location.href = "index.jsp";
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
                if ($('#usuario').val().length < 2 || $('#password').val().length < 2) {
                    alert("Debe ingresar ambos campos.");
                    return false;
                }
                return true;
            }

            function mostrarAlert(clase, mensaje) {
                $('#alerta').addClass(clase);
                $('#alerta').html('<strong>Error!</strong> <span>' + mensaje + '</span>');
                $('#mensaje-alerta').html(mensaje);
                $('#alerta').fadeIn(500);
                $('#alerta').removeClass('oculto');
            }

            function ocultarAlert() {
                $('#alerta').fadeOut(500);
                $('#alerta').html('');
            }

        </script>
        <div class="container-fluid">
            <div class="row">
                <div class="col-sm-12">
                    <br />
                    <br />
                    <br />
                </div>
            </div>
            <div class="row">
                <div style="background-image:url('./img/logo.png'); background-size: 220px 200px; background-repeat: no-repeat; background-position: center;" class="col-sm-4">
                    
                </div>
                <div class="col-sm-4">
                    <h2>Login usuario</h2>
                    <form  >
                        <div class="form-group">
                            <label for="usuario">Usuario</label>
                            <input type="text" class="form-control small" id="usuario" name="usuario" />
                        </div>
                        <div class="form-group">
                            <label for="password">Password</label>
                            <input type="password" class="form-control small" id="password" />
                        </div>
                        <div class="form-group">
                            <button id="btnLogin" type="button" onclick="login();" class="btn btn-primary">Ingresar</button>
                        </div>
                    </form>
                </div>

                <div class="col-sm-4"></div>
            </div>
            <div class="row">
                <div class="col-sm-4"></div>
                <div class="col-sm-4">
                    <div id="alerta" class="alert oculto">

                    </div>
                </div>
                <div class="col-sm-4"></div>
            </div>
        </div>
    </body>
</html>
