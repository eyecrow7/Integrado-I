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
                                <div class="card-body">
                                    <ul class="breadcrumb">
                                        <li class="breadcrumb-item"><a href="#!"><i class="feather icon-home"></i></a></li>
                                        <li class="breadcrumb-item"><a href="#!">Rectificación asistencia</a></li>
                                        <li class="breadcrumb-item"><a href="#!">Periodo ${periodo_vigente.nombrePeriodo}</a></li>
                                    </ul>

                                    <div class="row">
                                        <c:if test="${periodo_vigente != null}">
                                            <div class="col-sm-12">
                                                <form>
                                                    <div class="row">
                                                        <div class="col-sm-3">
                                                            <div class="form-group">
                                                                <label >Grado:</label>
                                                                <select id="seccion" name="seccion" class="form-control"  onchange="cargarSecciones()">
                                                                    <option value="">::: Seleccione :::</option>
                                                                    <c:forEach items="${grados}" var="item" >
                                                                        <option value="${item.idSeccion}">${item.nivel}° ${item.nro} ${item.letra}</option>
                                                                    </c:forEach>
                                                                </select>
                                                            </div>
                                                        </div>

                                                        <div class="col-sm-3">
                                                            <div class="form-group">
                                                                <label >Curso:</label>
                                                                <select id="curso" name="curso" class="form-control" onchange="cargarFechas()">
                                                                    <option value="">::: Seleccione :::</option>

                                                                </select>
                                                            </div>
                                                        </div>
                                                        <div class="col-sm-3">
                                                            <div class="form-group">
                                                                <label >Fecha:</label>
                                                                <select id="fecha" name="fecha" class="form-control" required="">
                                                                    <option value="">::: Seleccione :::</option>

                                                                </select>
                                                            </div>
                                                        </div>
                                                        <div class="col-sm-3 mt-4">
                                                            <input type="hidden" name="periodo" id="periodo" value="${periodo_vigente.idPeriodo}">
                                                            <button onclick="consultarAlumnosInscritos()" type="button" class="btn btn-primary btn-sm">
                                                                ​ <i class="fa fa-search"></i> Consultar
                                                            </button>
                                                        </div>
                                                    </div>


                                                    <div class="row mt-2">
                                                        <div class="col-sm-12">
                                                            <table class="table table-bordered table-striped">
                                                                <thead class="bg-primary ">
                                                                    <tr>
                                                                        <th>#</th>
                                                                        <th>Alumno</th>
                                                                        <th>Correo</th>
                                                                        <th>Asistió</th>
                                                                    </tr>
                                                                </thead>
                                                                <tbody id="resultado_alumnos">
                                                                    <tr class='text-center'>
                                                                        <td colspan='7'>Sin resultados</td>
                                                                    </tr>
                                                                </tbody>
                                                            </table>

                                                            <button onclick="guardarAsistencia()" id="btnGuardarAsistencia" type="button" class="btn btn-info" disabled>
                                                                <i class="fa fa-save"></i> Guardar Asistencia
                                                            </button>
                                                        </div>

                                                </form>
                                            </div>

                                        </c:if>

                                        <c:if test="${periodo_vigente == null}">
                                            <div class="col-sm-12">
                                                <div class="alert alert-primary" role="alert">
                                                    Lo sentimos! No se ha encontrado periodo vigente actual.
                                                </div>
                                            </div>
                                        </c:if>
                                    </div>

                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <jsp:include page="includes/js.jsp" />
    </body>
    <script>
        const botonGuardar = document.getElementById("btnGuardarAsistencia");
        botonGuardar.disabled = true;

        document.getElementById("fecha").addEventListener("change", function () {
            const fecha = this.value;
            if (fecha === "") {
                deshabilitarBoton();
            }
        });

        function guardarAsistencia() {
            const seccion = document.getElementById("seccion").value;
            const fecha = document.getElementById("fecha").value;
            const curso = document.getElementById("curso").value;

            let filas = document.querySelectorAll("#resultado_alumnos tr");
            let idsAlumnos = [];
            let idsAsistencia = [];
            let asistencias = [];

            filas.forEach((fila) => {
                let idAsistencia = fila.querySelector("input[name='idAsistencia']").value;
                let idAlumno = fila.querySelector("input[name='idAlumno']").value;
                let asistio = fila.querySelector("input[type='checkbox']").checked ? "1" : "0";
                idsAlumnos.push(idAlumno);
                idsAsistencia.push(idAsistencia);
                asistencias.push(asistio);
            });

            let _params = {
                "accion": "procesar_rectificacion",
                "idSeccion": seccion,
                "idCursoProf": curso,
                "fecha": fecha,
                "idAlumno": idsAlumnos.join(';'), // Join with semicolon
                "idAsistencia": idsAsistencia.join(';'), // Join with semicolon
                "asistencias": asistencias.join(';') // Join with semicolon
            };

            axios
                    .get("asistencia", {params: _params})
                    .then((response) => {
                        response = response.data;
                        if (response.msg === "OK") {
                            fnToast("success", "Se procesó de forma correcta la marcación");
                        } else {
                            fnToast("info", response.msg);
                        }

                    })
                    .catch((error) => {
                        console.dir(error);
                        fnToast("error", "No se pudo procesar asistencia.");
                    });
        }

        function consultarAlumnosInscritos() {
            const seccion = document.getElementById("seccion").value;
            const fecha = document.getElementById("fecha").value;
            const curso = document.getElementById("curso").value;
            const periodo = document.getElementById("periodo").value;

            if (seccion === "") {
                fnToast("error", "Debe seleccionar una sección");
                return;
            }

            if (curso === "") {
                fnToast("error", "Debe seleccionar un curso");
                return;
            }

            if (fecha === "") {
                fnToast("error", "Debe seleccionar una fecha");
                return;
            }

            var _params = {
                "accion": "listar_alumnos_inscritos_rectificacion",
                "seccion": seccion,
                "curso": curso,
                "fecha": fecha,
                "periodo": periodo
            };

            axios
                    .get("asistencia", {params: _params})
                    .then((response) => {
                        response = response.data;

                        var result = "";

                        if (response.length > 0) {
                            response.forEach((item, index) => {
                                result += "<tr>";
                                result += "    <td>" + (index + 1) + "</td>";
                                result += "    <td>" + item.apePaterno + " " + item.apeMaterno + " " + item.nombres + "</td>";
                                result += "    <td>" + item.correo + "</td>";
                                result += "    <td>";
                                result += "        <input type='hidden' name='idAsistencia' value='" + item.idAsisAlu + "'>";
                                result += "        <input type='hidden' name='idAlumno' value='" + item.idAlumno + "' />";
                                result += "        <input type='checkbox' name='asistio_" + item.idAlumno + "' value='1' " + (item.asistio === 1 ? "checked" : "") + ">";
                                result += "    </td>";
                                result += "</tr>";
                            });

                            botonGuardar.disabled = false;
                        } else {
                            result = "<tr class='text-center'><td colspan='7'>Sin resultados</td></tr>";
                            fnToast("error", "No se encontraron alumnos.");
                            deshabilitarBoton();
                        }
                        document.getElementById("resultado_alumnos").innerHTML = result;
                    })
                    .catch((error) => {
                        console.dir(error);
                        fnToast("error", "No se pudo obtener alumnos.");
                    });
        }

        function resetarAlumnos() {
            document.getElementById("resultado_alumnos").innerHTML = "<tr class='text-center'><td colspan='7'>Sin resultados</td></tr>";
        }

        function verificarEstadoBoton() {
            if (botonGuardar.disabled) {
                resetarAlumnos();
            }
        }
        function deshabilitarBoton() {
            botonGuardar.disabled = true;
            verificarEstadoBoton();
        }
        function cargarSecciones() {
            const curso = document.getElementById("curso");
            const fecha = document.getElementById("fecha");
            const seccion = document.getElementById("seccion").value;

            var _params = {
                "accion": "listar_x_profesor",
                "seccion": seccion === "" ? 0 : seccion
            };

            fecha.innerHTML = '<option value="">::: Seleccione :::</option>';
            curso.innerHTML = '<option value="">::: Seleccione :::</option>';
            deshabilitarBoton();
            axios
                    .get("curso", {params: _params})
                    .then((response) => {
                        response = response.data;
                        if (response.length > 0) {
                            response.forEach(item => {
                                const option = document.createElement("option");
                                option.value = item.idCursoProf;
                                option.text = item.nombreCurso;
                                curso.appendChild(option);
                            });
                        }
                    })
                    .catch((error) => {
                        console.dir(error);
                        fnToast("error", "No se pudo obtener consultar respuesta.");
                    });
        }

        function cargarFechas() {
            const curso = document.getElementById("curso").value;
            const periodo = document.getElementById("periodo").value;
            const fecha = document.getElementById("fecha");

            var _params = {
                "accion": "listar_fechas_x_curso",
                "curso": curso === "" ? 0 : curso,
                "periodo": periodo
            };

            fecha.innerHTML = '<option value="">::: Seleccione :::</option>';
            deshabilitarBoton();
            axios
                    .get("curso", {params: _params})
                    .then((response) => {
                        response = response.data;
                        if (response.length > 0) {
                            response.forEach(item => {
                                const option = document.createElement("option");
                                option.value = item;
                                option.text = item;
                                fecha.appendChild(option);
                            });
                        }
                    })
                    .catch((error) => {
                        console.dir(error);
                        fnToast("error", "No se pudo obtener fechas.");
                    });
        }
    </script>
</html>
