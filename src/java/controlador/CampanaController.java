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
import java.text.DecimalFormat;
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
	    case "select-campanas":
		out.print(selectCampana(entrada.getInt("idempresa")));
		break;
	    case "detalle-subproducto":
		out.print(getDetalle(entrada.getInt("idcampana")));
		break;
	    case "get-campana-empresa-rutcliente":
		out.print(getCampanaEmpresaRutcliente(entrada.getInt("rutcliente"), entrada.getInt("idempresa")));
		break;
	    case "get-camapana-idcampana-idempresa":
		out.print(getCamapanaIdcampanaIdempresa(entrada.getInt("idcampana"), entrada.getInt("idempresa")));
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
	DecimalFormat format = new DecimalFormat("###,###,###,###.##");
	try {
	    while (rs.next()) {
		filas += "<tr>";
		filas += "<td><input type='hidden' value='" + rs.getInt("IDCAMPANA") + "'>" + modelo.Util.formatRut(rs.getInt("RUTEMPRESA") + "-" + rs.getString("DVEMPRESA")) + "</td>";
		filas += "<td>" + rs.getString("NOMBRE") + "</td>";
		filas += "<td>" + rs.getString("CODCAMPANA") + "</td>";
		filas += "<td>" + rs.getString("NOMCAMPANA") + "</td>";
		filas += "<td>" + rs.getString("DESCPRODUCTO") + "</td>";
		filas += "<td>" + rs.getString("FECHAINI") + "</td>";
		filas += "<td>" + rs.getString("FECHAFIN") + "</td>";
		filas += "<td>$" + format.format(rs.getDouble("META")) + "</td>";
		String filaButton = "";
		if (rs.getInt("SUBPRODUCTOS") < 1) {
		    filaButton = "<td>0</td>";
		} else {
		    filaButton = "<td>" + rs.getInt("SUBPRODUCTOS") + " <button type='button' class='btn btn-sm btn-success' onclick='verSubs(" + rs.getInt("IDCAMPANA") + ");' >Ver</button></td>";
		}
		filas += filaButton;
		filas += "<td><button type='button' onclick='del(" + rs.getString("IDCAMPANA") + ")' class='btn btn-sm btn-danger'>Eliminar</button></td>";
		filas += "</tr>";
	    }
	    salida.put("estado", "ok");
	    salida.put("cuerpotabla", filas);
	} catch (JSONException | SQLException ex) {
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
		+ campana.getBigInteger("meta") + ")";
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
		    + subproducto.getBigInteger("montometa") + ","
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

    private JSONObject selectCampana(int idempresa) {
	JSONObject salida = new JSONObject();
	String query = "CALL SP_SEL_SELECT_CAMPANAS_FECHA(" + idempresa + ")";
	Conexion c = new Conexion();
	c.abrir();
	ResultSet rs = c.ejecutarQuery(query);
	String options = modelo.Util.armarSelect(rs, "0", "Seleccione", "IDCAMPANA", "TEXTO");
	c.cerrar();
	salida.put("estado", "ok");
	salida.put("options", options);
	return salida;
    }

    private JSONObject getDetalle(int idcampana) {
	JSONObject salida = new JSONObject();
	String query = "CALL SP_GET_DETALLE_SUBPRODUCTOS(" + idcampana + ")";
	Conexion c = new Conexion();
	c.abrir();
	ResultSet rs = c.ejecutarQuery(query);
	String cuerpotabla = "";
	DecimalFormat format = new DecimalFormat("###,###,###.##");
	try {
	    while (rs.next()) {
		cuerpotabla += "<tr>";

		cuerpotabla += "<td>[" + rs.getString("CODSUBPRODUCTO") + "] " + rs.getString("DESCSUBPRODUCTO") + "</td>";
		//cuerpotabla += "<td>" + rs.getString("DESCSUBPRODUCTO") + "</td>";
		cuerpotabla += "<td>" + rs.getBigDecimal("PRIMA") + "</td>";
		cuerpotabla += "<td>$" + format.format(rs.getDouble("MONTOMETA")) + "</td>";
		cuerpotabla += "<td>" + rs.getInt("CANTIDADMETA") + "</td>";

		cuerpotabla += "</tr>";
	    }
	    salida.put("estado", "ok");
	    salida.put("cuerpotabla", cuerpotabla);
	} catch (JSONException | SQLException ex) {
	    System.out.println("Problemas en modelo.CampanaController.getDetalle()");
	    System.out.println(ex);
	    salida.put("estado", "error");
	    salida.put("mensaje", ex);
	}
	c.cerrar();
	return salida;
    }

    private JSONObject getCampanaEmpresaRutcliente(int rutcliente, int idempresa) {
	JSONObject salida = new JSONObject();
	String query = "CALL SP_GET_CAMPANA_EMPRESA_RUTCLIETE("
		+ rutcliente + ","
		+ idempresa + ")";

	Conexion c = new Conexion();
	//System.out.println("query: " + query);
	int idCampana = 0;
	c.abrir();
	ResultSet rs = c.ejecutarQuery(query);
	JSONArray campanas = new JSONArray();
	DecimalFormat format = new DecimalFormat("###,###,###,###.##");
	int cont = 0;
	try {
	    while (rs.next()) {
		JSONObject campana = new JSONObject();
		idCampana = rs.getInt("IDCAMPANA");
		campana.put("idcampana", rs.getInt("IDCAMPANA"));
		campana.put("idproducto", rs.getInt("IDPRODUCTO"));
		campana.put("idempresa", rs.getInt("IDEMPRESA"));
		campana.put("rutcliente", rs.getInt("RUT"));
		campana.put("dvcliente", rs.getString("DV"));
		campana.put("nomcliente", rs.getString("NOMBRES"));
		campana.put("apellidoscliente", rs.getString("APELLIDOS"));
		campana.put("genero", rs.getString("GENERO"));
		campana.put("fechanac", rs.getDate("FECHANAC"));
		campana.put("direccion", rs.getString("DIRECCION"));
		campana.put("comuna", rs.getString("COMUNA"));
		campana.put("region", rs.getString("REGION"));
		campana.put("codigopostal", rs.getInt("CODIGOPOSTAL"));
		campana.put("email", rs.getString("EMAIL"));
		campana.put("fono1", rs.getInt("FONO1"));
		campana.put("fono2", rs.getInt("FONO2"));
		campana.put("fono3", rs.getInt("FONO3"));
		campana.put("nomcampana", rs.getString("NOMCAMPANA"));
		campana.put("codcampana", rs.getString("CODCAMPANA"));
		campana.put("fechaini", rs.getDate("FECHAINI"));
		campana.put("fechafin", rs.getDate("FECHAFIN")); //Debajo de esta línea se estaba rescatando la meta como int. a parte de la de abajo
		campana.put("codproducto", rs.getString("CODPRODUCTO"));
		campana.put("descproducto", rs.getString("DESCPRODUCTO"));
		campana.put("nomempresa", rs.getString("NOMBRE"));
		campana.put("rutempresa", rs.getInt("RUTEMPRESA"));
		campana.put("dvempresa", rs.getString("DVEMPRESA"));
		campana.put("montoaprobado", rs.getInt("MONTOAPROBADO"));
		campana.put("meta", format.format(rs.getDouble("META")));
		campanas.put(campana);
		cont++;
	    }
	    salida.put("campanas", campanas);
	} catch (JSONException | SQLException ex) {
	    System.out.println("Problemas en modelo.CampanaController.getCampanaEmpresaRutCliente()[CABECERA]");
	    System.out.println(ex);
	    salida.put("estado", "error");
	    salida.put("mensaje", ex);
	}
	//System.out.println("Cont: " + cont);
	c.cerrar();
	if (cont > 1) {
	    salida.put("estado", "ok");
	    return salida;
	}
	c = new Conexion();
	c.abrir();
	query = "CALL SP_GET_DETALLE_SUBPRODUCTOS(" + idCampana + ")";
	
	ResultSet result = c.ejecutarQuery(query);
	String tab = "";
	
	try {
	    while (result.next()) {
		tab += "<tr>";
		tab += "<td><input type='checkbox' /></td>";
		tab += "<td><input type='hidden' value='" + result.getInt("IDCAMPANA") + "' /><input type='hidden' value='" + result.getInt("IDSUBPRODUCTO") + "' />" + result.getString("CODSUBPRODUCTO") + "</td>";
		tab += "<td>" + result.getString("DESCSUBPRODUCTO") + "</td>";
		tab += "<td>" + result.getBigDecimal("PRIMA") + "</td>";
		tab += "<td>$" + format.format(result.getDouble("MONTOMETA")) + "</td>";
		tab += "<td>" + result.getInt("CANTIDADMETA") + "</td>";
		tab += "</tr>";
	    }
	    salida.put("estado", "ok");
	    salida.put("cuerpotabla", tab);
	} catch (JSONException | SQLException ex) {
	    System.out.println("Problemas en modelo.CampanaController.getCampanaEmpresaRutCliente() [DETALLE]");
	    System.out.println(ex);
	    salida.put("estado", "error");
	    salida.put("mensaje", ex);
	}
	c.cerrar();
	System.out.println(salida);
	return salida;
    }

    private JSONObject getCamapanaIdcampanaIdempresa(int idcampana, int idempresa) {
	JSONObject salida = new JSONObject();
	String query = "CALL SP_GET_CAMPANA_IDCAMPANA_IDEMPRESA("
		+ idcampana + ","
		+ idempresa + ")";

	Conexion c = new Conexion();
	c.abrir();
	ResultSet rs = c.ejecutarQuery(query);
	JSONObject campana = new JSONObject();
	DecimalFormat format = new DecimalFormat("###,###,###,###.##");
	try {
	    while (rs.next()) {
		
		campana.put("idcampana", rs.getInt("IDCAMPANA"));
		campana.put("idproducto", rs.getInt("IDPRODUCTO"));
		campana.put("idempresa", rs.getInt("IDEMPRESA"));
		campana.put("rutcliente", rs.getInt("RUT"));
		campana.put("dvcliente", rs.getString("DV"));
		campana.put("nomcliente", rs.getString("NOMBRES"));
		campana.put("apellidoscliente", rs.getString("APELLIDOS"));
		campana.put("genero", rs.getString("GENERO"));
		campana.put("fechanac", rs.getDate("FECHANAC"));
		campana.put("direccion", rs.getString("DIRECCION"));
		campana.put("comuna", rs.getString("COMUNA"));
		campana.put("region", rs.getString("REGION"));
		campana.put("codigopostal", rs.getInt("CODIGOPOSTAL"));
		campana.put("email", rs.getString("EMAIL"));
		campana.put("fono1", rs.getInt("FONO1"));
		campana.put("fono2", rs.getInt("FONO2"));
		campana.put("fono3", rs.getInt("FONO3"));
		campana.put("nomcampana", rs.getString("NOMCAMPANA"));
		campana.put("codcampana", rs.getString("CODCAMPANA"));
		campana.put("fechaini", rs.getDate("FECHAINI"));
		campana.put("fechafin", rs.getDate("FECHAFIN"));
		//campana.put("meta", rs.getInt("META"));
		campana.put("codproducto", rs.getString("CODPRODUCTO"));
		campana.put("descproducto", rs.getString("DESCPRODUCTO"));
		campana.put("nomempresa", rs.getString("NOMBRE"));
		campana.put("rutempresa", rs.getInt("RUTEMPRESA"));
		campana.put("dvempresa", rs.getString("DVEMPRESA"));
		campana.put("montoaprobado", rs.getInt("MONTOAPROBADO"));
		campana.put("meta", format.format(rs.getDouble("META")));
	    }
	    salida.put("campana", campana);
	} catch (JSONException | SQLException ex) {
	    System.out.println("Problemas en modelo.CampanaController.getCampanaIdcamapanaIdempresa()[CABECERA]");
	    System.out.println(ex);
	    salida.put("estado", "error");
	    salida.put("mensaje", ex);
	}
	c.cerrar();

	c = new Conexion();
	c.abrir();
	query = "CALL SP_GET_DETALLE_SUBPRODUCTOS(" + salida.getJSONObject("campana").getInt("idcampana") + ")";
	ResultSet result = c.ejecutarQuery(query);
	String tab = "";
	
	try {
	    while (result.next()) {
		tab += "<tr>";
		tab += "<td><input type='checkbox' /></td>";
		tab += "<td><input type='hidden' value='" + result.getInt("IDCAMPANA") + "' /><input type='hidden' value='" + result.getInt("IDSUBPRODUCTO") + "' />" + result.getString("CODSUBPRODUCTO") + "</td>";
		tab += "<td>" + result.getString("DESCSUBPRODUCTO") + "</td>";
		tab += "<td>" + result.getBigDecimal("PRIMA") + "</td>";
		tab += "<td>$" + format.format(result.getDouble("MONTOMETA")) + "</td>";
		tab += "<td>" + result.getInt("CANTIDADMETA") + "</td>";
		tab += "</tr>";
	    }
	    salida.put("estado", "ok");
	    salida.put("cuerpotabla", tab);
	} catch (JSONException | SQLException ex) {
	    System.out.println("Problemas en modelo.CampanaController.getCampanaIdcampanaIdempresa() [DETALLE]");
	    System.out.println(ex);
	    salida.put("estado", "error");
	    salida.put("mensaje", ex);
	}
	c.cerrar();

	return salida;
    }
}
