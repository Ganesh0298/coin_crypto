import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print("START HTTP ---->");
    print('${options.method}\n${options.path}');
    String requestDataAsString=options.data.toString();
    print("START REQUEST \n $requestDataAsString \n END REQUEST \n <---- END HTTP");
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print("START HTTP ---->");
    String responseDataAsString=response.data.toString();
    print("START RESPONSE \n $responseDataAsString \n END RESPONSE \n <---- END HTTP");
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('ERROR PATH ---->${err.requestOptions.path}');
    print("ERROR MSG ----> ${err.message}");
    print("ERROR ---->${err.error}");
    return handler.next(err);
  }

}
