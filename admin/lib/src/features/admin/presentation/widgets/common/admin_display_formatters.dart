String shortId(String id) {
  if (id.length <= 10) {
    return id;
  }
  return '${id.substring(0, 6)}...${id.substring(id.length - 4)}';
}

String initialFor(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return '?';
  }
  return trimmed.substring(0, 1).toUpperCase();
}

String formatAdminDate(DateTime? value) {
  if (value == null) {
    return 'N/A';
  }

  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$day/$month/${value.year} $hour:$minute';
}
