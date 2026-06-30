import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';

/// Hasil transaksi dari Midtrans — setara TransactionResult di Android SDK native
enum MidtransTxStatus {
  success,   // STATUS_SUCCESS
  pending,   // STATUS_PENDING
  failed,    // STATUS_FAILED
  cancelled, // STATUS_CANCELED
  invalid,   // STATUS_INVALID
}

class MidtransResult {
  final MidtransTxStatus status;
  final String? transactionId;
  final String? message;

  const MidtransResult({
    required this.status,
    this.transactionId,
    this.message,
  });
}

/// WebView untuk Midtrans Snap — fungsinya setara dengan
/// UiKitApi.getDefaultInstance().startPaymentUiFlow() di Android SDK native.
///
/// Snap akan redirect ke salah satu URL berikut setelah transaksi selesai:
///   - https://yourapp.com/finish    (transaction_status=settlement/capture)
///   - https://yourapp.com/unfinish  (transaction_status=pending)
///   - https://yourapp.com/error     (transaction_status=deny/expire/cancel)
///
/// Kita deteksi via URL pattern karena tidak ada native callback di WebView.
class MidtransWebViewScreen extends StatefulWidget {
  final String redirectUrl;
  final String orderId;

  const MidtransWebViewScreen({
    super.key,
    required this.redirectUrl,
    required this.orderId,
  });

  @override
  State<MidtransWebViewScreen> createState() => _MidtransWebViewScreenState();
}

class _MidtransWebViewScreenState extends State<MidtransWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _resultSent = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);
            _checkUrlForResult(url);
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
            _checkUrlForResult(url);
          },
          onNavigationRequest: (request) {
            _checkUrlForResult(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.redirectUrl));
  }

  /// Deteksi status transaksi dari URL Snap callback
  /// Pola URL Midtrans Snap:
  ///   .../v2/vtweb/{token}                    → masih di halaman pembayaran
  ///   status_code=200&transaction_status=settlement → sukses
  ///   status_code=201&transaction_status=pending     → pending
  ///   status_code=202 atau deny/cancel/expire        → gagal
  void _checkUrlForResult(String url) {
    if (_resultSent) return;

    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final params = uri.queryParameters;
    final transactionStatus = params['transaction_status'];
    final statusCode = params['status_code'];
    final orderId = params['order_id'] ?? widget.orderId;

    // Tutup otomatis kalau Snap sudah selesai memproses dan redirect keluar
    // dari domain midtrans (kembali ke finish/unfinish/error redirect URL)
    final isMidtransDomain = uri.host.contains('midtrans.com');

    if (!isMidtransDomain && (transactionStatus != null || statusCode != null)) {
      _resultSent = true;
      _sendResult(transactionStatus, orderId);
      return;
    }

    // Fallback: deteksi dari path close/finish Snap (tanpa query param)
    if (url.contains('/snap/v2/track') ||
        url.contains('finish') ||
        url.contains('unfinish') ||
        url.contains('error')) {
      if (transactionStatus != null) {
        _resultSent = true;
        _sendResult(transactionStatus, orderId);
      }
    }
  }

  void _sendResult(String? transactionStatus, String orderId) {
    MidtransTxStatus status;
    switch (transactionStatus) {
      case 'capture':
      case 'settlement':
        status = MidtransTxStatus.success;
        break;
      case 'pending':
        status = MidtransTxStatus.pending;
        break;
      case 'deny':
      case 'expire':
        status = MidtransTxStatus.failed;
        break;
      case 'cancel':
        status = MidtransTxStatus.cancelled;
        break;
      default:
        status = MidtransTxStatus.invalid;
    }

    Navigator.of(context).pop(
      MidtransResult(
        status: status,
        transactionId: orderId,
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18)),
        title: Text('Batalkan Pembayaran?',
            style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text(
          'Transaksi belum selesai. Yakin ingin keluar?',
          style: GoogleFonts.inter(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Lanjut Bayar',
                style: GoogleFonts.inter(color: AppColors.electricBlue)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Keluar',
                style: GoogleFonts.inter(color: AppColors.errorRed)),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop(
            const MidtransResult(status: MidtransTxStatus.cancelled),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.pageBg,
        appBar: AppBar(
          title: Text('Pembayaran',
              style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.w700)),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, size: 22),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                Navigator.of(context).pop(
                  const MidtransResult(status: MidtransTxStatus.cancelled),
                );
              }
            },
          ),
        ),
        body: Stack(children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: AppColors.pageBg,
              child: const Center(
                child: CircularProgressIndicator(
                    color: AppColors.electricBlue),
              ),
            ),
        ]),
      ),
    );
  }
}
