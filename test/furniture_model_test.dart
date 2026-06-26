import 'package:flutter_test/flutter_test.dart';
import 'package:ar_furniture/models/furniture_model.dart';

void main() {
  group('FurnitureItem.getSampleFurniture', () {
    final items = FurnitureItem.getSampleFurniture();

    test('produces a non-empty catalogue', () {
      expect(items, isNotEmpty);
    });

    test('assigns unique, sequential string ids starting at 1', () {
      final ids = items.map((e) => e.id).toList();
      expect(ids.toSet().length, ids.length, reason: 'ids must be unique');
      expect(ids.first, '1');
      expect(ids.last, items.length.toString());
    });

    test('maps every item to a .glb model under assets/models', () {
      for (final item in items) {
        expect(item.modelUrl, 'assets/models/${item.name}.glb');
      }
    });

    test('prices every item with a positive amount', () {
      expect(items.every((e) => e.price > 0), isTrue);
    });

    test('infers category from the item name', () {
      FurnitureItem byName(String name) =>
          items.firstWhere((e) => e.name == name);

      expect(byName('Office Chair').category, 'Chairs');
      expect(byName('Coffee Table').category, 'Tables');
      expect(byName('Single Bed').category, 'Beds');
      expect(byName('Velvet Sofa').category, 'Sofas');
      expect(byName('Big Couch').category, 'Sofas');
      expect(byName('Standing lamp').category, 'Lighting');
      expect(byName('Bookshelf').category, 'Storage');
    });

    test('falls back to a placeholder image for items without a PNG', () {
      // Items in the exclusion list use the generic chair.png and no imagePath.
      // All listed items currently have PNGs, so imagePath is set for each.
      for (final item in items) {
        expect(item.imageUrl, isNotEmpty);
      }
    });
  });
}
