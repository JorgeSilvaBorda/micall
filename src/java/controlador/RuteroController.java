package controlador;

import clases.json.JSONObject;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.PrintWriter;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Iterator;
import modelo.Conexion;

public class RuteroController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	JSONObject entrada = new JSONObject(request.getParameter("datos"));
	PrintWriter out = response.getWriter();
	response.setContentType("text/html; charset=UTF-8");
	switch (entrada.getString("tipo")) {
	    case "ins-rutero":
		out.print(insRutero(entrada.getJSONObject("rutero")));
		break;
            case "traer-ruteros-empresa":
                out.print(traerRuterosEmpresa(entrada.getInt("rutempresa")));
                break;
	    default:
		break;
	}
    }

    private JSONObject insRutero(JSONObject rutero) {
	JSONObject salida = new JSONObject();
	int idcampana = rutero.getInt("idcampana");
	Iterator i = rutero.getJSONArray("filas").iterator();
	while(i.hasNext()){
	    JSONObject fila = (JSONObject) i.next();
	    String query = "CALL SP_INS_FILA_RUTERO("
		    + idcampana + ","
		    + fila.getInt("rutcliente") + ","
		    + "'" + fila.getString("dvcliente") + "',"
		    + "'" + fila.getString("nombres") + "',"
		    + "'" + fila.getString("apellidos") + "',"
		    + "'" + fila.getString("genero") + "',"
		    + "'" + fila.getString("fechanac") + "',"
		    + "'" + fila.getString("direccion") + "',"
		    + "'" + fila.getString("comuna") + "',"
		    + "'" + fila.getString("region") + "',"
		    + fila.getInt("codigopostal") + ","
		    + "'" + fila.getString("email") + "',"
		    + fila.getInt("montoaprobado") + ","
		    + fila.getInt("fono1") + ","
		    + fila.getInt("fono2") + ","
		    + fila.getInt("fono3") + ","
                    + "'" + fila.getString("nomarchivo") + "')";
	    Conexion c = new Conexion();
	    c.abrir();
	    c.ejecutar(query);
	    c.cerrar();
	}
	
	
	salida.put("estado", "ok");
	return salida;
    }
    
    private JSONObject traerRuterosEmpresa(int rutempresa){
        JSONObject salida = new JSONObject();
        String query = "CALL SP_GET_RUTEROS_EMPRESA(" + rutempresa + ")";
        Conexion c = new Conexion();
        c.abrir();
        ResultSet rs = c.ejecutarQuery(query);
        //System.out.println(query);
        String tab = "<table id='tabla-ruteros-empresa' class='table table-sm small table-borderless table-hover table-striped'><thead>";
        tab += "<tr>";
        tab += "<th>Fecha Carga</th>";
        tab += "<th>Campaña</th>";
        tab += "<th>Registros</th>";
        tab += "<th>Archivo</th>";
        tab += "</tr></thead><tbody>";
        try {
            while(rs.next()){
                tab += "<tr>";
                tab += "<td>" + rs.getDate("FECHACARGA") + "</td>";
                tab += "<td>[" + rs.getString("CODCAMPANA") + "] " + rs.getString("NOMCAMPANA") + "</td>";
                tab += "<td>" + rs.getInt("CANT") + "</td>";
                tab += "<td>" + rs.getString("NOMARCHIVO") + "</td>";
                tab += "</tr>";
            }
            salida.put("tabla", tab);
            salida.put("estado", "ok");
        } catch (SQLException ex) {
            System.out.println("Problemas en modelo.RuteroController.traerRuterosEmpresa()");
            System.out.println(ex);
            salida = new JSONObject();
            salida.put("estado", "error");
            salida.put("mensaje", ex);
        }
        c.cerrar();
        return salida;
    }
}
