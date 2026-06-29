import 'package:flutter/material.dart';
import '../models/friend.dart';

class FriendsProvider with ChangeNotifier {
  final List<Friend> _friends = [
    Friend(id: 'f1', name: 'Alice'),
    Friend(id: 'f2', name: 'Bob'),
    Friend(id: 'f3', name: 'Charlie'),
  ];

  List<Friend> get friends => _friends;

  void addFriend(String name) {
    _friends.add(Friend(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name));
    notifyListeners();
  }

  void removeFriend(String id) {
    _friends.removeWhere((f) => f.id == id);
    notifyListeners();
  }
}
