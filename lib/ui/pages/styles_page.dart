import 'package:flutter/material.dart';

import '../../models/service_item.dart';
import '../../state/booking_store.dart';
import '../../utils/service_sort.dart';
import '../widgets/common.dart';

class StylesPage extends StatelessWidget {
  const StylesPage({super.key, required this.store});

  final BookingStore store;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final services = store.services;
        final grouped = _groupByCategory(services);
        final orderedCategories = grouped.keys.toList()
          ..sort(compareServiceCategory);
        return Scaffold(
          appBar: AppBar(
            title: const Text('헤어 스타일 소개'),
          ),
          body: Stack(
            children: [
              const BackgroundShape(),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '서비스 & 가격',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '카테고리별로 서비스 정보를 확인할 수 있어요.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.black54),
                      ),
                      const SizedBox(height: 16),
                      if (services.isEmpty)
                        Text(
                          '서비스 정보를 불러오는 중입니다.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.black54),
                        )
                      else
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final width = constraints.maxWidth;
                              final columns = width >= 1100
                                  ? 3
                                  : width >= 720
                                      ? 2
                                      : 1;
                              return SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: orderedCategories.map((category) {
                                    final items = grouped[category] ?? const [];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 24),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            category,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium,
                                          ),
                                          const SizedBox(height: 12),
                                          GridView.builder(
                                            itemCount: items.length,
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: columns,
                                              crossAxisSpacing: 16,
                                              mainAxisSpacing: 16,
                                              childAspectRatio: 0.88,
                                            ),
                                            itemBuilder: (context, index) {
                                              final item = items[index];
                                              return _StyleCard(
                                                item: item,
                                                index: index,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, List<ServiceItem>> _groupByCategory(
    List<ServiceItem> services,
  ) {
    final map = <String, List<ServiceItem>>{};
    for (final service in services) {
      map.putIfAbsent(service.category, () => []).add(service);
    }
    return map;
  }
}

class _StyleCard extends StatelessWidget {
  const _StyleCard({
    required this.item,
    required this.index,
  });

  final ServiceItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        'https://picsum.photos/seed/salon-${index + 1}/600/420';
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.category,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.black54),
                ),
                const SizedBox(height: 6),
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  formatPrice(item.price),
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontSize: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
