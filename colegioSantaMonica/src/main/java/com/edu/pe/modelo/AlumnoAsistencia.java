package com.edu.pe.modelo;

public class AlumnoAsistencia {

    private int idAsisAlu;
    private int idAlumno;
    private int idCursoProf;
    private String nombres;
    private String apePaterno;
    private String apeMaterno;
    private int asistio;
    private String correo;
    private String fecha;
    private String hora;
    private int idSeccion;

    public int getIdAsisAlu() {
        return idAsisAlu;
    }

    public void setIdAsisAlu(int idAsisAlu) {
        this.idAsisAlu = idAsisAlu;
    }

    public int getIdAlumno() {
        return idAlumno;
    }

    public void setIdAlumno(int idAlumno) {
        this.idAlumno = idAlumno;
    }

    public String getNombres() {
        return nombres;
    }

    public void setNombres(String nombres) {
        this.nombres = nombres;
    }

    public String getApePaterno() {
        return apePaterno;
    }

    public void setApePaterno(String apePaterno) {
        this.apePaterno = apePaterno;
    }

    public String getApeMaterno() {
        return apeMaterno;
    }

    public void setApeMaterno(String apeMaterno) {
        this.apeMaterno = apeMaterno;
    }

    public int getAsistio() {
        return asistio;
    }

    public void setAsistio(int asistio) {
        this.asistio = asistio;
    }

    public String getCorreo() {
        return correo;
    }

    public void setCorreo(String correo) {
        this.correo = correo;
    }

    public int getIdCursoProf() {
        return idCursoProf;
    }

    public void setIdCursoProf(int idCursoProf) {
        this.idCursoProf = idCursoProf;
    }

    public String getFecha() {
        return fecha;
    }

    public void setFecha(String fecha) {
        this.fecha = fecha;
    }

    public String getHora() {
        return hora;
    }

    public void setHora(String hora) {
        this.hora = hora;
    }

    public int getIdSeccion() {
        return idSeccion;
    }

    public void setIdSeccion(int idSeccion) {
        this.idSeccion = idSeccion;
    }

}
