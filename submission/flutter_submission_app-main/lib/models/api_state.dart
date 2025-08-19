sealed class ApiState<T> {
  const ApiState();
}

class ApiLoading<T> extends ApiState<T> {
  const ApiLoading();
}

class ApiSuccess<T> extends ApiState<T> {
  final T data;
  const ApiSuccess(this.data);
}

class ApiError<T> extends ApiState<T> {
  final Object error;
  final StackTrace? stackTrace;
  const ApiError(this.error, [this.stackTrace]);
}
