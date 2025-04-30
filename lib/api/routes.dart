const String _baseUrl = 'http://127.0.0.1:8000';
// const String _baseUrl = 'http://192.168.33.3:8000';

const String _prefix = '/api';

Uri getFullUrl(String shortUrl) {
  return Uri.parse(_baseUrl + _prefix + shortUrl);
}
