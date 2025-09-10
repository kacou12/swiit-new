// data/datasources/event_local_datasource.dart

import 'package:swiit/src/core/storage/hive_helper.dart';
import 'package:swiit/src/features/events/data/models/get_event_payload.dart';
import '../models/event_invite_model.dart';
import '../models/event_model.dart';

abstract class EventLocalDataSource {
  Future<List<EventModel>> getEvents(GetEventPayload params);
  Future<void> cacheEvents(List<EventModel> events);
  Future<List<EventInviteModel>> getAllEventInvites();
  Future<void> cacheEventInvites(List<EventInviteModel> eventInvites);
  Future<EventInviteModel> getEventInviteById(int id);
}

class EventLocalDataSourceImpl implements EventLocalDataSource {
  final HiveHelper hiveHelper;

  EventLocalDataSourceImpl({required this.hiveHelper});

  @override
  Future<List<EventModel>> getEvents(GetEventPayload params) async {
    final eventsBox = await hiveHelper.openBox('eventsBox');
    final events = eventsBox.values
        .map((event) => EventModel.fromJson(event))
        .where((event) => event.type == params.type)
        .toList();
    return events;
  }

  @override
  Future<void> cacheEvents(List<EventModel> events) async {
    final eventsBox = await hiveHelper.openBox('eventsBox');
    await eventsBox.clear();
    for (var event in events) {
      await eventsBox.add(event.toJson());
    }
  }

  @override
  Future<List<EventInviteModel>> getAllEventInvites() async {
    final eventInvitesBox = await hiveHelper.openBox('eventInvitesBox');
    final eventInvites = eventInvitesBox.values
        .map((eventInvite) => EventInviteModel.fromJson(eventInvite))
        .toList();
    return eventInvites;
  }

  @override
  Future<void> cacheEventInvites(List<EventInviteModel> eventInvites) async {
    final eventInvitesBox = await hiveHelper.openBox('eventInvitesBox');
    await eventInvitesBox.clear();
    for (var eventInvite in eventInvites) {
      await eventInvitesBox.add(eventInvite.toJson());
    }
  }

  @override
  Future<EventInviteModel> getEventInviteById(int id) async {
    final eventInvitesBox = await hiveHelper.openBox('eventInvitesBox');
    final eventInvite = eventInvitesBox.get(id);
    if (eventInvite != null) {
      return EventInviteModel.fromJson(eventInvite);
    } else {
      throw Exception('Event invite not found');
    }
  }
}
