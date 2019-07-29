package modelo;

import java.util.LinkedList;

public class Campana {
    private int id;
    private Producto producto;
    private LinkedList<SubProducto> subProductos;
    
    private String codigo, nombre;
    private String fechaIni, fechaFin;
    private int meta;

    public Campana(int id, Producto producto, LinkedList<SubProducto> subProductos, String codigo, String nombre, String fechaIni, String fechaFin, int meta) {
	this.id = id;
	this.producto = producto;
	this.subProductos = subProductos;
	this.codigo = codigo;
	this.nombre = nombre;
	this.fechaIni = fechaIni;
	this.fechaFin = fechaFin;
	this.meta = meta;
    }

    public Campana(Producto producto, LinkedList<SubProducto> subProductos, String codigo, String nombre, String fechaIni, String fechaFin, int meta) {
	this.producto = producto;
	this.subProductos = subProductos;
	this.codigo = codigo;
	this.nombre = nombre;
	this.fechaIni = fechaIni;
	this.fechaFin = fechaFin;
	this.meta = meta;
    }

    public int getId() {
	return id;
    }

    public void setId(int id) {
	this.id = id;
    }

    public Producto getProducto() {
	return producto;
    }

    public void setProducto(Producto producto) {
	this.producto = producto;
    }

    public LinkedList<SubProducto> getSubProductos() {
	return subProductos;
    }

    public void setSubProductos(LinkedList<SubProducto> subProductos) {
	this.subProductos = subProductos;
    }

    public String getCodigo() {
	return codigo;
    }

    public void setCodigo(String codigo) {
	this.codigo = codigo;
    }

    public String getNombre() {
	return nombre;
    }

    public void setNombre(String nombre) {
	this.nombre = nombre;
    }

    public String getFechaIni() {
	return fechaIni;
    }

    public void setFechaIni(String fechaIni) {
	this.fechaIni = fechaIni;
    }

    public String getFechaFin() {
	return fechaFin;
    }

    public void setFechaFin(String fechaFin) {
	this.fechaFin = fechaFin;
    }

    public int getMeta() {
	return meta;
    }

    public void setMeta(int meta) {
	this.meta = meta;
    }
    
}
