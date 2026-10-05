import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:reaple_app/core/utils/format.dart';
import 'package:reaple_app/core/widgets/error_banner.dart';
import 'package:reaple_app/core/widgets/primary_button.dart';
import 'package:reaple_app/features/product/data/product_models.dart';

enum VariantAction { addToCart, buyNow }

class VariantSelection {
  const VariantSelection(this.variant, this.qty);

  final VariantModel variant;
  final int qty;
}

/// Popup pilihan sebelum menambah ke keranjang atau membeli langsung.
Future<VariantSelection?> showVariantPicker(
  BuildContext context, {
  required ProductModel product,
  required VariantAction action,
}) {
  return showModalBottomSheet<VariantSelection>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 600),
    builder: (_) => _VariantPickerSheet(product: product, action: action),
  );
}

class _ModelOption {
  const _ModelOption(this.id, this.name);

  final int id;
  final String name;
}

class _VariantPickerSheet extends StatefulWidget {
  const _VariantPickerSheet({required this.product, required this.action});

  final ProductModel product;
  final VariantAction action;

  @override
  State<_VariantPickerSheet> createState() => _VariantPickerSheetState();
}

class _VariantPickerSheetState extends State<_VariantPickerSheet> {
  static const _gradeOrder = ['standar', 'premium', 'original'];

  int? _modelId;
  String? _grade;
  int? _variantId;
  int _qty = 1;

  ProductModel get _p => widget.product;
  bool get _isUnlock => _p.options.needsDuration;
  bool get _needsGrade => _p.options.needsGrade;

  List<_ModelOption> get _models {
    final seen = <int>{};
    final out = <_ModelOption>[];
    for (final v in _p.variants) {
      final id = v.iphoneModelId;
      if (id == null || !seen.add(id)) continue;
      out.add(_ModelOption(id, v.iphoneModel ?? 'iPhone'));
    }
    return out;
  }

  List<VariantModel> get _modelVariants => _p.variants.where((v) => v.iphoneModelId == _modelId).toList();

  List<VariantModel> get _gradeVariants {
    final list = _modelVariants.where((v) => v.grade != null).toList();
    list.sort((a, b) => _gradeOrder.indexOf(a.grade!).compareTo(_gradeOrder.indexOf(b.grade!)));
    return list;
  }

  VariantModel? get _selected {
    if (_isUnlock) {
      for (final v in _p.variants) {
        if (v.id == _variantId) return v;
      }
      return null;
    }

    if (_modelId == null) return null;

    final candidates = _modelVariants;
    if (_needsGrade) {
      for (final v in candidates) {
        if (v.grade == _grade) return v;
      }
      return null;
    }

    return candidates.isEmpty ? null : candidates.first;
  }

  int _maxQty(VariantModel? v) {
    if (v == null || !_needsGrade) return 1;
    return math.max(1, math.min(5, v.stock));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chosen = _selected;
    final maxQty = _maxQty(chosen);
    final total = chosen == null ? null : chosen.finalPrice * _qty;
    final isBuy = widget.action == VariantAction.buyNow;
    final inspection = _p.options.inspectionOnly;

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_p.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(
                    isBuy ? 'Pilih opsi, lalu lanjut ke alamat dan jadwal.' : 'Pilih opsi yang akan dimasukkan ke keranjang.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),
                  if (inspection) ...[
                    ErrorBanner(
                      'Anda hanya membayar ongkir/pengecekan sebesar ${Fmt.rupiah(_p.baseFee)}. '
                      'Estimasi perbaikan tidak dihitung di awal, teknisi hanya mencari kerusakan.',
                      isInfo: true,
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (_isUnlock) ..._durationSection(theme) else ..._modelSection(theme),
                  if (_needsGrade) ..._gradeSection(theme),
                  if (_needsGrade && chosen != null && chosen.available) ..._qtySection(theme, maxQty),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(inspection ? 'Biaya ongkir/pengecekan' : 'Total'),
                    const Spacer(),
                    Text(
                      total == null ? '-' : Fmt.rupiah(total),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: isBuy ? 'Lanjut Beli' : 'Masukkan Keranjang',
                  onPressed: (chosen != null && chosen.available)
                      ? () => Navigator.of(context).pop(VariantSelection(chosen, _qty))
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle? _sectionStyle(ThemeData theme) => theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700);

  List<Widget> _modelSection(ThemeData theme) {
    final models = _models;

    return [
      Text('Tipe iPhone', style: _sectionStyle(theme)),
      const SizedBox(height: 10),
      if (models.isEmpty)
        const Text('Belum ada tipe iPhone yang tersedia.')
      else
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final m in models)
              ChoiceChip(
                label: Text(m.name),
                selected: _modelId == m.id,
                onSelected: (_) => setState(() {
                  _modelId = m.id;
                  _grade = null;
                  _qty = 1;
                }),
              ),
          ],
        ),
      const SizedBox(height: 20),
    ];
  }

  List<Widget> _gradeSection(ThemeData theme) {
    final grades = _gradeVariants;

    return [
      Text('Grade sparepart', style: _sectionStyle(theme)),
      const SizedBox(height: 10),
      if (_modelId == null)
        Text('Pilih tipe iPhone terlebih dahulu.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant))
      else if (grades.isEmpty)
        const Text('Grade belum tersedia untuk tipe ini.')
      else
        for (final v in grades)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _OptionTile(
              title: v.gradeLabel ?? v.grade ?? '-',
              subtitle: v.available ? 'Stok ${v.stock}' : 'Stok habis',
              price: Fmt.rupiah(v.finalPrice),
              selected: _grade == v.grade,
              enabled: v.available,
              onTap: () => setState(() {
                _grade = v.grade;
                _qty = 1;
              }),
            ),
          ),
      const SizedBox(height: 12),
    ];
  }

  List<Widget> _durationSection(ThemeData theme) {
    return [
      Text('Durasi', style: _sectionStyle(theme)),
      const SizedBox(height: 10),
      if (_p.variants.isEmpty)
        const Text('Belum ada pilihan durasi yang tersedia.')
      else
        for (final v in _p.variants)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _OptionTile(
              title: v.durationLabel ?? '-',
              price: Fmt.rupiah(v.finalPrice),
              selected: _variantId == v.id,
              enabled: v.available,
              onTap: () => setState(() => _variantId = v.id),
            ),
          ),
      const SizedBox(height: 12),
    ];
  }

  List<Widget> _qtySection(ThemeData theme, int maxQty) {
    return [
      Row(
        children: [
          Text('Jumlah', style: _sectionStyle(theme)),
          const Spacer(),
          IconButton.outlined(
            tooltip: 'Kurangi',
            onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
            icon: const Icon(Icons.remove_rounded),
          ),
          SizedBox(width: 44, child: Text('$_qty', textAlign: TextAlign.center, style: theme.textTheme.titleMedium)),
          IconButton.outlined(
            tooltip: 'Tambah',
            onPressed: _qty < maxQty ? () => setState(() => _qty++) : null,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      const SizedBox(height: 12),
    ];
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.title,
    required this.price,
    required this.selected,
    required this.enabled,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final String price;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: selected ? scheme.primaryContainer : scheme.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: selected ? scheme.primary : scheme.outlineVariant, width: selected ? 2 : 1),
        ),
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(selected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                      if (subtitle != null) Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Text(price, style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}