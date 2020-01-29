package controlador;

import clases.json.JSONObject;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.util.List;
import java.util.Properties;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

public class UploadServlet extends HttpServlet {

    private static final int MEMORY_THRESHOLD = 1024 * 1024 * 3;  // 3MB
    private static final int MAX_FILE_SIZE = 1024 * 1024 * 100; // 100MB
    private static final int MAX_REQUEST_SIZE = 1024 * 1024 * 100; // 100MB
    private static final String RUTA_PROPERTIES = System.getenv("PANEL_PROPERTIES");
    private static String RUTA_RUTEROS = "";
    private static String RUTA_LOGS_RUTEROS = "";
    private static String TIPOOPERACION = "";
    private static String IDCAMPANA = "";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Parametrización ruta de archivos-------------------------------------
        InputStream inStream = new FileInputStream(RUTA_PROPERTIES);
        Properties prop = new Properties();
        prop.load(inStream);
        RUTA_RUTEROS = prop.getProperty("dir.ruteros.proceso.linux");
        RUTA_LOGS_RUTEROS = prop.getProperty("dir.ruteros.logs.linux");
        //----------------------------------------------------------------------
        request.getSession().removeAttribute("nombreArchivo");
        PrintWriter out = response.getWriter();
        response.setContentType("text/html; charset=UTF-8");

        if (ServletFileUpload.isMultipartContent(request)) {

            DiskFileItemFactory factory = new DiskFileItemFactory();
            factory.setSizeThreshold(MEMORY_THRESHOLD);
            File repository = new File(System.getProperty("java.io.tmpdir"));
            factory.setRepository(repository);
            ServletFileUpload upload = new ServletFileUpload(factory);
            upload.setFileSizeMax(MAX_FILE_SIZE);
            upload.setSizeMax(MAX_REQUEST_SIZE);
            String uploadPath = RUTA_RUTEROS;
            try {
                List<FileItem> images = upload.parseRequest(request);
                if (images != null && images.size() > 0) {
                    for (FileItem image : images) {
                        if (!image.isFormField()) {
                            String filePath = uploadPath + File.separator + image.getName();
                            File storeFile = new File(filePath);
                            if (storeFile.exists() && storeFile.isFile()) {
                                JSONObject salida = new JSONObject();
                                salida.put("estado", "error");
                                salida.put("mensaje", "El archivo que intenta ingresar ya existe (" + image.getName() + "). Debe ingresar uno distinto.");
                                request.getSession().removeAttribute("nombreArchivo");
                                out.print(salida);
                                return;
                            }
                            image.write(storeFile);
                            request.getSession().removeAttribute("nombreArchivo");
                            request.getSession().setAttribute("nombreArchivo", uploadPath + File.separator + image.getName());
                            System.out.println("Ruta guardada en sesion: " + request.getSession().getAttribute("nombreArchivo"));
                            File logCarga = new File(RUTA_LOGS_RUTEROS + File.separator + image.getName() + ".log");
                            FileWriter fr = new FileWriter(logCarga);
                            fr.write("Inicio proceso de carga");
                            fr.close();
                            out.print(procesarContenidoRutero(storeFile));
                        }
                    }
                } else {
                    out.print("Ho hay archivos");
                }
            } catch (Exception ex) {
                request.getSession().removeAttribute("nombreArchivo");
                JSONObject salida = new JSONObject();
                salida.put("estado", "error");
                salida.put("mensaje", "Consultar log de Java. No se pudo cargar el archivo.");
                out.print(salida);
                System.out.println("Error al cargar el archivo.");
                System.out.println(ex);
            }
        } else {
            JSONObject salida = new JSONObject();
            request.getSession().removeAttribute("nombreArchivo");
            salida.put("estado", "error");
            salida.put("mensaje", "Consultar log de Java. No se pudo cargar el archivo.");
            System.out.println("Error. Tipo de contenido en formulario HTML no corresponde con: enctype='multipart/form-data'");
            System.out.println("No se puede rescatar el archivo del formulario.");
        }
    }

    private JSONObject procesarContenidoRutero(File archivo) {
        int cont = 0;
        int filasBuenas = 0;
        int filasMalas = 0;
        int filasProcesadas = 0;

        try {
            BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream(archivo), "UTF-8"));

            String linea;
            while ((linea = reader.readLine()) != null) {
                if (cont > 0) {//Saltar cabecera
                    if (procesarFila(linea, cont, archivo.getName())) {
                        filasBuenas++;
                    } else {
                        filasMalas++;
                    }
                    filasProcesadas++;
                }
                cont++;
            }
        } catch (IOException ex) {
            JSONObject salida = new JSONObject();
            salida.put("filasBuenas", filasBuenas);
            salida.put("filasMalas", filasMalas);
            salida.put("filasProcesadas", filasProcesadas);
            salida.put("estado", "error");
            return salida;
        }

        JSONObject salida = new JSONObject();
        salida.put("filasBuenas", filasBuenas);
        salida.put("filasMalas", filasMalas);
        salida.put("filasProcesadas", filasProcesadas);
        salida.put("estado", "ok");
        return salida;
    }

    private boolean procesarFila(String fila, int fil, String nomarchivo) {
        File logCarga = new File(RUTA_LOGS_RUTEROS + File.separator + nomarchivo + ".log");

        //[VALIDACIONES]--------------------------------------------------------
        try {
            String[] campos = fila.split(";");
            FileWriter fr = new FileWriter(logCarga, true);

            //Validar Largo --------------------------------------------------------
            if (campos.length < 19) {
                System.out.println("[Fila: " + fil + "] Largo invalido");
                fr.write("[Fila: " + fil + "] Largo invalido" + System.getProperty("line.separator"));
                fr.close();
                return false;
            }
            //Validar rut numérico------------------------------------------------
            try {
                int rut = Integer.parseInt(campos[0]);
            } catch (NumberFormatException ex) {
                System.out.println("[Fila: " + fil + "] Caracter inválido en rut.");
                fr.write("[Fila: " + fil + "] Caracter inválido en rut." + System.getProperty("line.separator"));
                fr.close();
                return false;
            }
            //valida largo campo rut -----------------------------------------------
            if (campos[0].trim().length() < 7 || campos[0].trim().length() > 8) {
                System.out.println("[Fila: " + fil + "] Largo de rut invalido. Largo encontrado: " + campos[0].length());
                fr.write("[Fila: " + fil + "] Largo de rut invalido. Largo encontrado: " + campos[0].length() + System.getProperty("line.separator"));
                fr.close();
                return false;
            }
            //Valida campo rut numérico --------------------------------------------
            try {
                int rut = Integer.parseInt(campos[0]);
            } catch (NumberFormatException ex) {
                System.out.println("[Fila: " + fil + "]Rut no numérico");
                fr.write("[Fila: " + fil + "]Rut no numérico" + System.getProperty("line.separator"));
                fr.close();
                return false;
            }
            //Valida dv ------------------------------------------------------------
            if (!new modelo.Util().validarRut(campos[0].concat(campos[1]))) {
                System.out.println("[Fila: " + fil + "] Rut inválido");
                fr.write("[Fila: " + fil + "] Rut inválido" + System.getProperty("line.separator"));
                fr.close();
                return false;
            }
            //Validar largo campo nombres ------------------------------------------
            if (campos[2].length() < 2) {
                System.out.println("[Fila: " + fil + "] Largo de nombres < 2");
                fr.write("[Fila: " + fil + "] Largo de nombres < 2");
                fr.close();
                return false;
            }
            //Validar largo campo apellidos ----------------------------------------
            if (campos[3].length() < 2) {
                System.out.println("[Fila: " + fil + "] Largo de apellidos < 2");
                fr.write("[Fila: " + fil + "] Largo de apellidos < 2" + System.getProperty("line.separator"));
                fr.close();
                return false;
            }
            //validar fono1 numérico -------------------------------------------
            try {
                Integer.parseInt(campos[12]);
            } catch (NumberFormatException ex) {
                System.out.println("[Fila: " + fil + "] fono1 no numérico");
                fr.write("[Fila: " + fil + "] fono1 no numérico" + System.getProperty("line.separator"));
                fr.close();
                return false;
            }
            //validar fono2 numérico -------------------------------------------
            try {
                Integer.parseInt(campos[13]);
            } catch (NumberFormatException ex) {
                System.out.println("[Fila: " + fil + "] fono2 no numérico");
                fr.write("[Fila: " + fil + "] fono2 no numérico" + System.getProperty("line.separator"));
                fr.close();
                return false;
            }
            //validar fono3 numérico -------------------------------------------
            try {
                Integer.parseInt(campos[14]);
            } catch (NumberFormatException ex) {
                System.out.println("[Fila: " + fil + "] fono3 no numérico");
                fr.write("[Fila: " + fil + "] fono3 no numérico" + System.getProperty("line.separator"));
                fr.close();
                return false;
            }
            //Validar largo de fono1 -----------------------------------------------
            if ((campos[12]).trim().length() != 9) {
                System.out.println("[Fila: " + fil + "] Largo de fono1 debe ser de 9");
                fr.write("[Fila: " + fil + "] Largo de fono1 debe ser de 9" + System.getProperty("line.separator"));
                fr.close();
            }
            //Validar largo de fono2 -----------------------------------------------
            if ((campos[13]).trim().length() != 9) {
                System.out.println("[Fila: " + fil + "] Largo de fono2 debe ser de 9");
                fr.write("[Fila: " + fil + "] Largo de fono2 debe ser de 9" + System.getProperty("line.separator"));
                fr.close();
            }
            //Validar largo de fono3 -----------------------------------------------
            if ((campos[14]).trim().length() != 9) {
                System.out.println("[Fila: " + fil + "] Largo de fono3 debe ser de 9");
                fr.write("[Fila: " + fil + "] Largo de fono3 debe ser de 9" + System.getProperty("line.separator"));
                fr.close();
            }
        } catch (Exception ex) {
            System.out.println("[Último contador: " + fil + "] Error al validar la fila:");
            System.out.println(ex);
            return false;
        }

        return true;
    }
}
