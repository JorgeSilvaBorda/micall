package controlador;

import clases.json.JSONObject;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.PrintWriter;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Properties;
import javax.servlet.http.HttpSession;
import modelo.Conexion;

/*
@WebServlet("/upload")
@MultipartConfig
 */
public class RuteroController extends HttpServlet {

    private static final int MEMORY_THRESHOLD = 1024 * 1024 * 3;  // 3MB
    private static final int MAX_FILE_SIZE = 1024 * 1024 * 100; // 40MB
    private static final int MAX_REQUEST_SIZE = 1024 * 1024 * 100; // 50MB
    private static final String RUTA_PROPERTIES = System.getenv("PANEL_PROPERTIES");
    private static String RUTA_LOGS_RUTEROS = "";
    private static final long serialVersionUID = 205242440643911308L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        PrintWriter out = response.getWriter();
        response.setContentType("text/html; charset=UTF-8");
        JSONObject entrada = new JSONObject(request.getParameter("datos"));
        HttpSession session = request.getSession();
        InputStream inStream = new FileInputStream(RUTA_PROPERTIES);
        Properties prop = new Properties();
        prop.load(inStream);
        RUTA_LOGS_RUTEROS = prop.getProperty("dir.ruteros.logs.linux");
        switch (entrada.getString("tipo")) {
            case "ins-rutero":
                out.print(insRutero(Integer.parseInt(session.getAttribute("idusuario").toString()), entrada.getInt("idcampana"), entrada.getInt("tipooperacion"), request));
                break;
            case "traer-ruteros-empresa":
                out.print(traerRuterosEmpresa(entrada.getInt("rutempresa")));
                break;
            case "del-rutero":
                out.print(delRutero(entrada.getString("contenido"), entrada.getInt("idusuario"), entrada.getInt("idcampana"), entrada.getString("nomarchivo")));
                break;
            case "valida-del-rutero":
                out.print(procesaContenidoRuteroEliminacion(entrada));
                break;
            default:
                break;
        }

    }

    private JSONObject insRutero(int idusuario, int idcampana, int tipooperacion, HttpServletRequest request) {
        JSONObject salida = new JSONObject();
        HttpSession session = request.getSession();
        JSONObject newid = getIdNewRutero();
        int idrutero = newid.getInt("idrutero");
        File rutero = new File(session.getAttribute("nombreArchivo").toString());
        if (rutero.exists() && rutero.isFile()) {
            try {
                String comando = "sh /home/interfaces/rutero/carga-rutero.sh " + idrutero + " " + idcampana + " " + idusuario + " " + (tipooperacion == 1 ? "INS" : "DEL") + " " + rutero;
                Process p = Runtime.getRuntime().exec(comando);

                BufferedReader reader = new BufferedReader(new InputStreamReader(p.getInputStream()));
                BufferedReader errorReader = new BufferedReader(new InputStreamReader(p.getErrorStream()));

                String line = "";
                while ((line = reader.readLine()) != null) {
                    System.out.println(line);
                }

                line = "";
                while ((line = errorReader.readLine()) != null) {
                    System.out.println(line);
                }
            } catch (IOException ex) {
                salida.put("estado", "error");
                salida.put("estado", "No se pudo ingresar el rutero");
            }

        }
        salida.put("estado", "ok");
        return salida;
    }

    private JSONObject traerRuterosEmpresa(int rutempresa) {
        JSONObject salida = new JSONObject();
        String query = "CALL SP_GET_RUTEROS_EMPRESA(" + rutempresa + ")";
        Conexion c = new Conexion();
        c.abrir();
        ResultSet rs = c.ejecutarQuery(query);
        String tab = "<table id='tabla-ruteros-empresa' class='table table-sm small table-borderless table-hover table-striped'><thead>";
        tab += "<tr>";
        tab += "<th>Fecha Carga</th>";
        tab += "<th>Campaña</th>";
        tab += "<th>Registros</th>";
        tab += "<th>Archivo</th>";
        tab += "<th>Tipo Operación</th>";
        tab += "</tr></thead><tbody>";
        try {
            while (rs.next()) {
                tab += "<tr>";
                tab += "<td>" + rs.getDate("FECHACARGA") + "</td>";
                tab += "<td>[" + rs.getString("CODCAMPANA") + "] " + rs.getString("NOMCAMPANA") + "</td>";
                tab += "<td>" + rs.getInt("CANT") + "</td>";
                tab += "<td>" + rs.getString("NOMARCHIVO") + "</td>";
                tab += "<td>" + rs.getString("DESCOPERACION") + "</td>";
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

    private JSONObject delRutero(String contenido, int idusuario, int idcampana, String nomarchivo) {
        JSONObject ruteroid = getIdNewRutero();
        JSONObject salida = new JSONObject();
        if (ruteroid.getInt("idrutero") == 0) {
            salida.put("estado", "error");
            salida.put("mensaje", "No se puede obtener el ID de Rutero");
            return salida;
        }
        salida.put("estado", "ok");
        return salida;
    }

    private JSONObject getIdNewRutero() {
        String query = "CALL SP_GET_ID_RUTERO()";
        Conexion c = new Conexion();
        c.abrir();
        JSONObject salida = new JSONObject();
        ResultSet rs = c.ejecutarQuery(query);
        try {
            while (rs.next()) {
                salida.put("idrutero", rs.getInt("IDRUTERO"));
                salida.put("fechacreacion", rs.getDate("FECHACREACION"));
            }
            return salida;
        } catch (SQLException ex) {
            System.out.println("No se pudo obtener el IDRUTERO");
            System.out.println(ex);
            salida.put("fechacreacion", "1900-01-01");
            salida.put("idrutero", 0);
        }
        c.cerrar();
        System.out.println("Nuevo rutero: " + salida);
        return salida;
    }

    private JSONObject procesaContenidoRuteroEliminacion(JSONObject entrada) {
        //Generar archivo con el contenido--------------------------------------
        String RUTA_DEFAULT = "RUTERO.csv"; // [EN DURO] !!!! Corregir. Parametrizar en .properties 
        File newRutero = new File(RUTA_DEFAULT);
        //String nomarchivo = entrada.getString("nomarchivo");
        String[] filas = entrada.getString("contenido").split("\r\n");
        int filasProcesadas = 0;
        int filasBuenas = 0;
        int filasMalas = 0;
        //for (String fila : filas) {
        for (int i = 1; i < filas.length; i++) {
            String fila = filas[i];

            //System.out.println(fila);
            if (procesarFilaEliminacion(fila)) {
                filasBuenas++;
            } else {
                System.out.println("Fila: " + (filasProcesadas + 2));
                filasMalas++;
            }
            filasProcesadas++;
        }

        //System.out.println(filas);
        JSONObject salida = new JSONObject();
        salida.put("filasBuenas", filasBuenas);
        salida.put("filasMalas", filasMalas);
        salida.put("filasProcesadas", filasProcesadas);
        salida.put("estado", "ok");
        System.out.println(salida);
        return salida;
    }

    private boolean procesarFilaEliminacion(String fila) {

        //System.out.println(campos.length);
        //[VALIDACIONES]--------------------------------------------------------
        try {
            String[] campos = fila.split(";");
            //Validar Largo --------------------------------------------------------
            if (campos.length < 19) {
                System.out.println("Largo invalido");
                return false;
            }
            //valida largo campo rut -----------------------------------------------
            if (campos[0].length() < 7 || campos[0].length() > 8) {
                System.out.println("Largo de rut invalido. Largo encontrado: " + campos[0].length());
                return false;
            }
            //Valida campo rut numérico --------------------------------------------
            try {
                int rut = Integer.parseInt(campos[0]);
            } catch (NumberFormatException ex) {
                System.out.println("Rut no numérico");
                return false;
            }
            //Valida dv ------------------------------------------------------------
            if (!new modelo.Util().validarRut(campos[0].concat(campos[1]))) {
                System.out.println("Rut inválido");
                return false;
            }
        } catch (Exception ex) {
            System.out.println("Error al validar la fila:");
            System.out.println(ex);
            return false;
        }

        return true;
    }

}
