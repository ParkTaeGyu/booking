import '../models/service_item.dart';

const List<String> kServiceCategoryOrder = [
  '컷',
  '펌',
  '열펌',
  '염색',
  '클리닉',
  '기타',
];

int compareServiceCategory(String a, String b) {
  final indexA = kServiceCategoryOrder.indexOf(a);
  final indexB = kServiceCategoryOrder.indexOf(b);
  final aRank = indexA == -1 ? kServiceCategoryOrder.length : indexA;
  final bRank = indexB == -1 ? kServiceCategoryOrder.length : indexB;
  if (aRank != bRank) return aRank.compareTo(bRank);
  return a.compareTo(b);
}

List<String> sortedCategories(List<ServiceItem> services) {
  final seen = <String>{};
  final categories = <String>[];
  for (final service in services) {
    if (seen.add(service.category)) {
      categories.add(service.category);
    }
  }
  categories.sort(compareServiceCategory);
  return categories;
}
