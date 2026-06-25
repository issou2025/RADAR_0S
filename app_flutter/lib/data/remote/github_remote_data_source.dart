import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/security/encryption_helper.dart';

class GithubRemoteDataSource {
  static const String _apiBaseUrl = "https://api.github.com/repos";

  final String owner;
  final String repo;
  final String branch;

  GithubRemoteDataSource({
    required this.owner,
    required this.repo,
    required this.branch,
  });

  Future<Map<String, String>> _headers() async {
    final token = await EncryptionHelper.getGithubToken();
    final headers = {
      "Accept": "application/vnd.github.v3+json",
      "Content-Type": "application/json",
    };
    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "token $token";
    }
    return headers;
  }

  /// Check if the GitHub repository is accessible with credentials
  Future<bool> testConnection() async {
    try {
      final url = Uri.parse("$_apiBaseUrl/$owner/$repo");
      final headers = await _headers();
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Fetch file info from GitHub (returns decoded string content + sha string)
  Future<GithubFileResponse> fetchFile(String path) async {
    final url = Uri.parse("$_apiBaseUrl/$owner/$repo/contents/$path?ref=$branch");
    final headers = await _headers();
    final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 12));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final rawContent = jsonResponse['content'] as String;
      // Remove any newlines in base64 payload
      final cleanContent = rawContent.replaceAll('\n', '').replaceAll('\r', '');
      final decodedBytes = base64Decode(cleanContent);
      final utf8Content = utf8.decode(decodedBytes);
      final sha = jsonResponse['sha'] as String;
      
      return GithubFileResponse(content: utf8Content, sha: sha, exists: true);
    } else if (response.statusCode == 404) {
      return GithubFileResponse(content: "", sha: "", exists: false);
    } else {
      throw Exception("Failed to fetch file $path from GitHub (HTTP ${response.statusCode}): ${response.body}");
    }
  }

  /// Write/Update a file in the GitHub repository
  Future<String> updateFile({
    required String path,
    required String content,
    required String sha,
    required String commitMessage,
  }) async {
    final url = Uri.parse("$_apiBaseUrl/$owner/$repo/contents/$path");
    final headers = await _headers();
    
    final utf8Bytes = utf8.encode(content);
    final base64Content = base64Encode(utf8Bytes);
    
    final Map<String, dynamic> body = {
      "message": commitMessage,
      "content": base64Content,
      "branch": branch,
    };
    if (sha.isNotEmpty) {
      body["sha"] = sha;
    }

    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      final newSha = jsonResponse['content']['sha'] as String;
      return newSha;
    } else {
      throw Exception("Failed to update file $path on GitHub (HTTP ${response.statusCode}): ${response.body}");
    }
  }
}

class GithubFileResponse {
  final String content;
  final String sha;
  final bool exists;

  GithubFileResponse({
    required this.content,
    required this.sha,
    required this.exists,
  });
}
