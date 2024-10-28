package com.edu.pe.modelo.dao;

import com.edu.pe.config.Conexion;
import com.edu.pe.modelo.CursoProfesor;
import com.edu.pe.util.JsonUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CursoProfesorDAO {

    private static final Logger logger = LoggerFactory.getLogger(CursoProfesorDAO.class);
    private Connection connection;

    public CursoProfesorDAO() {
        this.connection = Conexion.getInstance().getConnection();
    }

    public List<CursoProfesor> CursoProfesor(int idProf) {
        String methodName = new Throwable().getStackTrace()[0].getMethodName();
        logger.info("Método: {}, Param id Profesor: {}", methodName, idProf);

        List<CursoProfesor> lista = new ArrayList<>();

        try {
            String sql = "select * from curso_profesor c inner join seccion s on s.id_seccion = c.id_seccion\n"
                    + "inner join curso cur on cur.id_curso = c.id_curso\n"
                    + "inner join grado g on g.id_grado = s.id_grado\n"
                    + "where c.id_profesor = ?\n"
                    + "order by s.id_seccion asc , c.id_profesor asc , c.id_curso";
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, idProf);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                CursoProfesor obj = new CursoProfesor();
                obj.setIdSeccion(rs.getInt("id_seccion"));
                obj.setIdCurso(rs.getInt("id_curso"));
                obj.setNivel(rs.getString("nivel"));
                obj.setNroGrado(rs.getString("nro"));
                obj.setNombreCurso(rs.getString("nombre_curso"));
                obj.setHoras(rs.getInt("horas"));
                obj.setLetra(rs.getString("letra"));
                obj.setIdCursoProf(rs.getInt("id_curso_prof"));

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

    public CursoProfesor CursoProfesorPorId(int idCursoProf) {
        String methodName = new Throwable().getStackTrace()[0].getMethodName();
        logger.info("Método: {}, Param id Curso Profesor: {}", methodName, idCursoProf);

        CursoProfesor obj = null;

        try {
            String sql = "select c.* , s.* , cur.* , g.*,\n" +
                        "(WEEKDAY(CURDATE()) + 1)\n" +
                        " AS marcar_asistencia\n" +
                        "from curso_profesor c inner join seccion s on s.id_seccion = c.id_seccion\n" +
                        "inner join curso cur on cur.id_curso = c.id_curso\n" +
                        "inner join grado g on g.id_grado = s.id_grado\n" +
                        "where c.id_curso_prof =?\n" +
                        "order by s.id_seccion asc , c.id_profesor asc , c.id_curso;";
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, idCursoProf);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                obj = new CursoProfesor();
                obj.setIdSeccion(rs.getInt("id_seccion"));
                obj.setIdCurso(rs.getInt("id_curso"));
                obj.setNivel(rs.getString("nivel"));
                obj.setNroGrado(rs.getString("nro"));
                obj.setNombreCurso(rs.getString("nombre_curso"));
                obj.setHoras(rs.getInt("horas"));
                obj.setLetra(rs.getString("letra"));
                obj.setIdCursoProf(rs.getInt("id_curso_prof"));
                obj.setNroDiaAct(rs.getInt("marcar_asistencia"));
            }

            logger.info("Método: {}, Data: {}", methodName, JsonUtil.toJsonValueAsString(obj));
        } catch (Exception e) {
            logger.error("Error en el método {}: {}", methodName, e.getMessage(), e);
            e.printStackTrace();
        }

        return obj;
    }
}
