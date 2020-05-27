class ApiResponse<T> {
  static const int LOADING = 0;
  static const  int COMPLETED = 1;
  static const int ERROR = 2;

  int status;
  T data;
  String message;

  ApiResponse.loading(this.message) : status  = LOADING;
  ApiResponse.completed(this.data) : status = COMPLETED;
  ApiResponse.error(this.message) : status = ERROR;

  @override
  String toString() {
    return "Status : $status \n Message : $message \n Data : $data";
  }
}

