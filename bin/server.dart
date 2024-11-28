import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

// Configure routes.
final _router = Router()
  ..get('/', _rootHandler)
  ..get('/echo/<message>', _echoHandler)
  ..get('/todos', _todosHandler);

Response _rootHandler(Request req) => Response.ok('Hello, World!\n');

Response _echoHandler(Request req) {
  final message = req.params['message'];
  return Response.ok('$message\n');
}

Response _todosHandler(Request req) {
  final todos = [
    {'id': '1', 'name': 'First Todo'},
    {'id': '2', 'name': 'Second Todo'},
    {'id': '3', 'name': 'Third Todo'},
  ];
  return Response.ok(jsonEncode(todos), headers: {'Content-Type': 'application/json'});
}

Middleware corsMiddleware() {
  return (Handler handler) {
    return (Request request) async {
      final response = await handler(request);
      return response.change(headers: {
        ...response.headers,
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      });
    };
  };
}

void main(List<String> args) async {
  final ip = InternetAddress.anyIPv4;

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsMiddleware())
      .addHandler(_router);

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
