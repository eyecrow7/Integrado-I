<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Colegio Santa Monica</title>
        <meta charset="utf-8">
        <jsp:include page="includes/css.jsp" />

    </head>

    <body>
        <jsp:include page="includes/navegacion.jsp" />
        <jsp:include page="includes/mensaje.jsp" />

        <div class="pcoded-main-container">
            <div class="pcoded-wrapper container-fluid mt-2">
                <div class="main-body">
                    <div class="row">
                        <div class="col-sm-12">
                            <div class="card">
                                <div class="card-header">
                                    <h5>Mi Programa</h5>
                                </div>
                                <div class="card-body">
                                    <c:if test="${periodo_vigente != null}">
                                        <ul class="breadcrumb">
                                            <li class="breadcrumb-item"><a href="#!"><i class="feather icon-home"></i></a></li>
                                            <li class="breadcrumb-item"><a href="#!">Mi horario clases</a></li>
                                            <li class="breadcrumb-item"><a href="#!">Periodo ${periodo_vigente.nombrePeriodo}</a></li>
                                        </ul>

                                        <table class="table table-bordered table-striped">
                                            <thead class="bg-primary ">
                                                <tr>
                                                    <th># Cod. Curso</th>
                                                    <th>Curso</th>
                                                    <th># Sección</th>
                                                    <th>Horas académicas</th>
                                                    <th>Nivel</th>
                                                    <th>Grado</th>
                                                    <th>Dia y hora</th>
                                                    <th>Asistencia</th>
                                                    <th></th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach items="${secciones}" var="item">
                                                    <tr>
                                                        <td>${item.idCursoProf}</td>
                                                        <td>${item.nombreCurso}</td>
                                                        <td>${item.idSeccion}</td>
                                                        <td>${item.horas}</td>
                                                        <td>${item.nivel}</td>
                                                        <td>${item.nroGrado}° ${item.letra}</td>
                                                        <td>
                                                            <ul style="list-style-type: none; padding-left: 0;">
                                                                <c:forEach items="${item.horarios}" var="horario">
                                                                    <li>
                                                                        <span>${horario.diaSemana}</span> 
                                                                        <span>${horario.horaInicio} - ${horario.horaFin}</span>
                                                                    </li>
                                                                </c:forEach>
                                                            </ul>
                                                        </td>
                                                        <td>
                                                            <a href="asistencia?accion=marcar&curso=${item.idCursoProf}" class="btn btn-info btn-sm">
                                                                <i class="fa fa-calendar-check"></i> Asistencia
                                                            </a>
                                                        </td>
                                                        <td>
                                                            <a href="asistencia?accion=exportarExcelAlumnos&seccion=${item.idSeccion}" 
                                                               class="btn btn-success btn-sm" target="_blank">
                                                                <i class="fa fa-file-excel"></i> Exportar Excel
                                                            </a>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                                <c:if test="${secciones.size() == 0}">
                                                    <tr class="text-center">
                                                        <td colspan="9">No cuenta con cursos asignados</td>
                                                    </tr>
                                                </c:if>
                                            </tbody>
                                        </table>
                                    </c:if>

                                    <c:if test="${periodo_vigente == null}">
                                        <div class="alert alert-primary" role="alert">
                                            Lo sentimos! No se ha encontrado periodo vigente actual.
                                        </div>
                                    </c:if>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <jsp:include page="includes/js.jsp" />
    </body>
</html>
