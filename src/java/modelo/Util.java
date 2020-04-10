package modelo;

import java.io.BufferedInputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class Util {

    public static int generaRandom(int ini, int fin) {
        return (int) Math.floor(Math.random() * (fin - ini + 1) + ini);
    }

    public static String hashMD5(String texto) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] hashInBytes = md.digest(texto.getBytes(StandardCharsets.UTF_8));

            StringBuilder sb = new StringBuilder();
            for (byte b : hashInBytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException ex) {
            System.out.println("Problemas al cifrar el mensaje");
            System.out.println(ex);
            return "";
        }

    }

    public static String armarSelect(ResultSet rs, String primerItemValue, String primerItemText, String colValues, String colTextos) {
        String salida = "<option value='" + primerItemValue + "'>" + primerItemText + "</option>";
        try {
            while (rs.next()) {
                salida += "<option value='" + rs.getString(colValues) + "'>" + rs.getString(colTextos) + "</option>";
            }
        } catch (SQLException ex) {
            System.out.println("No se puede armar el select.");
            System.out.println(ex);
        }
        return salida;
    }

    public static float redondearDecimales(float numero, int cantDecimales) {
        BigDecimal bd = new BigDecimal(Float.toString(numero));
        bd = bd.setScale(cantDecimales, BigDecimal.ROUND_HALF_UP);
        return bd.floatValue();
    }

    public static BigDecimal redondear(float numero, int cantDecimales) {
        BigDecimal bd = new BigDecimal(Float.toString(numero));
        bd = bd.setScale(cantDecimales, BigDecimal.ROUND_HALF_UP);
        return bd;
    }

    public static String formatRut(String rut) {

        int cont = 0;
        String format;
        rut = rut.replace(".", "");
        rut = rut.replace("-", "");
        format = "-" + rut.substring(rut.length() - 1);
        for (int i = rut.length() - 2; i >= 0; i--) {
            format = rut.substring(i, i + 1) + format;
            cont++;
            if (cont == 3 && i != 0) {
                format = "." + format;
                cont = 0;
            }
        }
        return format;
    }

    public static boolean validarRut(String rut) {

        boolean validacion = false;
        try {
            rut = rut.toUpperCase();
            rut = rut.replace(".", "");
            rut = rut.replace("-", "");
            int rutAux = Integer.parseInt(rut.substring(0, rut.length() - 1));

            char dv = rut.charAt(rut.length() - 1);

            int m = 0, s = 1;
            for (; rutAux != 0; rutAux /= 10) {
                s = (s + rutAux % 10 * (9 - m++ % 6)) % 11;
            }
            if (dv == (char) (s != 0 ? s + 47 : 75)) {
                validacion = true;
            }

        } catch (java.lang.NumberFormatException e) {
        } catch (Exception e) {
        }
        return validacion;
    }

    public static String formatMiles(String numero) {
        StringBuilder builder = new StringBuilder();
        for (int i = 1, len = builder.length(); i < len; i++) {
            if (i % 4 == 0) {
                builder.insert(len = builder.length() - i, '.');
                len = builder.length();
            }
        }
        return builder.toString();
    }

    public static int cuentaLineasArchivo(String filename) throws IOException {
        InputStream is = new BufferedInputStream(new FileInputStream(filename));
        try {
            byte[] c = new byte[1024];

            int readChars = is.read(c);
            if (readChars == -1) {
                // retorna 0 si no hay nada que leer...
                return 0;
            }

            // make it easy for the optimizer to tune this loop
            int count = 0;
            while (readChars == 1024) {
                for (int i = 0; i < 1024;) {
                    if (c[i++] == '\n') {
                        ++count;
                    }
                }
                readChars = is.read(c);
            }

            // count remaining characters
            while (readChars != -1) {
                //System.out.println(readChars);
                for (int i = 0; i < readChars; ++i) {
                    if (c[i] == '\n') {
                        ++count;
                    }
                }
                readChars = is.read(c);
            }

            return count == 0 ? 1 : count;
        } finally {
            is.close();
        }
    }
    
    public static String getFechaHora(){
        DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
        LocalDateTime now = LocalDateTime.now();
        return dtf.format(now);
    }

}
