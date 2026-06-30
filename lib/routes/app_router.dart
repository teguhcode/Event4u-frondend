import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models/transaction_model.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/detail/event_detail_screen.dart';
import '../presentation/screens/checkout/checkout_screen.dart';
import '../presentation/screens/payment/payment_screen.dart';
import '../presentation/screens/payment/payment_success_screen.dart';
import '../presentation/screens/eticket/eticket_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/search/search_screen.dart';
import '../presentation/screens/tickets/my_tickets_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';
import '../presentation/widgets/main_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: AppRoutes.search,
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: SearchScreen()),
          ),
          GoRoute(
            path: AppRoutes.myTickets,
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: MyTicketsScreen()),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.eventDetail,
        builder: (_, state) => EventDetailScreen(
          eventId: int.tryParse(state.pathParameters['id'] ?? '1') ?? 1,
        ),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        builder: (_, state) =>
            CheckoutScreen(args: state.extra as CheckoutArgs),
      ),
      GoRoute(
        path: AppRoutes.payment,
        builder: (_, state) =>
            PaymentScreen(args: state.extra as PaymentArgs),
      ),
      GoRoute(
        path: AppRoutes.paymentSuccess,
        builder: (_, state) => PaymentSuccessScreen(
          transaction: state.extra as TransactionModel,
        ),
      ),
      GoRoute(
        path: AppRoutes.eticket,
        builder: (_, state) =>
            ETicketScreen(eTicket: state.extra as ETicketModel),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, state) => LoginScreen(
          redirectPath: state.uri.queryParameters['redirect'],
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterScreen(),
      ),
    ],
  );
});

class AppRoutes {
  static const home           = '/';
  static const search         = '/search';
  static const myTickets      = '/tickets';
  static const profile        = '/profile';
  static const eventDetail    = '/event/:id';
  static const checkout       = '/checkout';
  static const payment        = '/payment';
  static const paymentSuccess = '/payment/success';
  static const eticket        = '/eticket';
  static const login          = '/login';
  static const register       = '/register';

  static String eventDetailPath(int id) => '/event/$id';
}

class CheckoutArgs {
  final int eventId;
  final String eventName;
  final String eventDate;
  final String eventTime;
  final int ticketTypeId;
  final String ticketTypeName;
  final int ticketPrice;
  final int quantity;

  const CheckoutArgs({
    required this.eventId,
    required this.eventName,
    required this.eventDate,
    required this.eventTime,
    required this.ticketTypeId,
    required this.ticketTypeName,
    required this.ticketPrice,
    required this.quantity,
  });
}

class PaymentArgs {
  final String orderId;
  final String? snapToken;
  final String? redirectUrl;
  final int totalAmount;
  final String expiryTime;
  final String? vaNumber;
  final String? qrisImageUrl;
  final String paymentMethod;
  final int? transactionId;

  const PaymentArgs({
    required this.orderId,
    this.snapToken,
    this.redirectUrl,
    required this.totalAmount,
    required this.expiryTime,
    this.vaNumber,
    this.qrisImageUrl,
    required this.paymentMethod,
    this.transactionId,
  });
}
