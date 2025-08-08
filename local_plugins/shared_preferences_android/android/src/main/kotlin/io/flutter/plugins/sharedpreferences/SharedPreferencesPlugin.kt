
// Replace the PreferenceManager usage with direct SharedPreferences access

// Find this line:
// val preferences = PreferenceManager.getDefaultSharedPreferences(context)

// Replace it with:
val preferences = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
