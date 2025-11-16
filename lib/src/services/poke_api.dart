import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models.dart';

class PokeApi {
  static const _list = 'https://pokeapi.co/api/v2/pokemon?limit={L}&offset={O}';

  static int _idFromUrl(String url) {
    final parts = url.split('/');
    for (var i = parts.length - 1; i >= 0; i--) {
      if (parts[i].isNotEmpty) return int.parse(parts[i]);
    }
    throw Exception('bad url $url');
  }

  static String art(int id) =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  static Future<List<Mon>> fetch({int limit = 60, int offset = 0}) async {
    final res = await http.get(Uri.parse(_list.replaceFirst('{L}', '$limit').replaceFirst('{O}', '$offset')));
    if (res.statusCode != 200) throw Exception('PokéAPI ${res.statusCode}');
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (json['results'] as List).cast<Map<String, dynamic>>();
    return list.map((row) {
      final id = _idFromUrl(row['url'] as String);
      return Mon(id: id, name: row['name'] as String, imageUrl: art(id));
    }).toList();
  }
}
