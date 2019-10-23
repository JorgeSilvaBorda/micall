/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
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

public class TipoCampanaController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	JSONObject entrada = new JSONObject(request.getParameter("datos"));
	PrintWriter out = response.getWriter();
	response.setContentType("text/html; charset=UTF-8");
	switch(entrada.getString("tipo")){
	    case "select-tipo-campana":
		out.print(getSelectTipoCampana());
		break;
            default:
                break;
	}
    }
    
    //<editor-fold desc="Métodos no implementados" >
    private JSONObject getTipoCampanas(){
	JSONObject salida = new JSONObject();
        /*
	String query = "CALL SP_GET_TIPOCAMPANAS()";
	Conexion c = new Conexion();
	c.abrir();
	ResultSet rs = c.ejecutarQuery(query);
	String filas = "";
	try{
	    while(rs.next()){
		filas += "<tr>";
		filas += "<td><input type='hidden' value='" + rs.getInt("IDTIPOCAMPANA") + "' /><span>" + rs.getString("CODTIPOCAMPANA") + "</span></td>";
		//filas += "<td>" + rs.getString("CODTIPOCAMPANA") + "</td>";
		filas += "<td>" + rs.getString("NOMTIPOCAMPANA") + "</td>";
		//filas += "<td>" + modelo.Util.formatRut(rs.getInt("RUTEMPRESA") + "-" + rs.getString("DVEMPRESA")) + "</td>";
		//filas += "<td><button type='button' class='btn btn-sm btn-warning' onclick='edit(this)'>Editar</button><button type='button' class='btn btn-sm btn-danger' onclick='del(this)'>Eliminar</button></td>";
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
        */
        
        //No implementado ------------------------------------------------------
        salida.put("estado", "ok");
	return salida;
    }
    
    private JSONObject insTipoCampana(JSONObject producto){
	JSONObject salida = new JSONObject();
        /*
	String query = "CALL SP_INS_PRODUCTO("
		+ producto.getInt("idempresa") + ", "
		+ "'" + producto.getString("codproducto") + "', "
		+ "'" + producto.getString("descproducto") + "')";
	Conexion c = new Conexion();
	c.abrir();
	c.ejecutar(query);
	c.cerrar();
        */
        
        //No implementado ------------------------------------------------------
	salida.put("estado", "ok");
	return salida;
    }
    
    private JSONObject existeTipoCampana(JSONObject producto){
	JSONObject salida = new JSONObject();
        /*
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
        */
        //No implementado --------------------------------------------------------
        salida.put("estado", "ok");
	return salida;
    }
    
    private JSONObject udTipoCampana(JSONObject producto){
	JSONObject salida = new JSONObject();
	//No implementado --
	salida.put("estado", "ok");
	return salida;
    }
    
    private JSONObject delTipoCampana(int idtipocampana){
	JSONObject salida = new JSONObject();
	String query = "CALL SP_DEL_TIPOCAMPANA(" + idtipocampana + ")";
	Conexion c = new Conexion();
	c.abrir();
	c.ejecutar(query);
	c.cerrar();
	salida.put("estado", "ok");
	return salida;
    }
    //</editor-fold>
    
    private JSONObject getSelectTipoCampana(){
	JSONObject salida = new JSONObject();
	String query = "CALL SP_GET_SELECT_TIPOCAMPANAS()";
	Conexion c = new Conexion();
	c.abrir();
	ResultSet rs = c.ejecutarQuery(query);
	String options = modelo.Util.armarSelect(rs, "0", "Seleccione", "IDTIPOCAMPANA", "DESCRIPCION");
	salida.put("options", options);
	salida.put("estado", "ok");
	c.cerrar();
	return salida;
    }

}
