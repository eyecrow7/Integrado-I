function fnToast(tipo, msg) {
    if (tipo === "success") {
        toastr.success(msg, toastr.options = {
            "timeOut": "5000",
            "positionClass ": " toast-top-right "
        });
    } else if (tipo === "error") {
        toastr.error(msg, toastr.options = {
            "timeOut": "5000",
            "positionClass ": " toast-top-right "
        });
    } else if (tipo === "info") {
        toastr.info(msg, toastr.options = {
            "timeOut": "5000",
            "positionClass ": " toast-top-right "
        });
    } else if (tipo === "warning") {
        toastr.warning(msg, toastr.options = {
            "timeOut": "5000",
            "positionClass ": " toast-top-right "
        });
    }
}