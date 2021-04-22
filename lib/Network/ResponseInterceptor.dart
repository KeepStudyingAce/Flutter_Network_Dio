import 'package:dio/dio.dart';
import 'ResultData.dart';

/// 数据初步处理
class ResponseInterceptors extends InterceptorsWrapper {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    RequestOptions option = response.requestOptions;

    try {
      if (option.contentType != null && option.contentType.contains("text")) {
        response.data = ResultData(response.data, true, 200);
        handler.next(response);
      }

      ///一般只需要处理200的情况，300、400、500保留错误信息，外层为http协议定义的响应码
      if (response.statusCode == 200 || response.statusCode == 201) {
        ///内层需要根据公司实际返回结构解析，一般会有code，data，msg字段

        int code = response.data["code"];
        if (code == 0) {
          response.data = ResultData(response.data, true, 200,
              headers: response.headers);
          handler.next(response);
        } else {
          response.data = ResultData(response.data, false, 200,
              headers: response.headers);
          handler.next(response);
        }
      }
    } catch (e) {
      print("ResponseError====" + e.toString() + "****" + option.path);

      response.data = ResultData(response.data, false, response.statusCode,
          headers: response.headers);
      handler.next(response);
    }

    response.data = ResultData(response.data, false, response.statusCode, headers: response.headers);
    handler.next(response);
  }
}
