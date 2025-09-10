// data/datasources/event_remote_datasource.dart

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:swiit/src/core/constants/base_url.dart';
import 'package:swiit/src/core/interceptor/helper/dio_helper.dart';
import 'package:swiit/src/features/chat/data/models/message_model.dart';
import 'package:swiit/src/features/chat/data/models/message_payload.dart';

abstract class ChatRemoteDataSource {
  Future<List<MessageModel>> getChatEventMessages(String roomIdPayload);
  Future<MessageModel> addChatEventMessage(MessagePayload payload);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final DioHelper dio;

  ChatRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<MessageModel>> getChatEventMessages(String roomIdPayload) async {
    String path_url = "message/$roomIdPayload";

    try {
      final response = await dio.get('$baseUrl/$path_url');
      // Check if response data is a Map
      if (response.data is Map<String, dynamic>) {
        // Extract the list of events from the 'data' key
        final List<dynamic> eventList =
            (response.data as Map<String, dynamic>)['data'];
        // Map the extracted list to a List of EventModel
        return eventList.map((event) => MessageModel.fromJson(event)).toList();
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      throw Exception('Failed to fetch events');
    }
  }

  @override
  Future<MessageModel> addChatEventMessage(MessagePayload payload) async {
    try {
      print("Payload: ${jsonEncode(payload.toJson())}");

      final response = await dio.post(
        '$baseUrl/message/',
        data: jsonEncode(
            payload.toJson()), // Ensure the payload is correctly encoded
      );

      print("Response: ${response.toString()}");

      if (response.statusCode == 200) {
        return MessageModel.fromJson(response.data);
      } else {
        // Print the status code and response for debugging
        print("Failed to add event, status code: ${response.statusCode}");
        print("Response data: ${response.data}");
        throw Exception('Failed to add event');
      }
    } on DioException catch (e) {
      // Handle DioError to get more details about the error
      if (e.response != null) {
        print("Dio error! Status code: ${e.response?.statusCode}");
        print("Data: ${e.response?.data}");
        print("Headers: ${e.response?.headers}");
      } else {
        // Error due to setting up or sending the request
        print("Error sending request: ${e.message}");
      }
      throw Exception('Failed to add event: ${e.message}');
    } catch (e) {
      // Handle other types of exceptions
      print("Unexpected error: $e");
      throw Exception('Unexpected error: $e');
    }
  }
}
