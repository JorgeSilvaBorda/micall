<%@include file="../headjava.jsp" %>

<br />
<div class="row">
    <div class="col-sm-4">
        <h3>BBDD</h3>
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
    <div class="col-sm-12">
        <form>
            <div class="row">
                <div class="col-sm-2">
                    <div class="form-group small">
                        <label for="desde">Fecha Inicio</label> 
                    </div>
                </div>
                <div class="col-sm-2">
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
                <div class="col-sm-2">
                    <div class="form-group small">
                        <input disabled="disabled" type="date" id="desde" class="form-control form-control-sm"/> 
                    </div>
                </div>
                <div class="col-sm-2">
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

<div class="row" >
    <div class="col-sm-12" id="detalle" >
        <!--
        <table class="table">
            <thead style="font-size:12px;">
                <tr>
                    <th colspan="2" >Indicadores</th>
                </tr>
                <tr>
                    <th>Concepto</th>
                    <th>Valor</th>    
                </tr>
            </thead>
            <tbody style="font-size: 12px;" id="cuerpo-indicadores">
                
            </tbody>
        </table>
        
        -->
    </div>   
</div>

<script type="text/javascript" src="panel-operativo/bbdd.js?=<% out.print(modelo.Util.generaRandom(10000, 99999)); %>" ></script>