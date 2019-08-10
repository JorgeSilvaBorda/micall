package controlador;

import clases.json.JSONException;
import clases.json.JSONObject;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import modelo.Conexion;

public class ProductoController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	JSONObject entrada = new JSONObject(request.getParameter("datos"));
	PrintWriter out = response.getWriter();
	response.setContentType("text/html; charset=UTF-8");
	switch(entrada.getString("tipo")){
	    case "get-productos":
		out.print(getProductos());
		break;
	    case "ins-producto":
		out.print(insProducto(entrada.getJSONObject("producto")));
		break;
	    case "existe-producto":
		out.print(existeProducto(entrada.getJSONObject("producto")));
		break;
	    case "upd-producto":
		out.print(updProducto(entrada.getJSONObject("producto")));
		break;
	    case "del-producto":
		out.print(delProducto(entrada.getInt("idproducto")));
		break;
	    case "carga-datos-producto":
		out.print(getSelectProductos(Integer.parseInt(entrada.getString("idempresa"))));
		break;
	}
    }
    
    private JSONObject getProductos(){
	JSONObject salida = new JSONObject();
	String query = "CALL SP_GET_PRODUCTOS()";
	Conexion c = new Conexion();
	c.abrir();
	ResultSet rs = c.ejecutarQuery(query);
	String filas = "";
	try{
	    while(rs.next()){
		filas += "<tr>";
		filas += "<td><input type='hidden' value='" + rs.getInt("IDPRODUCTO") + "' /><input type='hidden' value='" + rs.getInt("IDEMPRESA") + "' /><span>" + rs.getString("CODPRODUCTO") + "</span></td>";
		filas += "<td>" + rs.getString("DESCPRODUCTO") + "</td>";
		filas += "<td>" + rs.getString("NOMBRE") + "</td>";
		filas += "<td>" + modelo.Util.formatRut(rs.getInt("RUTEMPRESA") + "-" + rs.getString("DVEMPRESA")) + "</td>";
		filas += "<td><button type='button' class='btn btn-sm btn-warning' onclick='edit(this)'>Editar</button><button type='button' class='btn btn-sm btn-danger' onclick='del(this)'>Eliminar</button></td>";
		filas += "</tr>";
	    }
	    salida.put("cuerpotabla", filas);
	    salida.put("estado", "ok");
	}catch (JSONException | SQLException ex) {
	    System.out.println("Problemas en controlador.ProductoController.getEmpresas()");
	    System.out.println(ex);
	    salida.put("estado", "error");
	    salida.put("mensaje", ex);
	}
	c.cerrar();
	return salida;
    }
    
    private JSONObject insProducto(JSONObject producto){
	JSONObject salida = new JSONObject();
	String query = "CALL SP_INS_PRODUCTO("
		+ producto.getInt("idempresa") + ", "
		+ "'" + producto.getString("codproducto") + "', "
		+ "'" + producto.getString("descproducto") + "')";
	Conexion c = new Conexion();
	c.abrir();
	c.ejecutar(query);
	c.cerrar();
	salida.put("estado", "ok");
	return salida;
    }
    
    private JSONObject existeProducto(JSONObject producto){
	JSONObject salida = new JSONObject();
	String query = "CALL SP_EXISTE_PRODUCTO("
		+ "'" + producto.getString("codproducto") + "', "
		+ producto.getString("idempresa") + ")";
	Conexion c = new Conexion();
	c.abrir();
	ResultSet rs = c.ejecutarQuery(query);
	int cantidad = 0;
	try{
	    while(rs.next()){
		cantidad = rs.getInt("CANTIDAD");
	    }
	    salida.put("estado", "ok");
	    salida.put("cantidad", cantidad);
	}catch (JSONException | SQLException ex) {
	    System.out.println("Problemas en controlador.ProductoController.existeProducto()");
	    System.out.println(ex);
	    salida.put("estado", "error");
	    salida.put("mensaje", ex);
	}
	c.cerrar();
	return salida;
    }
    
    private JSONObject updProducto(JSONObject producto){
	JSONObject salida = new JSONObject();
	String query = "CALL SP_UPD_PRODUCTO(" + producto.getInt("idproducto") + ", " + producto.getInt("idempresa") + ", '" + producto.getString("codproducto") + "', '" + producto.getString("descproducto") + "')";
	Conexion c = new Conexion();
	c.abrir();
	c.ejecutar(query);
	c.cerrar();
	salida.put("estado", "ok");
	return salida;
    }
    
    private JSONObject delProducto(int idproducto){
	JSONObject salida = new JSONObject();
	String query = "CALL SP_DEL_PRODUCTO(" + idproducto + ")";
	Conexion c = new Conexion();
	c.abrir();
	c.ejecutar(query);
	c.cerrar();
	salida.put("estado", "ok");
	return salida;
    }
    
    private JSONObject getSelectProductos(int idempresa){
	JSONObject salida = new JSONObject();
	String query = "CALL SP_GET_SELECT_PRODUCTOS(" + idempresa + ")";
	Conexion c = new Conexion();
	c.abrir();
	ResultSet rs = c.ejecutarQuery(query);
	String options = modelo.Util.armarSelect(rs, "0", "Seleccione", "IDPRODUCTO", "DESCPRODUCTO");
	salida.put("options", options);
	salida.put("estado", "ok");
	c.cerrar();
	return salida;
    }
}
