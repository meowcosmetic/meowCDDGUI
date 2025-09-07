import 'dart:html' as html;

class HostService {
  static String? _cachedHost;
  
  /// Lấy hostname động từ window.location (không bao gồm port)
  static String getHost() {
    if (_cachedHost != null) {
      return _cachedHost!;
    }
    
    try {
      final location = html.window.location;
      final hostname = location.hostname;
      
      // Chỉ lấy hostname, bỏ port
      _cachedHost = hostname;
      
      return _cachedHost!;
    } catch (e) {
      // Fallback về localhost nếu không lấy được hostname
      _cachedHost = 'localhost';
      return _cachedHost!;
    }
  }
  
  /// Lấy protocol (http hoặc https)
  static String getProtocol() {
    try {
      return html.window.location.protocol.replaceAll(':', '');
    } catch (e) {
      return 'http';
    }
  }
  
  /// Lấy base URL động
  static String getBaseUrl() {
    final protocol = getProtocol();
    final host = getHost();
    return '$protocol://$host';
  }
  
  /// Lấy API base URL
  static String getApiBaseUrl() {
    return '${getBaseUrl()}/api';
  }
  
  /// Lấy CDD API URL
  static String getCddApiUrl() {
    return '${getBaseUrl()}/api/cdd/api/v1/neon';
  }
  
  /// Reset cache (hữu ích khi test hoặc thay đổi môi trường)
  static void resetCache() {
    _cachedHost = null;
  }
}
