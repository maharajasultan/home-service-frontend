class Fmt {
  Fmt._();

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

  /// 1250000 -> Rp1.250.000
  static String rupiah(num value) {
    final n = value.round();
    final digits = n.abs().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');
    return '${n < 0 ? '-' : ''}Rp$digits';
  }

  static DateTime? parse(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    return DateTime.tryParse(iso)?.toLocal();
  }

  /// 4 Okt 2026
  static String date(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';
}