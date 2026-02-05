import 'package:flutter/material.dart';

import '../../state/booking_store.dart';
import '../../config/env.dart';
import '../widgets/common.dart';
import 'admin_page.dart';
import 'customer_page.dart';
import 'styles_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.store});

  final BookingStore store;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return Scaffold(
          body: Stack(
            children: [
              const BackgroundShape(),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      _TopBar(
                        autoApprove: store.autoApprove,
                        onAutoApproveChanged: (value) {
                          store.setAutoApprove(value);
                        },
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: store.ready
                            ? Column(
                                children: [
                                  if (!Env.isConfigured)
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        '환경변수(SUPABASE_URL / SUPABASE_ANON_KEY)가 설정되지 않았습니다.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: Colors.redAccent),
                                      ),
                                    ),
                                  if (store.lastError != null)
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        '예약 데이터를 불러오지 못했습니다. (${store.lastError})',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: Colors.redAccent),
                                      ),
                                    ),
                                  Expanded(
                                    child: _RouteTiles(
                                      onCustomerTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => CustomerPage(store: store),
                                          ),
                                        );
                                      },
                                      onStylesTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => StylesPage(store: store),
                                          ),
                                        );
                                      },
                                      onAdminTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => AdminPage(store: store),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              )
                            : const Center(child: CircularProgressIndicator()),
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
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.autoApprove,
    required this.onAutoApproveChanged,
  });

  final bool autoApprove;
  final ValueChanged<bool> onAutoApproveChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 720;
        final toggleCard = Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black.withValues(alpha: 0.08),
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome, size: 20),
              const SizedBox(width: 8),
              Text(
                '자동확정',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(width: 8),
              Switch(
                value: autoApprove,
                onChanged: onAutoApproveChanged,
              ),
            ],
          ),
        );

        final titleBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Maison Bloom',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '미용실 예약 관리 대시보드',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                  ),
            ),
          ],
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleBlock,
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: toggleCard),
            ],
          );
        }

        return Row(
          children: [
            titleBlock,
            const Spacer(),
            toggleCard,
          ],
        );
      },
    );
  }
}

class _RouteTiles extends StatelessWidget {
  const _RouteTiles({
    required this.onCustomerTap,
    required this.onStylesTap,
    required this.onAdminTap,
  });

  final VoidCallback onCustomerTap;
  final VoidCallback onStylesTap;
  final VoidCallback onAdminTap;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 920;
    final children = [
      _RouteCard(
        title: '예약 신청 (고객)',
        subtitle: '카테고리별 서비스를 선택해 예약을 신청합니다.',
        bulletPoints: const ['30분 단위 예약', '서비스 다중 선택', '자동확정 옵션'],
        icon: Icons.event_available,
        onTap: onCustomerTap,
      ),
      _RouteCard(
        title: '헤어 스타일 소개',
        subtitle: '카테고리별 서비스와 가격 정보를 확인합니다.',
        bulletPoints: const ['DB 연동 서비스', '카테고리 정렬', '가격 표시'],
        icon: Icons.style,
        onTap: onStylesTap,
      ),
      _RouteCard(
        title: '예약 관리 (관리자)',
        subtitle: '대기/확정/거절을 관리하고 예약을 정렬합니다.',
        bulletPoints: const ['상태 필터', '정렬 기준', '승인/거절 처리'],
        icon: Icons.dashboard_customize,
        onTap: onAdminTap,
      ),
    ];

    return isWide
        ? Row(
            children: [
              Expanded(child: children[0]),
              const SizedBox(width: 16),
              Expanded(child: children[1]),
              const SizedBox(width: 16),
              Expanded(child: children[2]),
            ],
          )
        : ListView.separated(
            itemCount: children.length,
            separatorBuilder: (context, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) => children[index],
          );
  }
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({
    required this.title,
    required this.subtitle,
    required this.bulletPoints,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final List<String> bulletPoints;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .secondary
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 22, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            for (final bullet in bulletPoints)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.check, size: 16, color: Colors.black54),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        bullet,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('페이지 열기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
