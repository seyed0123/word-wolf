import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final httpClient = HttpClient();
  final url = Uri.parse('http://localhost:8080/hello');

  try {
    final request = await httpClient.getUrl(url);
    final response = await request.close();

    if (response.statusCode == HttpStatus.ok) {
      final responseBody = await response.transform(utf8.decoder).join();
      print('Response: $responseBody');
    } else {
      print('Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    httpClient.close();
  }


  final httpClient1 = HttpClient();
  final url1 = Uri.parse('http://localhost:8080/hello');

  try {
    final request = await httpClient1.postUrl(url1);
    // Add any request headers if needed (e.g., content-type).
    // request.headers.add(HttpHeaders.contentTypeHeader, 'application/json');

    // Write data to the request body (if required).
    request.write('{"key": "value"}');

    final response = await request.close();

    if (response.statusCode == HttpStatus.ok) {
      final responseBody = await response.transform(utf8.decoder).join();
      print('Response: $responseBody');
    } else {
      print('Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    httpClient1.close();
  }
}