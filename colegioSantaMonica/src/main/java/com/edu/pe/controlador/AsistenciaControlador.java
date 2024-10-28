package com.edu.pe.controlador;

import com.edu.pe.dto.UsuarioDTO;
import com.edu.pe.modelo.AlumnoAsistencia;
import com.edu.pe.modelo.CursoProfesor;
import com.edu.pe.modelo.Grado;
import com.edu.pe.modelo.HorarioCurso;
import com.edu.pe.modelo.PeriodoLectivo;
import com.edu.pe.modelo.dao.AlumnoAsistenciaDAO;
import com.edu.pe.modelo.dao.CursoProfesorDAO;
import com.edu.pe.modelo.dao.GradoDAO;
import com.edu.pe.modelo.dao.HorarioCursoDAO;
import com.edu.pe.modelo.dao.PeriodoLectivoDAO;
import com.google.gson.Gson;
import jakarta.servlet.ServletConfig;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.ByteArrayOutputStream;
import java.io.OutputStream;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.apache.poi.ss.usermodel.BorderStyle;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.FillPatternType;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.HorizontalAlignment;
import org.apache.poi.ss.usermodel.IndexedColors;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.VerticalAlignment;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@WebServlet(name = "AsistenciaControlador", urlPatterns = {"/asistencia"})
public class AsistenciaControlador extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(AsistenciaControlador.class);
    private UsuarioDTO usuario;
    private AlumnoAsistenciaDAO alumnoAsistenciaDao;
    private CursoProfesorDAO cursoProfDao;
    private PeriodoLectivoDAO periodoLectivoDao;
    private HorarioCursoDAO horarioCursoDao;
    private GradoDAO gradoDao;

    @Override
    public void init(ServletConfig config) throws ServletException {
        cursoProfDao = new CursoProfesorDAO();
        periodoLectivoDao = new PeriodoLectivoDAO();
        horarioCursoDao = new HorarioCursoDAO();
        alumnoAsistenciaDao = new AlumnoAsistenciaDAO();
        gradoDao = new GradoDAO();
    }

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        usuario = (UsuarioDTO) request.getSession().getAttribute("usuario");
        String accion = request.getParameter("accion");

        switch (accion) {
            case "marcar":
                marcar(request, response);
                break;
            case "procesar":
                procesarAsistencia(request, response);
                break;
            case "rectificacion":
                rectificacion(request, response);
                break;
            case "listar_alumnos_inscritos_rectificacion":
                listarAlumnosInscritosRectificacion(request, response);
                break;
            case "procesar_rectificacion":
                procesarRectificacion(request, response);
                break;
            case "exportarExcelAlumnos":
                exportarAlumnosExcel(request, response);
                break;

        }
    }

    protected void procesarRectificacion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HashMap<String, Object> data = new HashMap<String, Object>();
        PrintWriter out = response.getWriter();
        String methodName = new Throwable().getStackTrace()[0].getMethodName();
        try {
            int idSeccion = Integer.parseInt(request.getParameter("idSeccion"));
            int idCursoProf = Integer.parseInt(request.getParameter("idCursoProf"));
            String[] idsAlumnos = request.getParameter("idAlumno").split(";"); // Split by semicolon
            String[] idsAsistencia = request.getParameter("idAsistencia").split(";"); // Split by semicolon
            String[] asistencias = request.getParameter("asistencias").split(";"); // Split by semicolon
            String fecha = request.getParameter("fecha");

            logger.info("Método: {}, Param idsAlumnos: {}", methodName, Arrays.toString(idsAlumnos));
            logger.info("Método: {}, Param idsAsistencia: {}", methodName, Arrays.toString(idsAsistencia));
            logger.info("Método: {}, Param asistencias: {}", methodName, Arrays.toString(asistencias));
            logger.info("Método: {}, Param idSeccion: {}", methodName, idSeccion);
            logger.info("Método: {}, Param idCursoProf: {}", methodName, idCursoProf);
            logger.info("Método: {}, Param fecha: {}", methodName, fecha);

            String result = "";
            int contExito = 0;

            for (int i = 0; i < idsAlumnos.length; i++) {
                int idAlumno = Integer.parseInt(idsAlumnos[i]);
                String asistio = asistencias[i];

                AlumnoAsistencia obj = new AlumnoAsistencia();
                obj.setIdSeccion(idSeccion);
                obj.setIdCursoProf(idCursoProf);
                obj.setIdAlumno(idAlumno);
                obj.setFecha(fecha);
                obj.setIdAsisAlu(Integer.parseInt(idsAsistencia[i]));
                obj.setAsistio((asistio.equals("1")) ? 1 : 0);

                result = alumnoAsistenciaDao.GuardarAsistencia(obj);

                if (result.equals("OK")) {
                    contExito++;
                }
            }

            if (contExito == idsAlumnos.length) {
                data.put("msg", "OK");
            } else {
                if (contExito == 0) {
                    data.put("msg", "No se pudo procesar marcación estudiantil.");
                } else {
                    data.put("msg", "Se procesó marcación, pero hay algunos que no se pudieron procesar.");
                }
            }
        } catch (Exception e) {
            data.put("msg", e.getMessage());
            logger.error("Error en el método {}: {}", methodName, e.getMessage(), e);
        }

        out.print(new Gson().toJson(data));
    }

    protected void listarAlumnosInscritosRectificacion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        PrintWriter out = response.getWriter();
        int idSeccion = Integer.parseInt(request.getParameter("seccion"));
        int idCursoProf = Integer.parseInt(request.getParameter("curso"));
        String fecha = request.getParameter("fecha");

        List<AlumnoAsistencia> lista = alumnoAsistenciaDao.ObtenerAlumnosPorFecha(idSeccion,
                idCursoProf, fecha);

        out.print(new Gson().toJson(lista));
    }

    protected void rectificacion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("periodo_vigente", periodoLectivoDao.ObtenerPeriodoVigente());
        PeriodoLectivo objPeriodo = periodoLectivoDao.ObtenerPeriodoVigente();
        List<Grado> lista = new ArrayList<>();
        if (objPeriodo != null) {
            lista = gradoDao.ListarGradoPorProf(usuario.getId(), objPeriodo.getIdPeriodo());
        }
        request.setAttribute("grados", lista);
        request.getRequestDispatcher("pagRectificacionAsistencia.jsp").forward(request, response);
    }

    protected void procesarAsistencia(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String methodName = new Throwable().getStackTrace()[0].getMethodName();
        int idSeccion = Integer.parseInt(request.getParameter("idSeccion"));
        int idCursoProf = Integer.parseInt(request.getParameter("idCursoProf"));
        String[] idsAlumnos = request.getParameterValues("idAlumno");
        String[] idsAsistencia = request.getParameterValues("idAsistencia");
        LocalDate fechaActual = LocalDate.now();
        String fechaActualStr = fechaActual.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));

        logger.info("Método: {}, Param idsAlumnos: {}", methodName, Arrays.toString(idsAlumnos));
        logger.info("Método: {}, Param idsAlumnos: {}", methodName, Arrays.toString(idsAsistencia));
        logger.info("Método: {}, Param idSeccion: {}", methodName, idSeccion);
        logger.info("Método: {}, Param idCursoProf: {}", methodName, idCursoProf);

        String result = "";
        int contExito = 0;

        for (int i = 0; i < idsAlumnos.length; i++) {
            int idAlumno = Integer.parseInt(idsAlumnos[i]);
            String asistio = request.getParameter("asistio_" + idAlumno);

            AlumnoAsistencia obj = new AlumnoAsistencia();
            obj.setIdSeccion(idSeccion);
            obj.setIdCursoProf(idCursoProf);
            obj.setIdAlumno(idAlumno);
            obj.setFecha(fechaActualStr);
            obj.setIdAsisAlu(Integer.parseInt(idsAsistencia[i]));
            obj.setAsistio((asistio != null && asistio.equals("1")) ? 1 : 0);

            result = alumnoAsistenciaDao.GuardarAsistencia(obj);

            if (result.equals("OK")) {
                contExito++;
            }
        }

        if (contExito == idsAlumnos.length) {
            request.getSession().setAttribute("success", "Se procesó de forma correcta la marcación");
        } else {
            if (contExito == 0) {
                request.getSession().setAttribute("error", "No se pudo procesar marcación estudiantil.");
            } else {
                request.getSession().setAttribute("info", "Se procesó marcación, pero hay algunos que no se pudieron procesar.");
            }
        }

        response.sendRedirect("asistencia?accion=marcar&curso=" + idCursoProf);
    }

    protected void marcar(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int idCursoProf = Integer.parseInt(request.getParameter("curso"));

        CursoProfesor obj = cursoProfDao.CursoProfesorPorId(idCursoProf);

        if (obj == null) {
            request.getSession().setAttribute("error", "Lo sentimos! No se encontró curso profesor.");
            response.sendRedirect("main?accion=inicio");
            return;
        }

        obj.setHorarios(horarioCursoDao.listarHorarioCursoPorCursoProf(obj.getIdCursoProf()));

        for (HorarioCurso item : obj.getHorarios()) {
            if (item.getNroDia() == obj.getNroDiaAct()) {
                obj.setMarcacion(true);
                break;
            }
        }

        request.setAttribute("periodo_vigente", periodoLectivoDao.ObtenerPeriodoVigente());
        request.setAttribute("seccion", obj);
        request.setAttribute("asistencia", alumnoAsistenciaDao.ObtenerAlumnosDelDia(obj.getIdSeccion(), obj.getIdCursoProf()));
        request.getRequestDispatcher("pagMarcarAsistencia.jsp").forward(request, response);
    }

    protected void exportarAlumnosExcel(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        String methodName = new Throwable().getStackTrace()[0].getMethodName();
        try {
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setHeader("Content-Disposition", "attachment; filename=reporte_consulta_alumnos.xlsx");

            String[] columnas = {"#", "Ape. Paterno", "Ape. Materno", "Nombres", "Correo"};

            XSSFWorkbook workbook = new XSSFWorkbook();

            ByteArrayOutputStream stream = new ByteArrayOutputStream();
            XSSFSheet hoja = workbook.createSheet();
            Row fila = hoja.createRow(0);
            CellStyle cabeceraEstilo = workbook.createCellStyle();
            cabeceraEstilo.setFillForegroundColor(IndexedColors.OLIVE_GREEN.getIndex());
            cabeceraEstilo.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            cabeceraEstilo.setBorderBottom(BorderStyle.THIN);
            cabeceraEstilo.setBorderLeft(BorderStyle.THIN);
            cabeceraEstilo.setBorderRight(BorderStyle.THIN);
            cabeceraEstilo.setBorderBottom(BorderStyle.THIN);
            cabeceraEstilo.setAlignment(HorizontalAlignment.CENTER);
            cabeceraEstilo.setVerticalAlignment(VerticalAlignment.CENTER);

            Font fuenteCabecera = workbook.createFont();
            fuenteCabecera.setFontName("Arial");
            fuenteCabecera.setBold(true);
            fuenteCabecera.setFontHeightInPoints((short) 12);
            fuenteCabecera.setColor(IndexedColors.WHITE.getIndex());
            cabeceraEstilo.setFont(fuenteCabecera);
            hoja.setDefaultColumnWidth(20);
            hoja.setDefaultRowHeightInPoints(20);

            for (int i = 0; i < columnas.length; i++) {
                Cell cell = fila.createCell(i);
                cell.setCellStyle(cabeceraEstilo);
                cell.setCellValue(columnas[i]);

            }

            int idSeccion = Integer.parseInt(request.getParameter("seccion"));
            List<AlumnoAsistencia> lista = alumnoAsistenciaDao.ObtenerAlumnosPorSeccion(idSeccion);
            int initRow = 1;
            for (AlumnoAsistencia c : lista) {
                fila = hoja.createRow(initRow);
                fila.createCell(0).setCellValue(initRow);
                fila.createCell(1).setCellValue(c.getApePaterno());
                fila.createCell(2).setCellValue(c.getApeMaterno());
                fila.createCell(3).setCellValue(c.getNombres());
                fila.createCell(4).setCellValue(c.getCorreo());

                initRow++;
            }

            ByteArrayOutputStream outByteStream = new ByteArrayOutputStream();
            workbook.write(outByteStream);
            byte[] outArray = outByteStream.toByteArray();
            OutputStream outStream = response.getOutputStream();
            outStream.write(outArray);
            outStream.flush();

        } catch (Exception e) {
            logger.error("Error en el método {}: {}", methodName, e.getMessage(), e);
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
