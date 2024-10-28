package com.edu.pe.modelo.dao;

import com.edu.pe.config.Conexion;
import com.edu.pe.dto.UsuarioDTO;
import com.edu.pe.modelo.PeriodoLectivo;
import com.edu.pe.util.JsonUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class PeriodoLectivoDAO {

    private static final Logger logger = LoggerFactory.getLogger(PeriodoLectivoDAO.class);

    private Connection connection;

    public PeriodoLectivoDAO() {
        this.connection = Conexion.getInstance().getConnection();
    }

    public PeriodoLectivo ObtenerPeriodoVigente() {
        String methodName = new Throwable().getStackTrace()[0].getMethodName();
        logger.info("Método: {}", methodName);

        PeriodoLectivo obj = null;

        try {
            String sql = "select * from periodo_lectivo where vigente = 1";
            PreparedStatement ps = connection.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                obj = new PeriodoLectivo();
                obj.setIdPeriodo(rs.getInt("id_periodo"));
                obj.setNombrePeriodo(rs.getString("nombre_periodo"));
                obj.setVigente(rs.getInt("vigente"));
            }

            logger.info("Resultado: {}", JsonUtil.toJsonValueAsString(obj));
        } catch (Exception e) {
            logger.error("Error en el método {}: {}", methodName, e.getMessage(), e);
            e.printStackTrace();
        }

        return obj;
    }

}
