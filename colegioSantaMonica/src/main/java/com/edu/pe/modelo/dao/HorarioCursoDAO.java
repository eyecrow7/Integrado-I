package com.edu.pe.modelo.dao;

import com.edu.pe.config.Conexion;
import com.edu.pe.modelo.CursoProfesor;
import com.edu.pe.modelo.HorarioCurso;
import com.edu.pe.util.JsonUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class HorarioCursoDAO {

    private static final Logger logger = LoggerFactory.getLogger(GradoDAO.class);

    private Connection connection;

    public HorarioCursoDAO() {
        this.connection = Conexion.getInstance().getConnection();
    }

    public List<HorarioCurso> listarHorarioCursoPorCursoProf(int idCursoProf) {
        String methodName = new Throwable().getStackTrace()[0].getMethodName();
        logger.info("Método: {}, Param id Curso Profesor: {}", methodName, idCursoProf);

        List<HorarioCurso> lista = new ArrayList<>();

        try {
            String sql = "select * from horario_curso "
                    + " where id_curso_prof = ? "
                    + " order by nro_dia , hora_inicio asc;";
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, idCursoProf);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                HorarioCurso obj = new HorarioCurso();
                obj.setDiaSemana(rs.getString("dia_semana"));
                obj.setHoraInicio(rs.getString("hora_inicio"));
                obj.setHoraFin(rs.getString("hora_fin"));
                obj.setNroDia(rs.getInt("nro_dia"));
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
}
