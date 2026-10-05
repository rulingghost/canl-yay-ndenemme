class GiftItem {
  final String id;
  final String name;
  final String icon;
  final int cost;

  const GiftItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.cost,
  });
}

class GiftList {
  static const List<GiftItem> items = [
    GiftItem(id: 'rose', name: 'Gül', icon: '🌹', cost: 10),
    GiftItem(id: 'heart', name: 'Kalp', icon: '💖', cost: 50),
    GiftItem(id: 'coffee', name: 'Kahve', icon: '☕', cost: 100),
    GiftItem(id: 'rocket', name: 'Roket', icon: '🚀', cost: 250),
    GiftItem(id: 'crown', name: 'Altın Taç', icon: '👑', cost: 500),
    GiftItem(id: 'sports_car', name: 'Spor Araba', icon: '🏎️', cost: 1000),
    GiftItem(id: 'yacht', name: 'Yat', icon: '🛥️', cost: 2000),
    GiftItem(id: 'castle', name: 'Şato', icon: '🏰', cost: 5000),
  ];
}
