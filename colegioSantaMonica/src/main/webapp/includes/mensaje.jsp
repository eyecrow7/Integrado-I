<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:if test = "${sessionScope.error !=null}">
    <script>
        var msj;
        msj = '${sessionScope.error }';
        toastr.error(msj, toastr.options = {
            "timeOut": "5000",
            "positionClass ": " toast-top-right "
        });
    </script>
</c:if> 

<c:if test = "${sessionScope.success !=null}">
    <script>
        var msj;
        msj = '${sessionScope.success }';
        toastr.success(msj, toastr.options = {
            "timeOut": "5000",
            "positionClass ": " toast-bottom-right "
        });
    </script>
</c:if>

<c:remove var="success" scope="session"/> 
<c:remove var="error" scope="session"/> 