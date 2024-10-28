package com.edu.pe.modelo.dao;

import com.edu.pe.config.Conexion;
import com.edu.pe.modelo.AlumnoAsistencia;
import com.edu.pe.modelo.Grado;
import com.edu.pe.modelo.PeriodoLectivo;
import com.edu.pe.util.JsonUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class AlumnoAsistenciaDAO {

    private static final Logger logger = LoggerFactory.getLogger(AlumnoAsistenciaDAO.class);
    private Connection connection;

    public AlumnoAsistenciaDAO() {
        this.connection = Conexion.getInstance().getConnection();
    }

    public List<AlumnoAsistencia> ObtenerAlumnosDelDia(int idSeccion, int idCursoProf) {
        String methodName = new Throwable().getStackTrace()[0].getMethodName();
        logger.info("Método: {}, Param idSeccion: {}", methodName, idSeccion);
        logger.info("Método: {}, Param idCursoProf: {}", methodName, idCursoProf);

        List<AlumnoAsistencia> lista = new ArrayList<>();

        try {
            PreparedStatement ps = connection.prepareStatement("{call sp_list_asistencia_curso(?,?,current_date())}");
            ps.setInt(1, idSeccion);
            ps.setInt(2, idCursoProf);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                AlumnoAsistencia obj = new AlumnoAsistencia();
                obj.setIdAsisAlu(rs.getInt("id_asis_alu"));
                obj.setIdAlumno(rs.getInt("id_alumno"));
                obj.setNombres(rs.getString("nombres"));
                obj.setApePaterno(rs.getString("ape_paterno"));
                obj.setApeMaterno(rs.getString("ape_materno"));
                obj.setCorreo(rs.getString("correo"));
                obj.setAsistio(rs.getInt("asistio"));
                lista.add(obj);
            }

            logger.info("Método: {}, Data: {}", methodName, JsonUtil.toJsonValueAsString(lista));
            logger.info("Método: {}, Cantidad: {}", methodName, lista.size());
        } catch (Exception e) {
            logger.error("Error en el método {}: {}", methodName, e.getMessage(), e);
            e.printStackTrace();
        }

        return lista;
    }

    public List<AlumnoAsistencia> ObtenerAlumnosPorFecha(int idSeccion, int idCursoProf, String fecha) {
        String methodName = new Throwable().getStackTrace()[0].getMethodName();
        logger.info("Método: {}, Param idSeccion: {}", methodName, idSeccion);
        logger.info("Método: {}, Param idCursoProf: {}", methodName, idCursoProf);

        List<AlumnoAsistencia> lista = new ArrayList<>();

        try {
            PreparedStatement ps = connection.prepareStatement("{call sp_list_asistencia_curso(?,?,?)}");
            ps.setInt(1, idSeccion);
            ps.setInt(2, idCursoProf);
            ps.setString(3, fecha);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                AlumnoAsistencia obj = new AlumnoAsistencia();
                obj.setIdAsisAlu(rs.getInt("id_asis_alu"));
                obj.setIdAlumno(rs.getInt("id_alumno"));
                obj.setNombres(rs.getString("nombres"));
                obj.setApePaterno(rs.getString("ape_paterno"));
                obj.setApeMaterno(rs.getString("ape_materno"));
                obj.setCorreo(rs.getString("correo"));
                obj.setAsistio(rs.getInt("asistio"));
                lista.add(obj);
            }

            logger.info("Método: {}, Data: {}", methodName, JsonUtil.toJsonValueAsString(lista));
            logger.info("Método: {}, Cantidad: {}", methodName, lista.size());
        } catch (Exception e) {
            logger.error("Error en el método {}: {}", methodName, e.getMessage(), e);
            e.printStackTrace();
        }

        return lista;
    }

    public String GuardarAsistencia(AlumnoAsistencia obj) {
        String methodName = new Throwable().getStackTrace()[0].getMethodName();
        String result = "";
        logger.info("Método: {} , request:{}", methodName, JsonUtil.toJsonValueAsString(obj));

        try {
            PreparedStatement ps = connection.prepareStatement("{call sp_marcar_asistencia(?,?,?,?,?,?)}");
            ps.setInt(1, obj.getIdSeccion());
            ps.setInt(2, obj.getIdCursoProf());
            ps.setInt(3, obj.getIdAlumno());
            ps.setString(4, obj.getFecha());
            ps.setInt(5, obj.getIdAsisAlu());
            ps.setInt(6, obj.getAsistio());
            result = ps.executeUpdate() > 0 ? "OK" : "No se pudo guardar asistencia";

            logger.info("Resultado: {}", result);
        } catch (Exception e) {
            logger.error("Error en el método {}: {}", methodName, e.getMessage(), e);
            e.printStackTrace();
        }

        return result;
    }

      public List<AlumnoAsistencia> ObtenerAlumnosPorSeccion(int idSeccion) {
        String methodName = new Throwable().getStackTrace()[0].getMethodName();
        logger.info("Método: {}, Param idSeccion: {}", methodName, idSeccion);

        List<AlumnoAsistencia> lista = new ArrayList<>();

        try {
            String sql = "select * from grupo_seccion gs"
                    + "  inner join alumno a on a.id_alumno = gs.id_alumno\n" +
                    "where gs.id_seccion =?";
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, idSeccion);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                AlumnoAsistencia obj = new AlumnoAsistencia();
                obj.setIdAlumno(rs.getInt("id_alumno"));  
                obj.setNombres(rs.getString("nombres"));
                obj.setApePaterno(rs.getString("ape_paterno"));
                obj.setApeMaterno(rs.getString("ape_materno"));
                obj.setCorreo(rs.getString("correo"));
                lista.add(obj);
            }

            logger.info("Método: {}, Data: {}", methodName, JsonUtil.toJsonValueAsString(lista));
        } catch (Exception e) {
            logger.error("Error en el método {}: {}", methodName, e.getMessage(), e);
            e.printStackTrace();
        }

        return lista;
    }

}
