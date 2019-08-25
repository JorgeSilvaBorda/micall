package controlador;

import clases.json.JSONArray;
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
import modelo.Empresa;

public class EmpresaController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	JSONObject entrada = new JSONObject(request.getParameter("datos"));
	PrintWriter out = response.getWriter();
	response.setContentType("text/html; charset=UTF-8");
	switch (entrada.getString("tipo")) {
	    case "get-empresas":
		out.print(getEmpresas());
		break;
	    case "ins-empresa":
		out.print(crearEmpresa(entrada.getJSONObject("empresa")));
		break;
	    case "upd-empresa":
		out.print(updEmpresa(entrada.getJSONObject("empresa")));
		break;
	    case "del-empresa":
		out.print(delEmpresa(entrada.getInt("idempresa")));
		break;
	    case "existe-empresa":
		out.print(existeEmpresa(entrada.getInt("rutempresa")));
		break;
	    case "carga-select-empresa":
		out.print(getEmpresasSelect());
	}
    }

    public JSONObject crearEmpresa(JSONObject empresa) {
	Empresa e = new Empresa(empresa.getInt("rutempresa"), empresa.getString("dvempresa"), empresa.getString("nomempresa"), empresa.getString("direccion"), empresa.getString("creacion"), empresa.getString("ultmodificacion"));
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

    public JSONObject delEmpresa(int idEmpresa) {
	String query = "CALL SP_DEL_EMPRESA(" + idEmpresa + ")";
	Conexion c = new Conexion();
	c.abrir();
	c.ejecutar(query);
	c.cerrar();
	JSONObject salida = new JSONObject();
	salida.put("estado", "ok");
	return salida;
    }

    public JSONObject updEmpresa(JSONObject empresa) {

	String query = "CALL SP_UPD_EMPRESA("
		+ empresa.getInt("idempresa") + ", "
		+ empresa.getInt("rut") + ", "
		+ "'" + empresa.getString("dv") + "', "
		+ "'" + empresa.getString("nombre") + "', "
		+ "'" + empresa.getString("direccion") + "')";

	Conexion c = new Conexion();
	c.abrir();
	c.ejecutar(query);
	c.cerrar();
	JSONObject salida = new JSONObject();
	salida.put("estado", "ok");
	return salida;
    }

    public JSONObject getEmpresas() {
	JSONArray empresas = new JSONArray();
	JSONObject salida = new JSONObject();
	String query = "CALL SP_GET_EMPRESAS()";
	Conexion c = new Conexion();
	c.abrir();
	ResultSet rs = c.ejecutarQuery(query);
	String tabla = "";
	String filas = "";
	try {
	    while (rs.next()) {
		JSONObject empresa = new JSONObject();
		empresa.put("idempresa", rs.getInt("IDEMPRESA"));
		empresa.put("rutempresa", rs.getInt("RUTEMPRESA"));
		empresa.put("dvempresa", rs.getString("DVEMPRESA"));
		empresa.put("nombre", rs.getString("NOMBRE"));
		empresa.put("direccion", rs.getString("DIRECCION"));
		empresa.put("creacion", rs.getString("CREACION"));
		empresa.put("ultmodificacion", rs.getString("ULTMODIFICACION"));
		filas += "<tr>";
		filas += "<td><input type='hidden' value='" + rs.getInt("IDEMPRESA") + "' /><span>" + modelo.Util.formatRut(rs.getInt("RUTEMPRESA") + "-" + rs.getString("DVEMPRESA")) + "</span></td>";
		filas += "<td>" + rs.getString("NOMBRE") + "</td>";
		filas += "<td>" + rs.getString("DIRECCION") + "</td>";
		filas += "<td>" + rs.getString("CREACION") + "</td>";
		filas += "<td>" + rs.getString("ULTMODIFICACION") + "</td>";
		filas += "<td><button type='button' class='btn btn-sm btn-warning' onclick='editar(this)'>Editar</button><button type='button' class='btn btn-sm btn-danger' onclick='del(this)'>Eliminar</button></td>";
		filas += "</tr>";
		empresas.put(empresa);
	    }
	    salida.put("empresas", empresas);
	    salida.put("cuerpotabla", filas);
	    salida.put("estado", "ok");
	} catch (JSONException | SQLException ex) {
	    salida.put("estado", "error");
	    salida.put("mensaje", ex);
	    System.out.println("Error en EmpresaController.getEmpresas()");
	    System.out.println(ex);
	}
	c.cerrar();
	return salida;
    }

    public JSONObject getEmpresaById(int idEmpresa) {
	JSONObject salida = new JSONObject();
	String query = "CALL SP_GET_EMPRESA_BY_ID(" + idEmpresa + ")";
	Conexion c = new Conexion();
	c.abrir();
	ResultSet rs = c.ejecutarQuery(query);
	try {
	    while (rs.next()) {
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
	} catch (JSONException | SQLException ex) {
	    System.out.println("Problemas en EmpresaController.getEmpresaById()");
	    System.out.println(ex);
	    salida.put("estado", "error");
	    salida.put("mensaje", ex);
	}
	c.cerrar();
	return salida;
    }

    public JSONObject getEmpresaByRut(int rutEmpresa) {
	JSONObject salida = new JSONObject();
	String query = "CALL SP_GET_EMPRESA_BY_RUT(" + rutEmpresa + ")";
	Conexion c = new Conexion();
	c.abrir();
	ResultSet rs = c.ejecutarQuery(query);
	try {
	    while (rs.next()) {
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
	} catch (JSONException | SQLException ex) {
	    System.out.println("Problemas en EmpresaController.getEmpresaById()");
	    System.out.println(ex);
	    salida.put("estado", "error");
	    salida.put("mensaje", ex);
	}
	c.cerrar();
	return salida;
    }

    private JSONObject getEmpresasSelect() {
	String query = "CALL SP_GET_EMPRESAS()";
	Conexion c = new Conexion();
	c.abrir();
	ResultSet rs = c.ejecutarQuery(query);
	String options = modelo.Util.armarSelect(rs, "0", "Seleccione", "IDEMPRESA", "NOMBRE");
	c.cerrar();
	JSONObject salida = new JSONObject();
	salida.put("estado", "ok");
	salida.put("options", options);
	return salida;
    }
    
    private JSONObject existeEmpresa(int rutempresa){
	JSONObject salida = new JSONObject();
	Conexion c = new Conexion();
	c.abrir();
	String query = "SELECT COUNT(RUTEMPRESA) CANTIDAD FROM EMPRESA WHERE RUTEMPRESA = " + rutempresa;
	ResultSet rs = c.ejecutarQuery(query);
	int cont = 0;
	try {
	    while(rs.next()){
		cont = rs.getInt("CANTIDAD");
	    }
	    salida.put("cantidad", cont);
	    salida.put("estado", "ok");
	} catch (JSONException | SQLException ex) {
	    System.out.println("Problemas en EmpresaController.existeEmpresa()");
	    System.out.println(ex);
	    salida.put("estado", "error");
	    salida.put("mensaje", "ex");
	}
	c.cerrar();
	return salida;
    }
}
