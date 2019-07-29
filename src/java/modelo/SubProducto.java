package modelo;

import java.math.BigDecimal;

public class SubProducto {
    private int id;
    private String codigo, descripcion;
    private BigDecimal prima;
    private Empresa empresa;

    public SubProducto(int id, String codigo, String descripcion, BigDecimal prima, Empresa empresa) {
	this.id = id;
	this.codigo = codigo;
	this.descripcion = descripcion;
	this.prima = prima;
	this.empresa = empresa;
    }

    public SubProducto(String codigo, String descripcion, BigDecimal prima, Empresa empresa) {
	this.codigo = codigo;
	this.descripcion = descripcion;
	this.prima = prima;
	this.empresa = empresa;
    }

    public int getId() {
	return id;
    }

    public void setId(int id) {
	this.id = id;
    }

    public String getCodigo() {
	return codigo;
    }

    public void setCodigo(String codigo) {
	this.codigo = codigo;
    }

    public String getDescripcion() {
	return descripcion;
    }

    public void setDescripcion(String descripcion) {
	this.descripcion = descripcion;
    }

    public BigDecimal getPrima() {
	return prima;
    }

    public void setPrima(BigDecimal prima) {
	this.prima = prima;
    }

    public Empresa getEmpresa() {
	return empresa;
    }

    public void setEmpresa(Empresa empresa) {
	this.empresa = empresa;
    }
    
    
}
