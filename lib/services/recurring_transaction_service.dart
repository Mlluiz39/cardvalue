class RecurringTransactionService {
  /// Generates transaction instances from active recurrence rules.
  /// Called on app launch and periodically via timer.
  Future<void> processRecurringRules() async {
    // Read active recurrence rules where next_occurrence <= now
    // For each, create a new Transaction instance
    // Update next_occurrence based on frequency/interval
    // Implementation via Supabase queries
  }
}
