class StatusHelper {
  /// Convert backend status to frontend display label
  static String toDisplayLabel(String backendStatus) {
    switch (backendStatus) {
      case 'Open':
        return 'Private';
      case 'Submitted':
        return 'Open';
      case 'Closed':
        return 'Closed';
      default:
        return backendStatus;
    }
  }
  
  /// Convert frontend display label to backend status
  static String toBackendStatus(String displayLabel) {
    switch (displayLabel) {
      case 'Private':
        return 'Open';
      case 'Open':
        return 'Submitted';
      case 'Closed':
        return 'Closed';
      default:
        return displayLabel;
    }
  }
  
  /// Get color for status badge
  static String getStatusColor(String backendStatus) {
    switch (backendStatus) {
      case 'Open': // Private on frontend
        return '0xFFFED7AA'; // Orange
      case 'Submitted': // Open on frontend
        return '0xFFDCEEFB'; // Blue
      case 'Closed':
        return '0xFFE5E7EB'; // Gray
      default:
        return '0xFFE5E7EB';
    }
  }
  
  /// Get text color for status badge
  static String getStatusTextColor(String backendStatus) {
    switch (backendStatus) {
      case 'Open': // Private on frontend
        return '0xFF9A3412'; // Dark orange
      case 'Submitted': // Open on frontend
        return '0xFF1E40AF'; // Dark blue
      case 'Closed':
        return '0xFF374151'; // Dark gray
      default:
        return '0xFF374151';
    }
  }
}