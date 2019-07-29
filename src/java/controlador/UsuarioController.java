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
import javax.servlet.http.HttpSession;
import modelo.Conexion;

public class UsuarioController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	PrintWriter out = response.getWriter();
	response.setContentType("text/html; charset=UTF-8");
	JSONObject entrada = new JSONObject(request.getParameter("datos"));
	switch (entrada.getString("tipo")) {
	    case "login":
		out.print(loginUsuario(entrada.getJSONObject("credenciales"), request));
		break;
	}
    }

    private JSONObject loginUsuario(JSONObject credenciales, HttpServletRequest request) {
	JSONObject salida = new JSONObject();
	int rut = Integer.parseInt(credenciales.getString("rutusuario"));
	String password = credenciales.getString("password");

	String query = "CALL SP_VALIDA_USUARIO(" + rut + ", '" + modelo.Util.hashMD5(password) + "')";
	Conexion c = new Conexion();
	c.abrir();
	ResultSet rs = c.ejecutarQuery(query);
	int cont = 0;
	try {
	    while (rs.next()) {
		JSONObject usuario = new JSONObject();
		usuario.put("idusuario", rs.getInt("IDUSUARIO"));
		usuario.put("idtipousuario", rs.getInt("IDTIPOUSUARIO"));
		usuario.put("rutusuario", rs.getInt("RUTUSUARIO"));
		usuario.put("dvusuario", rs.getString("DVUSUARIO"));
		usuario.put("desctipousuario", rs.getString("DESCTIPOUSUARIO"));
		usuario.put("nombre", rs.getString("NOMUSUARIO"));
		usuario.put("appaterno", rs.getString("APPATERNO"));
		usuario.put("apmaterno", rs.getString("APMATERNO"));
		usuario.put("idempresa", rs.getInt("IDEMPRESA"));
		usuario.put("rutempresa", rs.getInt("RUTEMPRESA"));
		usuario.put("dvempresa", rs.getString("DVEMPRESA"));
		usuario.put("idusuario", rs.getInt("IDUSUARIO"));
		usuario.put("empresa", rs.getString("EMPRESA"));
		cont++;
		salida.put("filas", cont);
		salida.put("usuario", usuario);
	    }
	    if (cont < 1) {
		salida.put("estado", "no-valido");
		salida.put("mensaje", "Las credenciales que ingresó no coinciden con las registradas.");
	    } else {
		salida.put("estado", "ok");
		HttpSession session = request.getSession();
		JSONObject usuario = salida.getJSONObject("usuario");
		session.setAttribute("rutusuario", usuario.getInt("rutusuario"));
		session.setAttribute("dvusuario", usuario.getString("dvusuario"));
		session.setAttribute("nombre", usuario.getString("nombre"));
		session.setAttribute("idtipousuario", usuario.getInt("idtipousuario"));
		session.setAttribute("desctipousuario", usuario.getString("desctipousuario"));
		session.setAttribute("appaterno", usuario.getString("appaterno"));
		session.setAttribute("apmaterno", usuario.getString("apmaterno"));
		session.setAttribute("rutempresa", usuario.getInt("rutempresa"));
		session.setAttribute("dvempresa", usuario.getString("dvempresa"));
		session.setAttribute("empresa", usuario.getString("empresa"));
	    }
	} catch (JSONException | SQLException ex) {
	    System.out.println("Problemas en  controlador.UsuarioControler.loginUsuario()");
	    System.out.println(ex);
	    salida.put("estado", "error");
	    salida.put("mensaje", ex);
	}
	c.cerrar();
	return salida;
    }
}
