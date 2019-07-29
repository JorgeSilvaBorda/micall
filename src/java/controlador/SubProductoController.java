package controlador;

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
import modelo.Conexion;

public class SubProductoController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	JSONObject entrada = new JSONObject(request.getParameter("datos"));
	PrintWriter out = response.getWriter();
	response.setContentType("text/html; charset=UTF-8");
	switch (entrada.getString("tipo")) {
	    case "get-subproductos":
		out.print(getSubProductos());
		break;
	    case "ins-subproducto":
		out.print(insSubProducto(entrada.getJSONObject("subproducto")));
		break;
	    case "existe-subproducto":
		out.print(existeSubProducto(entrada.getJSONObject("subproducto")));
		break;
	    case "upd-subproducto":
		out.print(updSubProducto(entrada.getJSONObject("subproducto")));
		break;
	    case "del-subproducto":
		out.print(delSubProducto(entrada.getInt("idsubproducto")));
		break;
	}
    }

    private JSONObject getSubProductos() {
	JSONObject salida = new JSONObject();
	String query = "CALL SP_GET_SUBPRODUCTOS()";
	Conexion c = new Conexion();
	c.abrir();
	ResultSet rs = c.ejecutarQuery(query);
	String filas = "";
	try {
	    while (rs.next()) {
		filas += "<tr>";
		filas += "<td><input type='hidden' value='" + rs.getInt("IDSUBPRODUCTO") + "' /><input type='hidden' value='" + rs.getInt("IDEMPRESA") + "' /><span>" + rs.getString("CODSUBPRODUCTO") + "</span></td>";
		filas += "<td>" + rs.getString("DESCSUBPRODUCTO") + "</td>";
		filas += "<td>" + rs.getString("NOMBRE") + "</td>";
		filas += "<td>" + modelo.Util.formatRut(rs.getInt("RUTEMPRESA") + "-" + rs.getString("DVEMPRESA")) + "</td>";
		filas += "<td>" + rs.getString("PRIMA") + "</td>";
		filas += "<td><button type='button' class='btn btn-sm btn-warning' onclick='edit(this)'>Editar</button><button type='button' class='btn btn-sm btn-danger' onclick='del(this)'>Eliminar</button></td>";
		filas += "</tr>";
	    }
	    salida.put("cuerpotabla", filas);
	    salida.put("estado", "ok");
	} catch (JSONException | SQLException ex) {
	    System.out.println("Problemas en controlador.SubProductoController.getSubProductos()");
	    System.out.println(ex);
	    salida.put("estado", "error");
	    salida.put("mensaje", ex);
	}
	c.cerrar();
	return salida;
    }

    private JSONObject insSubProducto(JSONObject subproducto) {
	JSONObject salida = new JSONObject();
	String query = "CALL SP_INS_SUBPRODUCTO("
		+ subproducto.getInt("idempresa") + ", "
		+ "'" + subproducto.getString("codsubproducto") + "', "
		+ "'" + subproducto.getString("descsubproducto") + "',"
		+ subproducto.getBigDecimal("prima") + ")";
	Conexion c = new Conexion();
	c.abrir();
	c.ejecutar(query);
	c.cerrar();
	salida.put("estado", "ok");
	return salida;
    }

    private JSONObject existeSubProducto(JSONObject subproducto) {
	JSONObject salida = new JSONObject();
	String query = "CALL SP_EXISTE_SUBPRODUCTO("
		+ "'" + subproducto.getString("codsubproducto") + "', "
		+ subproducto.getString("idempresa") + ")";
	Conexion c = new Conexion();
	c.abrir();
	ResultSet rs = c.ejecutarQuery(query);
	int cantidad = 0;
	try {
	    while (rs.next()) {
		cantidad = rs.getInt("CANTIDAD");
	    }
	    salida.put("estado", "ok");
	    salida.put("cantidad", cantidad);
	} catch (JSONException | SQLException ex) {
	    System.out.println("Problemas en controlador.SubProductoController.existeSubProducto()");
	    System.out.println(ex);
	    salida.put("estado", "error");
	    salida.put("mensaje", ex);
	}
	c.cerrar();
	return salida;
    }

    private JSONObject updSubProducto(JSONObject subproducto) {
	JSONObject salida = new JSONObject();
	String query = "CALL SP_UPD_SUBPRODUCTO(" 
		+ subproducto.getInt("idsubproducto") + ", " 
		+ subproducto.getInt("idempresa") + ", "
		+ "'" + subproducto.getString("codsubproducto") + "', "
		+ "'" + subproducto.getString("descsubproducto") + "',"
		+ subproducto.getBigDecimal("prima") + ")";
	Conexion c = new Conexion();
	c.abrir();
	c.ejecutar(query);
	c.cerrar();
	salida.put("estado", "ok");
	return salida;
    }

    private JSONObject delSubProducto(int idsubproducto) {
	JSONObject salida = new JSONObject();
	String query = "CALL SP_DEL_SUBPRODUCTO(" + idsubproducto + ")";
	Conexion c = new Conexion();
	c.abrir();
	c.ejecutar(query);
	c.cerrar();
	salida.put("estado", "ok");
	return salida;
    }
}
