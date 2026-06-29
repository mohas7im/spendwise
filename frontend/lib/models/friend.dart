class Friend {
  final String id;
  final String name;
  final String avatarUrl;

  Friend({
    required this.id,
    required this.name,
    String? avatarUrl,
  }) : avatarUrl = avatarUrl ?? 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random';
}
