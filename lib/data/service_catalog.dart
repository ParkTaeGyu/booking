class ServiceItem {
  const ServiceItem({
    required this.category,
    required this.name,
    required this.price,
    this.isFeatured = false,
  });

  final String category;
  final String name;
  final int price;
  final bool isFeatured;
}

const List<ServiceItem> allServices = [
  // 컷
  ServiceItem(category: '컷', name: '남성 사이드다운펌(커트포함)', price: 40000),
  ServiceItem(category: '컷', name: '앞머리컷', price: 2000),
  ServiceItem(category: '컷', name: '남성컷', price: 20000),
  ServiceItem(category: '컷', name: '남학생 컷', price: 18000),
  ServiceItem(category: '컷', name: '남성 두피스켈프(커트 포함)', price: 40000),
  ServiceItem(category: '컷', name: '여성컷', price: 23000),
  ServiceItem(category: '컷', name: '여학생 컷', price: 20000),
  ServiceItem(category: '컷', name: '여성 두피스켈프(커트포함)', price: 45000),

  // 일반펌
  ServiceItem(category: '일반펌', name: '남성 베이직펌', price: 60000),
  ServiceItem(category: '일반펌', name: '남성 프리미엄 베이직펌', price: 70000),
  ServiceItem(category: '일반펌', name: '앞머리펌', price: 35000),
  ServiceItem(category: '일반펌', name: '앞머리매직', price: 45000),
  ServiceItem(category: '일반펌', name: '다운펌', price: 35000),
  ServiceItem(category: '일반펌', name: '여성 베이직펌', price: 70000),
  ServiceItem(category: '일반펌', name: '여성 프리미엄 베이직펌', price: 80000),
  ServiceItem(category: '일반펌', name: '뿌리볼륨펌', price: 60000),

  // 열펌
  ServiceItem(category: '열펌', name: '디지털, 셋팅', price: 100000),
  ServiceItem(category: '열펌', name: '프리미엄 디지털 셋팅', price: 120000),
  ServiceItem(category: '열펌', name: '남성 볼륨매직', price: 90000),
  ServiceItem(category: '열펌', name: '남성 프리미엄 볼륨매직', price: 110000),
  ServiceItem(category: '열펌', name: '매직', price: 100000),
  ServiceItem(category: '열펌', name: '프리미엄 매직', price: 120000),
  ServiceItem(category: '열펌', name: '여성 볼륨매직', price: 110000),
  ServiceItem(category: '열펌', name: '여성 프리미엄 볼륨매직', price: 130000),
  ServiceItem(category: '열펌', name: '매직셋팅', price: 140000),
  ServiceItem(category: '열펌', name: '프리미엄 매직셋팅', price: 160000),

  // 염색
  ServiceItem(category: '염색', name: '뿌리염색', price: 45000),
  ServiceItem(category: '염색', name: '프리미엄 뿌리염색', price: 55000),
  ServiceItem(category: '염색', name: '남성컬러', price: 60000),
  ServiceItem(category: '염색', name: '남성 프리미엄 컬러', price: 70000),
  ServiceItem(category: '염색', name: '남성 탈색', price: 70000),
  ServiceItem(category: '염색', name: '여성 컬러', price: 70000),
  ServiceItem(category: '염색', name: '여성 프리미엄 컬러', price: 80000),
  ServiceItem(category: '염색', name: '여자 탈색', price: 70000),
  ServiceItem(category: '염색', name: '메니큐어,왁싱', price: 70000),
  ServiceItem(category: '염색', name: '염색 시 커트 만원', price: 10000),

  // 클리닉
  ServiceItem(category: '클리닉', name: '앰플큐티클영양(펌/염색 시 선택가능)', price: 10000),
  ServiceItem(category: '클리닉', name: '하오니코약식', price: 50000),
  ServiceItem(category: '클리닉', name: '하오니코클리닉', price: 80000),
  ServiceItem(category: '클리닉', name: '복구클리닉', price: 160000),
  ServiceItem(category: '클리닉', name: '두피스켈프', price: 40000),
  ServiceItem(category: '클리닉', name: '탈모케어솔루션', price: 50000),

  // 기타
  ServiceItem(category: '기타', name: '남성 샴푸', price: 10000),
  ServiceItem(category: '기타', name: '여성 샴푸', price: 13000),
  ServiceItem(category: '기타', name: '남성 스타일링(샴푸추가시+5000원)', price: 15000),
  ServiceItem(category: '기타', name: '기본드라이(샴푸 추가시 +5000원)', price: 20000),
  ServiceItem(category: '기타', name: '웨이브드라이(샴푸 추가시+5000원)', price: 23000),
];

const List<ServiceItem> featuredServices = [
  ServiceItem(category: '컷', name: '남성컷', price: 20000, isFeatured: true),
  ServiceItem(category: '컷', name: '여성컷', price: 23000, isFeatured: true),
  ServiceItem(category: '일반펌', name: '남성 베이직펌', price: 60000, isFeatured: true),
  ServiceItem(category: '일반펌', name: '여성 프리미엄 베이직펌', price: 80000, isFeatured: true),
  ServiceItem(category: '열펌', name: '프리미엄 디지털 셋팅', price: 120000, isFeatured: true),
  ServiceItem(category: '열펌', name: '여성 프리미엄 볼륨매직', price: 130000, isFeatured: true),
  ServiceItem(category: '염색', name: '프리미엄 뿌리염색', price: 55000, isFeatured: true),
  ServiceItem(category: '염색', name: '여성 프리미엄 컬러', price: 80000, isFeatured: true),
  ServiceItem(category: '클리닉', name: '하오니코클리닉', price: 80000, isFeatured: true),
  ServiceItem(category: '클리닉', name: '복구클리닉', price: 160000, isFeatured: true),
];
