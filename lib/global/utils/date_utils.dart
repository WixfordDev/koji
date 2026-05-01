/// Converts a UTC DateTime to Singapore Standard Time (UTC+8).
/// Use this for all task schedule time display throughout the app.
DateTime toSgt(DateTime dt) => dt.toUtc().add(const Duration(hours: 8));
