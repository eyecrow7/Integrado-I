package com.edu.pe.modelo.dao;

import com.edu.pe.config.Conexion;
import com.edu.pe.modelo.Curso;
import com.edu.pe.modelo.CursoProfesor;
import com.edu.pe.util.JsonUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CursoDAO {

    private static final Logger logger = LoggerFactory.getLogger(CursoDAO.class);
    private Connection connection;

    public CursoDAO() {
        this.connection = Conexion.getInstance().getConnection();
    }

    public List<Curso> CursoPorSeccion(int idSeccion, int idProf) {
        String methodName = new Throwable().getStackTrace()[0].getMethodName();
        logger.info("Método: {}, Param id Seccion: {}", methodName, idSeccion);
        logger.info("Método: {}, Param id Profesor: {}", methodName, idProf);

        List<Curso> lista = new ArrayList<>();

        try {
            String sql = "select * from curso_profesor c inner join curso cur on cur.id_Curso = c.id_curso\n"
                    + "where id_seccion = ? and id_profesor = ?\n"
                    + "order by nombre_curso asc";
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, idSeccion);
            ps.setInt(2, idProf);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Curso obj = new Curso();
                obj.setIdCurso(rs.getInt("id_curso"));
                obj.setNombreCurso(rs.getString("nombre_curso"));
                obj.setIdCursoProf(rs.getInt("id_curso_prof"));
                lista.add(obj);
            }

            logger.info("Método: {}, Data: {}", methodName, JsonUtil.toJsonValueAsString(lista));
        } catch (Exception e) {
            logger.error("Error en el método {}: {}", methodName, e.getMessage(), e);
            e.printStackTrace();
        }

        return lista;
    }

    public List<String> FechasPorCurso(int idPeriodo, int idCursoProf) {
        String methodName = new Throwable().getStackTrace()[0].getMethodName();
        logger.info("Método: {}, Param id Periodo: {}", methodName, idPeriodo);
        logger.info("Método: {}, Param id Curso Profesor: {}", methodName, idCursoProf);

        List<String> lista = new ArrayList<>();

        try {
            PreparedStatement ps = connection.prepareStatement("{call sp_obtener_fecha_curso(?,?)}");
            ps.setInt(1, idPeriodo);
            ps.setInt(2, idCursoProf);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                lista.add(rs.getString(1));
            }

            logger.info("Método: {}, Data: {}", methodName, JsonUtil.toJsonValueAsString(lista));
        } catch (Exception e) {
            logger.error("Error en el método {}: {}", methodName, e.getMessage(), e);
            e.printStackTrace();
        }

        return lista;
    }

}
