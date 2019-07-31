package controlador;

import clases.json.JSONArray;
import clases.json.JSONException;
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

public class CampanaController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	JSONObject entrada = new JSONObject(request.getParameter("datos"));
	PrintWriter out = response.getWriter();
	response.setContentType("text/html; charset=UTF-8");
	switch (entrada.getString("tipo")) {
	    case "get-campanas":
		out.print(getCampanas());
		break;
	    case "ins-campana":
		out.print(insCampanaSubProducto(entrada.getJSONObject("campana")));
		break;
	    case "del-campana":
		out.print(delCampana(entrada.getInt("idcampana")));
		break;
	    default:
		break;
	}
    }

    private JSONObject getCampanas() {
	JSONObject salida = new JSONObject();
	String query = "CALL SP_GET_CAMPANAS()";
	String filas = "";
	Conexion c = new Conexion();
	c.abrir();
	ResultSet rs = c.ejecutarQuery(query);
	try{
	    while(rs.next()){
		filas += "<tr>";
		filas += "<td><input type='hidden' value='" + rs.getInt("IDCAMPANA") + "'>" + modelo.Util.formatRut(rs.getInt("RUTEMPRESA") + "-" + rs.getString("DVEMPRESA")) + "</td>";
		filas += "<td>" + rs.getString("NOMBRE") + "</td>";
		filas += "<td>" + rs.getString("CODCAMPANA") + "</td>";
		filas += "<td>" + rs.getString("NOMCAMPANA") + "</td>";
		filas += "<td>" + rs.getString("DESCPRODUCTO") + "</td>";
		filas += "<td>" + rs.getString("FECHAINI") + "</td>";
		filas += "<td>" + rs.getString("FECHAFIN") + "</td>";
		filas += "<td>" + rs.getInt("META") + "</td>";
		String filaButton = "";
		if(rs.getInt("SUBPRODUCTOS") < 1){
		    filaButton = "<td>0</td>";
		}else{
		    filaButton = "<td>" + rs.getInt("SUBPRODUCTOS") + " <button type='button' class='btn btn-sm btn-success' onclick='verSubs(" + rs.getInt("IDCAMPANA") + ");' >Ver</button></td>";
		}
		filas += filaButton;
		filas += "<td><button type='button' onclick='del(" + rs.getString("IDCAMPANA") + ")' class='btn btn-sm btn-danger'>Eliminar</button></td>";
		filas += "</tr>";
	    }
	    salida.put("estado", "ok");
	    salida.put("cuerpotabla", filas);
	}catch (JSONException | SQLException ex) {
	    System.out.println("Problemas en modelo.CampanaController.getCampanas()");
	    System.out.println(ex);
	    salida.put("estado", "error");
	    salida.put("mensaje", ex);
	}
	c.cerrar();
	return salida;
    }

    private JSONObject insCampanaSubProducto(JSONObject campana) {
	JSONObject salida = new JSONObject();
	JSONArray subproductos = campana.getJSONArray("subproductos");
	Iterator i = subproductos.iterator();

	//Insertar Campaña
	String query = "CALL SP_INS_CAMPANA("
		+ campana.getInt("idproducto") + ", "
		+ "'" + campana.getString("nomcampana") + "', "
		+ "'" + campana.getString("codcampana") + "', "
		+ "'" + campana.getString("fechaini") + "', "
		+ "'" + campana.getString("fechafin") + "', "
		+ campana.getInt("meta") + ")";
	Conexion c = new Conexion();
	c.abrir();
	ResultSet rs = c.ejecutarQuery(query);

	int liid = 0;
	try {
	    while (rs.next()) {
		liid = rs.getInt("LIID");
	    }
	    if (liid == 0) {
		salida.put("estado", "error");
		salida.put("mensaje", "No se pudo ingresar la campaña. Se aborta la operación.");
	    } else {
		salida.put("idcampana", liid);
	    }
	} catch (JSONException | SQLException ex) {
	    System.out.println("Problemas en modelo.CampanaController.insCampana()");
	    System.out.println(ex);
	    salida.put("estado", "error");
	    salida.put("mensaje", ex);
	}
	c.cerrar();
	while (i.hasNext()) {
	    JSONObject subproducto = (JSONObject) i.next();
	    c = new Conexion();
	    c.abrir();
	    query = "CALL SP_INS_CAMPANA_SUBPRODUCTO("
		    + liid + ","
		    + subproducto.getInt("idsubproducto") + ","
		    + subproducto.getInt("montometa") + ","
		    + subproducto.getInt("cantmeta") + ")";
	    c.ejecutar(query);
	    c.cerrar();
	}
	salida.put("estado", "ok");
	return salida;
    }

    private JSONObject delCampana(int idcampana) {
	JSONObject salida = new JSONObject();
	String query = "CALL SP_DEL_CAMPANASUBPRODUCTO(" + idcampana + ")";
	Conexion c = new Conexion();
	c.abrir();
	c.ejecutar(query);
	c.cerrar();
	
	query = "CALL SP_DEL_CAMPANA(" + idcampana + ")";
	c = new Conexion();
	c.abrir();
	c.ejecutar(query);
	c.cerrar();
	salida.put("estado", "ok");
	return salida;
    }
}
