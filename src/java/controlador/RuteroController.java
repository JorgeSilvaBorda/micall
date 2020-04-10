package controlador;

import clases.json.JSONException;
import clases.json.JSONObject;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
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
import modelo.Util;

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
    private static String RUTA_RUTEROS = "";
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
        RUTA_RUTEROS = prop.getProperty("dir.ruteros.proceso.linux");
        switch (entrada.getString("tipo")) {
            case "ins-rutero":
                out.print(insRutero(entrada.getInt("idrutero"), Integer.parseInt(session.getAttribute("idusuario").toString()), entrada.getInt("idcampana"), entrada.getInt("tipooperacion"), request));
                break;
            case "traer-ruteros-empresa":
                out.print(traerRuterosEmpresa(entrada.getInt("rutempresa")));
                break;
            case "valida-del-rutero":
                out.print(procesaContenidoRuteroEliminacion(entrada));
                break;
            case "del-archivo-proceso":
                out.print(delArchivoProceso(entrada.getString("nomarchivo")));
                request.getSession().removeAttribute("nombreArchivo");
                break;
            case "get-filas-cargadas":
                out.print(getFilasCargadas(entrada));
                break;
            default:
                break;
        }

    }

    private JSONObject insRutero(int idrutero, int idusuario, int idcampana, int tipooperacion, HttpServletRequest request) {
        JSONObject salida = new JSONObject();
        HttpSession session = request.getSession();

        File rutero = new File(session.getAttribute("nombreArchivo").toString());
        File logCarga = new File(RUTA_LOGS_RUTEROS + File.separator + rutero.getName() + ".log");
        if (logCarga.exists() && logCarga.isFile()) {
            try {
                FileWriter fr = new FileWriter(logCarga, true);
                fr.write("[" + modelo.Util.getFechaHora() + "]Inicia el proceso de carga de Rutero en BD." + System.getProperty("line.separator"));
                fr.flush();
                fr.close();
            } catch (IOException ex) {
                System.out.println("No se puede escribir el final de la carga en el archivo de log.");
                System.out.println(ex);
            }
        }
        if (rutero.exists() && rutero.isFile()) {

            int filas = 0;
            try {
                try {
                    filas = Util.cuentaLineasArchivo(rutero.getAbsolutePath());
                } catch (IOException ex) {
                    System.out.println("Error al obtener la cantidad de filas del archivo: " + rutero.getAbsolutePath());
                    System.out.println(ex);
                    salida.put("estado", "error");
                    salida.put("mensaje", "No se pudo obtener la cantidad de filas del archivo.");
                    return salida;
                }

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
                System.out.println("Error. No se puede procesar el rutero");
                System.out.println(ex);
                salida.put("estado", "error");
                salida.put("mensaje", "No se pudo ingresar el rutero" + System.getProperty("line.separator") + ex);
            }

        }
        salida.put("estado", "ok");
        if (logCarga.exists() && logCarga.isFile()) {
            try {
                FileWriter fr = new FileWriter(logCarga, true);
                fr.write("[" + modelo.Util.getFechaHora() + "]Termina el proceso de carga de Rutero en BD.");
                fr.flush();
                fr.close();
            } catch (IOException ex) {
                System.out.println("No se puede escribir el final de la carga en el archivo de log.");
                System.out.println(ex);
            }
        }
        return salida;
    }

    private JSONObject getFilasCargadas(JSONObject entrada) {
        JSONObject salida = new JSONObject();
        String query = "CALL SP_GET_FILAS_CARGADAS(" + entrada.getInt("idrutero") + ")";
        System.out.println(query);
        Conexion c = new Conexion();
        c.abrir();
        ResultSet rs = c.ejecutarQuery(query);
        try {
            while (rs.next()) {
                salida.put("idrutero", rs.getInt("IDRUTERO"));
                salida.put("filastotales", rs.getInt("TOTALFILAS"));
                salida.put("filascargadas", rs.getInt("CUENTAACTUAL"));
            }
            salida.put("estado", "ok");
        } catch (JSONException | SQLException ex) {
            System.out.println("Problemas en controlador.RuteroController.getFilasCargadas()");
            System.out.println(ex);
            salida.put("estado", "error");
            salida.put("mensaje", ex);
        }
        c.cerrar();
        return salida;
    }

    private JSONObject traerRuterosEmpresa(int rutempresa) {
        JSONObject salida = new JSONObject();
        String query = "CALL SP_GET_RUTEROS_EMPRESA_2(" + rutempresa + ")";
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
        tab += "<th>Log</th>";
        tab += "</tr></thead><tbody>";
        try {
            while (rs.next()) {
                String rutafullarchivo = rs.getString("NOMARCHIVO");
                String nomLog = rutafullarchivo.split(java.io.File.separator)[rutafullarchivo.split(java.io.File.separator).length - 1];
                String enlace = "";
                File log = new File(RUTA_LOGS_RUTEROS + File.separator + nomLog + ".log");
                //System.out.println("Para el log: " + log.getAbsolutePath());
                if (log.exists() && log.isFile()) {
                    enlace = "<td><a href='#' onclick='traerLog(\"" + nomLog + ".log\");'>Descargar</a></td>";
                } else {
                    enlace = "<td></td>";
                }
                String nomarchivo = rs.getString("NOMARCHIVO").split(File.separator)[rs.getString("NOMARCHIVO").split(File.separator).length - 1];
                tab += "<tr>";
                tab += "<td>" + rs.getDate("FECHACARGA") + "</td>";
                tab += "<td>[" + rs.getString("CODCAMPANA") + "] " + rs.getString("NOMCAMPANA") + "</td>";
                tab += "<td>" + rs.getInt("CANT") + "</td>";
                //tab += "<td>" + rs.getString("NOMARCHIVO") + "</td>";
                tab += "<td>" + nomarchivo + "</td>";
                tab += "<td>" + rs.getString("DESCOPERACION") + "</td>";
                tab += enlace;
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

    private JSONObject delArchivoProceso(String nomarchivo) {
        JSONObject salida = new JSONObject();
        File rutero = new File(RUTA_RUTEROS + File.separator + nomarchivo);
        if (rutero.exists() && rutero.isFile()) {
            rutero.delete();
        }
        salida.put("estado", "ok");
        salida.put("mensaje", "Archivo eliminado correctamente.");
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
            JSONObject resultado = procesarFilaEliminacion(fila);
            if (resultado.getInt("estado") == 0) {
                filasBuenas++;
            } else {
                System.out.println(resultado);
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

    private JSONObject procesarFilaEliminacion(String fila) {
        JSONObject salida = new JSONObject();
        //System.out.println(campos.length);
        //[VALIDACIONES]--------------------------------------------------------
        try {
            String[] campos = fila.split(";");
            //Validar Largo --------------------------------------------------------
            if (campos.length < 19) {
                System.out.println("Largo invalido");
                salida.put("rut", campos[0]);
                salida.put("mensaje", "Largo de fila inválido.");
                salida.put("fila", (fila + 1));
                salida.put("estado", 1); //Largo de fila inválido.
                return salida;
            }
            //valida largo campo rut -----------------------------------------------
            if (campos[0].length() < 7 || campos[0].length() > 8) {
                System.out.println("Largo de rut invalido. Largo encontrado: " + campos[0].length());
                salida.put("rut", campos[0]);
                salida.put("mensaje", "Largo de rut inválido. Largo encontrado: " + campos[0].length());
                salida.put("fila", (fila + 1));
                salida.put("estado", 1);
                return salida;
            }
            //Valida campo rut numérico --------------------------------------------
            try {
                int rut = Integer.parseInt(campos[0]);
            } catch (NumberFormatException ex) {
                System.out.println("Rut no numérico");
                salida.put("rut", campos[0]);
                salida.put("mensaje", "Rut no numérico");
                salida.put("fila", (fila + 1));
                salida.put("estado", 1);
                return salida;
            }
            //Valida dv ------------------------------------------------------------
            if (!new modelo.Util().validarRut(campos[0].concat(campos[1]))) {
                System.out.println("Rut inválido");
                salida.put("rut", campos[0]);
                salida.put("mensaje", "Validación de rut incorrecta. Dígito verificador no corresponde.");
                salida.put("fila", (fila + 1));
                salida.put("estado", 1);
                return salida;
            }
        } catch (Exception ex) {
            System.out.println("Error al validar la fila:");
            System.out.println(ex);
            salida.put("rut", "-1");
            salida.put("mensaje", "No se puede validar la fila.");
            salida.put("fila", (fila + 1));
            salida.put("estado", 1);
            return salida;
        }
        salida.put("estado", 0); //Resultado ok.
        salida.put("fila", (fila + 1));

        return salida;
    }
    
    private JSONObject getIdNewRutero(){
        JSONObject salida = new JSONObject();
        
        return salida;
    }

}
