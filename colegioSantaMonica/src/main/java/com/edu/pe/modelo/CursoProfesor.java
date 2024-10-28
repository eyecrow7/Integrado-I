package com.edu.pe.modelo;

import java.util.ArrayList;
import java.util.List;

public class CursoProfesor {

    private int idCursoProf;
    private int idSeccion;
    private int idCurso;
    private String nombreCurso;
    private int horas;
    private int creditos;
    private String nivel;
    private String nroGrado;
    private String letra;
    private int nroDiaAct;
    private boolean marcacion;
    private List<HorarioCurso> horarios = new ArrayList<>();

    public CursoProfesor() {
        this.marcacion = false;
    }

    public int getIdCursoProf() {
        return idCursoProf;
    }

    public void setIdCursoProf(int idCursoProf) {
        this.idCursoProf = idCursoProf;
    }

    public int getIdSeccion() {
        return idSeccion;
    }

    public void setIdSeccion(int idSeccion) {
        this.idSeccion = idSeccion;
    }

    public int getIdCurso() {
        return idCurso;
    }

    public void setIdCurso(int idCurso) {
        this.idCurso = idCurso;
    }

    public String getNombreCurso() {
        return nombreCurso;
    }

    public void setNombreCurso(String nombreCurso) {
        this.nombreCurso = nombreCurso;
    }

    public int getHoras() {
        return horas;
    }

    public void setHoras(int horas) {
        this.horas = horas;
    }

    public int getCreditos() {
        return creditos;
    }

    public void setCreditos(int creditos) {
        this.creditos = creditos;
    }

    public List<HorarioCurso> getHorarios() {
        return horarios;
    }

    public void setHorarios(List<HorarioCurso> horarios) {
        this.horarios = horarios;
    }

    public String getNroGrado() {
        return nroGrado;
    }

    public void setNroGrado(String nroGrado) {
        this.nroGrado = nroGrado;
    }

    public String getNivel() {
        return nivel;
    }

    public void setNivel(String nivel) {
        this.nivel = nivel;
    }

    public String getLetra() {
        return letra;
    }

    public void setLetra(String letra) {
        this.letra = letra;
    }

    public int getNroDiaAct() {
        return nroDiaAct;
    }

    public void setNroDiaAct(int nroDiaAct) {
        this.nroDiaAct = nroDiaAct;
    }

    public boolean isMarcacion() {
        return marcacion;
    }

    public void setMarcacion(boolean marcacion) {
        this.marcacion = marcacion;
    }

}
