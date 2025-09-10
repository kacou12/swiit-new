// data/datasources/event_remote_datasource.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:swiit/src/core/constants/base_url.dart';
import 'package:swiit/src/core/interceptor/helper/dio_helper.dart';
import 'package:swiit/src/features/auth/data/models/user_model.dart';
import 'package:swiit/src/features/events/data/models/get_event_payload.dart';
import '../models/event_invite_model.dart';
import '../models/event_invite_payload.dart';
import '../models/event_model.dart';
import '../models/event_payload.dart';
import '../models/event_search_payload.dart';
import '../models/event_subscription_payload.dart';
import '../models/get_my_event_payload.dart';
import '../models/update_event_payload.dart';

abstract class EventRemoteDataSource {
  Future<List<EventModel>> getEvents(GetEventPayload params);
  Future<List<EventModel>> getMyEvents(GetMyEventPayload params);
  Future<EventModel> addEvent(EventPayload payload);
  Future<EventModel> updateEvent(UpdateEventPayload event);
  Future<List<EventInviteModel>> getAllEventInvites();
  Future<EventInviteModel> addEventInvite(EventInvitePayload payload);
  Future<EventInviteModel> getEventInviteById(int id);
  Future<bool> subscription(EventSubscriptionPayload payload);
  Future<List<EventModel>> eventSearch(EventSearchPayload payload);
  Future<List<UserModel>> getEventSubscribers(String payload);
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final DioHelper dio;

  EventRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<EventModel>> getEvents(GetEventPayload params) async {
    final path = params.type == EventSearchType.switer
        ? "/search"
        : params.type == EventSearchType.club
            ? "/club/${params.referenceId}"
            : "";
    try {
      final response = await dio.get('$baseUrl/event$path',
          queryParameters: params.toJson());
      // Check if response data is a Map
      if (response.data is Map<String, dynamic>) {
        // Extract the list of events from the 'data' key
        final List<dynamic> eventList =
            (response.data as Map<String, dynamic>)['data'];
        // Map the extracted list to a List of EventModel
        return eventList.map((event) => EventModel.fromJson(event)).toList();
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      throw Exception('Failed to fetch events');
    }
  }

  @override
  Future<EventModel> addEvent(EventPayload payload) async {
    try {
      final data = FormData.fromMap(payload.toJson());
      final response = await dio.post(
        '$baseUrl/event',
        data: data, // Ensure the payload is correctly encoded
      );

      print("Response: ${response.toString()}");

      if (response.statusCode == 200) {
        return EventModel.fromJson(response.data['data']);
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

  @override
  Future<List<EventInviteModel>> getAllEventInvites() async {
    final response = await dio.get('$baseUrl/event_invites');
    if (response.statusCode == 200) {
      List<EventInviteModel> eventInvites = (response.data as List)
          .map((eventInvite) => EventInviteModel.fromJson(eventInvite))
          .toList();
      return eventInvites;
    } else {
      throw Exception('Failed to load event invites');
    }
  }

  @override
  Future<List<UserModel>> getEventSubscribers(String payload) async {
    final response =
        await dio.get('$baseUrl/event/subscription/event/$payload');
    if (response.statusCode == 200) {
      List<UserModel> suscribers = (response.data["data"] as List)
          .map((suscriber) => UserModel.fromJson(json.encode(suscriber)))
          .toList();
      return suscribers;
    } else {
      throw Exception('Failed to load event invites');
    }
  }

  @override
  Future<EventInviteModel> addEventInvite(EventInvitePayload payload) async {
    final response = await dio.post(
      '$baseUrl/event/invitation/',
      data: FormData.fromMap(payload.toJson()),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return EventInviteModel.fromJson(response.data["data"]);
    } else {
      throw Exception('Failed to add event invite');
    }
  }

  @override
  Future<EventInviteModel> getEventInviteById(int id) async {
    final response = await dio.get('/event_invites/$id');
    if (response.statusCode == 200) {
      return EventInviteModel.fromJson(response.data);
    } else {
      throw Exception('Failed to load event invite');
    }
  }

  @override
  Future<bool> subscription(EventSubscriptionPayload payload) async {
    final response = await dio.post(
      '$baseUrl/event/subscription',
      data: FormData.fromMap(payload.toJson()),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to subscribe');
    }
  }

  @override
  Future<List<EventModel>> eventSearch(EventSearchPayload payload) async {
    final response = await dio.get(
      '$baseUrl/event/search',
      queryParameters: payload.toJson(),
    );
    if (response.statusCode == 200) {
      if (response.data['data'] == null) {
        return [];
      }
      List<EventModel> events = (response.data['data'] as List)
          .map((event) => EventModel.fromJson(event))
          .toList();
      return events;
    } else {
      throw Exception('Failed to load events');
    }
  }

  @override
  Future<EventModel> updateEvent(UpdateEventPayload event) async {
    final response = await dio.put(
      '$baseUrl/event/${event.id}',
      data: event.toJson(),
    );
    if (response.statusCode == 200) {
      return EventModel.fromJson(response.data);
    } else {
      throw Exception('Failed to update event');
    }
  }

  @override
  Future<List<EventModel>> getMyEvents(GetMyEventPayload params) async {
    final response = await dio.get(
      '$baseUrl/event',
      queryParameters: params.toJson(),
    );
    if (response.statusCode == 200) {
      List<EventModel> events = (response.data['data'] as List)
          .map((event) => EventModel.fromJson(event))
          .toList();
      return events;
    } else {
      throw Exception('Failed to load events');
    }
  }
}
