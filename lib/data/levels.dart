import '../game/level_generator.dart';
import '../models/level_data.dart';

/// 30 solver-validated levels from a fixed seed (easy 4x4, medium 5x5, hard 6x6).
/// Regenerating with the same seed yields the same catalog.
final List<LevelData> allLevels =
    List<LevelData>.unmodifiable(LevelGenerator.generateCatalog());

LevelData? levelById(int id) {
  for (final level in allLevels) {
    if (level.id == id) return level;
  }
  return null;
}

int get totalLevels => allLevels.length;
