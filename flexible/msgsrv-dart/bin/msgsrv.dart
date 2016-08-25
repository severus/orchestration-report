import 'dart:io';
import 'dart:convert';

import 'package:appengine/appengine.dart';

requestHandler(HttpRequest request) async {
  try {
    if (request.uri.path == '/') {
      ContentType contentType = request.headers.contentType;

      if (request.method == 'POST' && contentType.mimeType == 'application/json') {
        var jsonString = await request.transform(UTF8.decoder).join();
        Map jsonData = JSON.decode(jsonString);

        if (jsonData['text'] == null) {
          request.response
            ..statusCode = HttpStatus.BAD_REQUEST
            ..write('Expected "text" field')
            ..close();
        } else {
          var timestamp = new DateTime.now().toUtc();

          jsonData['timestamp'] = timestamp.toString();
          request.response
            ..headers.contentType = ContentType.JSON
            ..write(JSON.encode(jsonData))
            ..close();
        }
      } else {
        request.response
          ..statusCode = HttpStatus.METHOD_NOT_ALLOWED
          ..write('Unsupported request: ${request.method}')
          ..close();
      }
    } else {
      request.response
        ..statusCode = HttpStatus.NOT_FOUND
        ..write('Not Found: ${request.uri}')
        ..close();
    }
  } catch (e) {
    request.response
      ..statusCode = HttpStatus.INTERNAL_SERVER_ERROR
      ..write('Exception during file I/O: $e.')
      ..close();
  }
}

void main(List<String> args) {
  int port = 8080;
  if (args.length > 0) {
    port = int.parse(args[0]);
  }

  runAppEngine(requestHandler, port: port);
}
