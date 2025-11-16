// lib/src/pages/onboarding/character_select_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models.dart';
import '../../state/app_state.dart';

class CharacterSelectPage extends StatefulWidget {
  const CharacterSelectPage({super.key});

  @override
  State<CharacterSelectPage> createState() => _CharacterSelectPageState();
}

class _CharacterSelectPageState extends State<CharacterSelectPage> {
  // --- STATE MANAGEMENT ---
  late final List<Mon> _defaultMons;
  List<Mon> _allMons = [];       // <-- NEW: To store the full list of Pokémon
  List<Mon> _displayMons = [];   // The list currently shown to the user
  Set<int> _takenMonIds = {};

  int? _selectedId;
  final _searchController = TextEditingController();
  bool _isLoading = true; // <-- Start as true because we will fetch the full list initially
  String? _error;

  // --- STATIC DATA AND HELPERS ---
  static String art(int id) => 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  static const _starters = <Mon>[
    Mon(id: 1, name: 'bulbasaur', imageUrl: ''),
    Mon(id: 4, name: 'charmander', imageUrl: ''),
    Mon(id: 7, name: 'squirtle', imageUrl: ''),
    Mon(id: 25, name: 'pikachu', imageUrl: ''),
    Mon(id: 133, name: 'eevee', imageUrl: ''),
    Mon(id: 152, name: 'chikorita', imageUrl: ''),
  ];

  @override
  void initState() {
    super.initState();
    _defaultMons = _starters.map((m) => m.copyWith(imageUrl: art(m.id))).toList();
    _displayMons = _defaultMons;

    _fetchAllPokemon(); // <-- NEW: Fetch the full list on init

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fetchTakenMons();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- LOGIC ---

  // NEW: Fetches the complete list of Pokémon from the API once.
  Future<void> _fetchAllPokemon() async {
    try {
      // The PokeAPI has a limit parameter to get more results at once
      final uri = Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=1025');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];

        List<Mon> allMons = [];
        for (var p in results) {
          // The ID is in the URL, e.g., ".../pokemon/1/"
          final urlParts = p['url'].split('/');
          final id = int.parse(urlParts[urlParts.length - 2]);
          allMons.add(Mon(id: id, name: p['name'], imageUrl: art(id)));
        }
        _allMons = allMons;
      } else {
        _error = 'Failed to load Pokémon list.';
      }
    } catch (e) {
      _error = 'Could not connect to the Pokémon network.';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _fetchTakenMons() {
    final app = context.read<AppState>();
    setState(() {
      _takenMonIds = app.board.where((s) => s.starter != null).map((s) => s.starter!.id).toSet();
    });
  }

  // UPDATED: Now searches the local _allMons list instead of making an API call.
  void _searchPokemon() {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      setState(() => _displayMons = _defaultMons); // Go back to starters
      return;
    }

    // Filter the full list based on the search query
    final filteredList = _allMons.where((mon) {
      return mon.name.contains(query) || mon.id.toString() == query;
    }).toList();

    setState(() {
      _displayMons = filteredList;
      if (filteredList.isEmpty) {
        _error = 'No Pokémon found for "$query".';
      } else {
        _error = null;
      }
    });
  }

  // --- UI WIDGETS ---
  @override
  Widget build(BuildContext context) {
    // ... The rest of your UI code remains the same, only minor changes needed ...
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Choose Your Starter'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF81C784), Color(0xFF4DB6AC)],
          ),
        ),
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 60, 16, 0),
                child: _buildSearchBar(),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : _buildPokemonGrid(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  Widget _buildSearchBar() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search the Pokédex...',
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: _searchPokemon,
            ),
          ),
          onChanged: (_) => _searchPokemon(), // <-- UPDATED: Search as you type
        ),
      ),
    );
  }

  Widget _buildPokemonGrid() {
    if (_error != null && _displayMons.isEmpty) { // Show error only if there are no results
      return Center(
          child: Text(_error!, style: const TextStyle(color: Colors.white70, fontSize: 16)));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: .86,
      ),
      itemCount: _displayMons.length,
      itemBuilder: (_, i) {
        final m = _displayMons[i];
        final bool isSelected = _selectedId == m.id;
        final bool isTaken = _takenMonIds.contains(m.id);

        return _PokemonCard(
          mon: m,
          isSelected: isSelected,
          isTaken: isTaken,
          onTap: isTaken ? null : () => setState(() => _selectedId = m.id),
        );
      },
    );
  }

  Widget _buildBottomButton() {
    final bool canConfirm = _selectedId != null;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF004D40),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          onPressed: !canConfirm
              ? null
              : () {
            final chosen = _allMons.firstWhere((e) => e.id == _selectedId, orElse: () => _defaultMons.firstWhere((e) => e.id == _selectedId));
            Navigator.of(context).pop(chosen);
          },
          child: const Text('Confirm Starter'),
        ),
      ),
    );
  }
}


// --- THE _PokemonCard WIDGET REMAINS UNCHANGED ---
// It is already correctly designed to handle the display logic.
class _PokemonCard extends StatelessWidget {
  final Mon mon;
  final bool isSelected;
  final bool isTaken;
  final VoidCallback? onTap;

  const _PokemonCard({
    required this.mon,
    required this.isSelected,
    required this.isTaken,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? cs.primary : cs.outline.withAlpha(77),
            width: isSelected ? 3 : 1.2,
          ),
          boxShadow: [
            if (isSelected) BoxShadow(color: cs.primary.withAlpha(77), blurRadius: 18)
          ],
          color: Colors.white.withAlpha(isTaken ? 102 : 242),
        ),
        child: Column(
          children: [
            Expanded(
              child: Opacity(
                opacity: isTaken ? 0.6 : 1.0,
                child: Image.network(
                  mon.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.wifi_off_rounded, color: Colors.grey, size: 40),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mon.name[0].toUpperCase() + mon.name.substring(1),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: isTaken ? Colors.black.withAlpha(128) : Colors.black,
              ),
            ),
            if (isTaken)
              const Text(
                '(Taken)',
                style: TextStyle(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
