package controlador;

import clases.json.JSONArray;
import clases.json.JSONException;
import clases.json.JSONObject;
import java.sql.ResultSet;
import java.sql.SQLException;
import modelo.Empresa;
import modelo.Conexion;

public class EmpresaController {

    public JSONObject crearEmpresa(JSONObject empresa){
	Empresa e = new Empresa(empresa.getInt("rut"), empresa.getString("dv"), empresa.getString("nombre"), empresa.getString("direccion"), empresa.getString("creacion"), empresa.getString("ultmodificacion"));
	String query = "CALL SP_INS_EMPRESA("
		+ e.getRut() + ", "
		+ "'" + e.getDv() + "', "
		+ "'" + e.getNombre() + "', "
		+ "'" + e.getDireccion() + "')";
	Conexion c = new Conexion();
	c.abrir();
	c.ejecutar(query);
	c.cerrar();
	JSONObject salida = new JSONObject();
	salida.put("estado", "ok");
	return salida;
    }
    
    public JSONObject delEmpresa(int idEmpresa){
	String query = "CALL SP_DEL_EMPRESA(" + idEmpresa + ")";
	Conexion c = new Conexion();
	c.abrir();
	c.ejecutar(query);
	c.cerrar();
	JSONObject salida = new JSONObject();
	salida.put("estado", "ok");
	return salida;
    }  
    
    public JSONObject updEmpresa(JSONObject empresaOrigen, JSONObject empresaDestino){
	Empresa original = Empresa.fromJsonWithId(empresaOrigen);
	Empresa destino = Empresa.fromJsonWithId(empresaDestino);
	String query = "CALL SP_UPD_EMPRESA("
		+ original.getId() + ", "
		+ destino.getRut() + ", "
		+ "'" + destino.getDv() + "', "
		+ "'" + destino.getNombre() + "', "
		+ "'" + destino.getDireccion() + "')";
	
	Conexion c = new Conexion();
	c.abrir();
	c.ejecutar(query);
	c.cerrar();
	JSONObject salida = new JSONObject();
	salida.put("estado", "ok");
	return salida;
    }
    
    public JSONObject getEmpresas(){
	JSONArray empresas = new JSONArray();
	JSONObject salida = new JSONObject();
	String query = "CALL SP_GET_EMPRESAS()";
	Conexion c = new Conexion();
	c.abrir();
	ResultSet rs = c.ejecutarQuery(query);
	try{
	    while(rs.next()){
		JSONObject empresa = new JSONObject();
		empresa.put("idempresa", rs.getInt("IDEMPRESA"));
		empresa.put("rutempresa", rs.getInt("RUTEMPRESA"));
		empresa.put("dvempresa", rs.getString("DVEMPRESA"));
		empresa.put("nombre", rs.getInt("NOMBRE"));
		empresa.put("direccion", rs.getInt("DIRECCION"));
		empresa.put("creacion", rs.getInt("CREACION"));
		empresa.put("ultmodificacion", rs.getInt("ULTMODIFICACION"));
		empresas.put(empresa);
	    }
	    salida.put("empresas", empresas);
	    salida.put("estado", "ok");
	}catch (JSONException | SQLException ex) {
	    salida.put("estado", "error");
	    salida.put("mensaje", ex);
	    System.out.println("Error en EmpresaController.getEmpresas()");
	    System.out.println(ex);
	}
	c.cerrar();
	return salida;
    }
    
    public JSONObject getEmpresaById(int idEmpresa){
	JSONObject salida = new JSONObject();
	String query = "CALL SP_GET_EMPRESA_BY_ID(" + idEmpresa + ")";
	Conexion c = new Conexion();
	c.abrir();
	ResultSet rs = c.ejecutarQuery(query);
	try{
	    while(rs.next()){
		JSONObject empresa = new JSONObject();
		empresa.put("idempresa", rs.getInt("IDEMPRESA"));
		empresa.put("rutempresa", rs.getInt("RUTEMPRESA"));
		empresa.put("dvempresa", rs.getString("DVEMPRESA"));
		empresa.put("nombre", rs.getInt("NOMBRE"));
		empresa.put("direccion", rs.getInt("DIRECCION"));
		empresa.put("creacion", rs.getInt("CREACION"));
		empresa.put("ultmodificacion", rs.getInt("ULTMODIFICACION"));
		
		salida.put("empresa", empresa);
	    }
	    salida.put("estado", "ok");
	}catch (JSONException | SQLException ex) {
	    System.out.println("Problemas en EmpresaController.getEmpresaById()");
	    System.out.println(ex);
	    salida.put("estado", "error");
	    salida.put("mensaje", ex);
	}
	c.cerrar();
	return salida;
    }
    
    public JSONObject getEmpresaByRut(int rutEmpresa){
	JSONObject salida = new JSONObject();
	String query = "CALL SP_GET_EMPRESA_BY_RUT(" + rutEmpresa + ")";
	Conexion c = new Conexion();
	c.abrir();
	ResultSet rs = c.ejecutarQuery(query);
	try{
	    while(rs.next()){
		JSONObject empresa = new JSONObject();
		empresa.put("idempresa", rs.getInt("IDEMPRESA"));
		empresa.put("rutempresa", rs.getInt("RUTEMPRESA"));
		empresa.put("dvempresa", rs.getString("DVEMPRESA"));
		empresa.put("nombre", rs.getInt("NOMBRE"));
		empresa.put("direccion", rs.getInt("DIRECCION"));
		empresa.put("creacion", rs.getInt("CREACION"));
		empresa.put("ultmodificacion", rs.getInt("ULTMODIFICACION"));
		
		salida.put("empresa", empresa);
	    }
	    salida.put("estado", "ok");
	}catch (JSONException | SQLException ex) {
	    System.out.println("Problemas en EmpresaController.getEmpresaById()");
	    System.out.println(ex);
	    salida.put("estado", "error");
	    salida.put("mensaje", ex);
	}
	c.cerrar();
	return salida;
    }
    
}
