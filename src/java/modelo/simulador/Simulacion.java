package modelo.simulador;

import java.util.LinkedList;

public class Simulacion {
    private int cuotas;
    private double monto;
    private float tasaMensual;
    private float impuesto;
    private int montoAfecto;
    private int montoNoAfecto;
    private int montoACapitalizar;
    private int costoTotal;
    private int UF;
    private int topeUF;
    private int montoTope;
    
    private LinkedList<Object[]> subproductos; // Estructura: {Subproducto, int(montoCalculado)}

    public Simulacion(int cuotas, double monto, LinkedList<Object[]> subproductos) {
        this.cuotas = cuotas;
        this.monto = monto;
        this.subproductos = subproductos;
    }

    public Simulacion() {
    }

    public int getCuotas() {
        return cuotas;
    }

    public void setCuotas(int cuotas) {
        this.cuotas = cuotas;
    }

    public double getMonto() {
        return monto;
    }

    public void setMonto(double monto) {
        this.monto = monto;
    }

    public LinkedList<Object[]> getSubproductos() {
        return subproductos;
    }

    public void setSubproductos(LinkedList<Object[]> subproductos) {
        this.subproductos = subproductos;
    }
    
    
}
