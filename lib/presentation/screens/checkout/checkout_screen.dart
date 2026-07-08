import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/transaction_model.dart';
import '../../../routes/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/main_scaffold.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final CheckoutArgs args;
  const CheckoutScreen({super.key, required this.args});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _promoCtrl = TextEditingController();
  double _discount = 0;
  bool _promoApplied = false;
  String _promoMsg = '';

  static const double _serviceFee = 5000;

  double get _subtotal =>
      widget.args.ticketPrice * widget.args.quantity.toDouble();
  double get _total => _subtotal - _discount + _serviceFee;

  String _rp(double v) {
    final s = v.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return 'Rp$s';
  }

  // Validasi promo lokal sesuai dengan seeder
  void _applyPromo() {
    final code = _promoCtrl.text.trim().toUpperCase();
    setState(() {
      if (code == 'SEPTEMBERCERIA') {
        _discount = _subtotal * 0.15;
        _promoApplied = true;
        _promoMsg = 'Promo SEPTEMBERCERIA: diskon 15% (${_rp(_discount)})';
      } else if (code == 'CUCIGUDANG') {
        _discount = _subtotal * 0.10;
        _promoApplied = true;
        _promoMsg = 'Promo CUCIGUDANG: diskon 10% (${_rp(_discount)})';
      } else if (code.isEmpty) {
        _promoApplied = false;
        _discount = 0;
        _promoMsg = '';
      } else {
        _promoApplied = false;
        _discount = 0;
        _promoMsg = 'Kode promo tidak valid atau sudah kadaluarsa.';
      }
    });
  }

  /// POST /api/transactions/checkout → backend buat Snap Token via Midtrans
  Future<void> _doCheckout() async {
    final req = CheckoutRequest(
      eventId:   widget.args.eventId,
      quantity:  widget.args.quantity,
      promoCode: _promoApplied ? _promoCtrl.text.trim() : null,
      // payment_method tidak dikirim — Midtrans Snap akan tampilkan
      // semua opsi pembayaran (QRIS, VA, GoPay, dll) di halaman mereka
    );

    final tx = await ref.read(checkoutProvider.notifier).checkout(req);

    if (!mounted) return;
    if (tx != null) {
      context.push(
        AppRoutes.payment,
        extra: PaymentArgs(
          orderId:       tx.displayOrderId,
          snapToken:     tx.snapToken,
          redirectUrl:   tx.redirectUrl,
          totalAmount:   tx.total.toInt(),
          expiryTime:    DateTime.now()
              .add(const Duration(hours: 24))
              .toIso8601String(),
          paymentMethod: 'midtrans',
          transactionId: tx.id,
        ),
      );
    }
  }

  @override
  void dispose() {
    _promoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checkoutState = ref.watch(checkoutProvider);
    final user = ref.read(authProvider).user;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          child: Column(children: [
            // ── Ticket Summary ────────────────────────────────────────
            _Section(title: 'Ringkasan Tiket', child: Column(children: [
              _Row(label: 'Event',
                  value: widget.args.eventName, small: true),
              _Row(label: 'Tanggal',
                  value: '${widget.args.eventDate} · ${widget.args.eventTime}'),
              _Row(label: 'Kategori', value: widget.args.ticketTypeName),
              _Row(label: 'Jumlah', value: '${widget.args.quantity} Tiket'),
              _Row(label: 'Subtotal', value: _rp(_subtotal), last: true),
            ])),
            const SizedBox(height: 12),

            // ── Pemesan ───────────────────────────────────────────────
            if (user != null)
              _Section(title: 'Data Pemesan', child: Column(children: [
                _Row(label: 'Nama', value: user.name),
                _Row(label: 'Email', value: user.email, last: true),
              ])),
            if (user != null) const SizedBox(height: 12),

            // ── Promo ─────────────────────────────────────────────────
            _Section(title: 'Kode Promo', child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _promoCtrl,
                    textCapitalization: TextCapitalization.characters,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Masukkan kode promo',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.border)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: AppColors.electricBlue, width: 1.5)),
                      filled: true,
                      fillColor: AppColors.pageBg,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _applyPromo,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                        color: AppColors.deepIndigo,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text('Terapkan',
                        style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
              ]),
              if (_promoMsg.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _promoApplied
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _promoApplied ? '✓  $_promoMsg' : '✗  $_promoMsg',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: _promoApplied
                            ? const Color(0xFF059669)
                            : AppColors.errorRed,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ])),
            const SizedBox(height: 12),

            // ── Payment Detail ────────────────────────────────────────
            _Section(title: 'Rincian Pembayaran', child: Column(children: [
              _Row(label: 'Subtotal', value: _rp(_subtotal)),
              if (_promoApplied)
                _Row(label: 'Diskon Promo',
                    value: '−${_rp(_discount)}',
                    valueColor: const Color(0xFF059669)),
              _Row(label: 'Biaya Layanan', value: _rp(_serviceFee)),
              _Row(label: 'Total Bayar', value: _rp(_total),
                  bold: true, valueColor: AppColors.electricBlue,
                  last: true),
            ])),

          ]),
        ),

        // ── Sticky Bottom Bar ─────────────────────────────────────────
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(
                16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
            decoration: const BoxDecoration(
              color: AppColors.cardBg,
              border: Border(
                  top: BorderSide(color: AppColors.border, width: 0.5)),
            ),
            child: Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, children: [
                Text('Total Bayar',
                    style: GoogleFonts.inter(
                        fontSize: 11, color: AppColors.textSecondary)),
                Text(_rp(_total),
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
              ]),
              const SizedBox(width: 16),
              Expanded(
                child: AppButton(
                  label: checkoutState.isLoading
                      ? 'Memproses...'
                      : 'Lanjutkan Pembayaran',
                  onTap: checkoutState.isLoading ? null : _doCheckout,
                  loading: checkoutState.isLoading,
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────
class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          child,
        ]),
      );
}

class _Row extends StatelessWidget {
  final String label, value;
  final bool bold, small, last;
  final Color? valueColor;
  const _Row({required this.label, required this.value,
      this.bold = false, this.small = false, this.last = false,
      this.valueColor});

  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(children: [
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: bold ? 13 : 12,
                    fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                    color: AppColors.textSecondary)),
            const Spacer(),
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: bold ? 15 : (small ? 11 : 12),
                    fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
                    color: valueColor ?? AppColors.textPrimary),
                textAlign: TextAlign.right, maxLines: 2),
          ]),
        ),
        if (!last) const Divider(
            height: 1, thickness: 0.5, color: AppColors.border),
      ]);
}
