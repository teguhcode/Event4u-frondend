class EventItem {
  final int id;
  final String name;
  final String date;
  final String time;
  final String price;
  final String emoji;
  final int colorValue;

  const EventItem({
    required this.id,
    required this.name,
    required this.date,
    required this.time,
    required this.price,
    required this.emoji,
    required this.colorValue,
  });
}

const List<EventItem> allEvents = [
  EventItem(id: 1,  name: 'Dua Lipa — Future Nostalgia Tour', date: '31 Des 2024', time: '19:00 WIB', price: 'Rp150.000', emoji: '🎤', colorValue: 0xFFEFF4FF),
  EventItem(id: 2,  name: 'Coldplay World Tour 2026',          date: '15 Agt 2026', time: '20:00 WIB', price: 'Rp750.000', emoji: '🎸', colorValue: 0xFFFFF0EB),
  EventItem(id: 3,  name: 'Tech Summit Bali 2026',             date: '5 Sep 2026',  time: '09:00 WIB', price: 'Rp350.000', emoji: '🎓', colorValue: 0xFFECFDF5),
  EventItem(id: 4,  name: 'Pameran Seni Nusantara 2026',       date: '1 Agt 2026',  time: '09:00 WIB', price: 'Rp50.000',  emoji: '🎭', colorValue: 0xFFFDF0FF),
  EventItem(id: 5,  name: 'Bali Food Festival 2026',           date: '18 Okt 2026', time: '10:00 WIB', price: 'Gratis',    emoji: '🍜', colorValue: 0xFFFFF7ED),
  EventItem(id: 6,  name: 'Seminar Digital Marketing',         date: '12 Jun 2026', time: '09:00 WIB', price: 'Rp75.000',  emoji: '📊', colorValue: 0xFFEFF4FF),
  EventItem(id: 7,  name: 'Java Jazz Festival 2026',           date: '24 Mei 2026', time: '18:00 WIB', price: 'Rp250.000', emoji: '🎹', colorValue: 0xFFFFF0EB),
  EventItem(id: 8,  name: 'Bali Marathon 2026',                date: '26 Jul 2026', time: '05:00 WIB', price: 'Rp350.000', emoji: '🏃', colorValue: 0xFFECFDF5),
  EventItem(id: 9,  name: 'Workshop UI/UX Design',             date: '3 Agt 2026',  time: '10:00 WIB', price: 'Rp200.000', emoji: '🎨', colorValue: 0xFFFDF0FF),
  EventItem(id: 10, name: 'Konser Sheila On 7',                date: '17 Mei 2026', time: '19:00 WIB', price: 'Rp200.000', emoji: '🎵', colorValue: 0xFFEFF4FF),
];

List<EventItem> searchEvents(String query) {
  if (query.trim().isEmpty) return allEvents;
  final q = query.toLowerCase();
  return allEvents.where((e) =>
    e.name.toLowerCase().contains(q) ||
    e.date.toLowerCase().contains(q) ||
    e.price.toLowerCase().contains(q)
  ).toList();
}
