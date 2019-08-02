package controlador;

import clases.json.JSONObject;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.PrintWriter;
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
		    + fila.getInt("fono3") + ")";
	    Conexion c = new Conexion();
	    c.abrir();
	    c.ejecutar(query);
	    c.cerrar();
	}
	
	
	salida.put("estado", "ok");
	return salida;
    }
}
