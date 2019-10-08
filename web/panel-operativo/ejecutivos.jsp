<%@include file="../headjava.jsp" %>
<script type="text/javascript" src="panel-operativo/ejecutivos.js?=<% out.print(modelo.Util.generaRandom(10000, 99999)); %>" ></script>
<br />
<div class="row">
    <div class="col-sm-4">
        <h3>Ejecutivos</h3>
    </div>
</div>

<div class="row">
    <div class="form-group-small">
        <label for="select-campana" >Campaña</label>
        <select onchange="traeDatosCampana();" id="select-campana" class="form-control-sm">
            
        </select>
    </div>
</div>
<br />
<div class="row">
    <div class="col-sm-9">
        <form>
            <div class="row">
                <div class="col-sm-3">
                    <div class="form-group small">
                        <label for="desde">Fecha Inicio</label> 
                    </div>
                </div>
                <div class="col-sm-3">
                    <div class="form-group small">
                        <label for="hasta">Fecha Fin</label> 
                    </div>
                </div>
                <div class="col-sm-2">
                    <div class="form-group small">
                        <label for="btnBuscar"></label> 
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-sm-3">
                    <div class="form-group small">
                        <input disabled="disabled" type="date" id="desde" class="form-control form-control-sm"/> 
                    </div>
                </div>
                <div class="col-sm-3">
                    <input disabled="disabled" type="date" id="hasta" class="form-control form-control-sm"/> 
                </div>
                <div class="col-sm-2">
                    <div class="form-group small">
                        <button onclick="buscar();" id="btnBuscar" type="button" class="btn btn-success btn-sm">Buscar</button>
                    </div>
                </div>
            </div>
        </form>
    </div>
    
</div>
<div class="row">
    <div class="col-sm-12">
        <table id="tabla-ejecutivos" class="table" style="font-size: 10px;" >
            <thead>
                <tr>
                    <th>Nombres</th>
                    <th>Rut</th>
                    <th>Ventas</th>
                    <th>#<br />Llamadas</th>
                    <th>Hra 1ª<br />Conexión</th>
                    <th>Tmo<br/>Logeado</th>
                    <th>Tmo<br/>Espera</th>
                    <th>% Tmo<br />Espera</th>
                    <th>Tmo<br />Llamada</th>
                    <th>% Tmo<br />Llamada</th>
                    <th>Tmo Registro<br />De Llamada</th>
                    <th>% Tmo Registro<br />De Llamada</th>
                    <th>Tmo<br />Pause</th>
                    <th>% Tmo<br />Pause</th>
                    <th>Tmo<br />Muerto</th>
                    <th>% Tmo<br />Muerto</th>
                    <th>Tmo Hablando<br />Con Cliente</th>
                    <th>Productividad</th>
                </tr>
            </thead>
            <tbody id="cuerpo-ejecutivos">
                
            </tbody>
        </table>
    </div>
</div>
