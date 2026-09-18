import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/home_screen/home_screen.dart';
import '../presentation/live_tracking_screen/live_tracking_screen.dart';
import '../presentation/sign_up_login_screen/sign_up_login_screen.dart';
import '../presentation/technician_job_queue_screen/technician_job_queue_screen.dart';
import '../presentation/payment_screen/payment_screen.dart';
import '../presentation/booking_confirmation_screen/booking_confirmation_screen.dart';
import '../presentation/order_confirmation_screen/order_confirmation_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/pre_checkout_screen/pre_checkout_screen.dart';
import '../presentation/homeowner_profile_screen/homeowner_profile_screen.dart';
import '../widgets/app_scaffold.dart';
import '../presentation/notifications_screen/notifications_screen.dart';
import '../presentation/ai_diagnosis_screen/ai_diagnosis_screen.dart';
import '../presentation/role_selection_screen/role_selection_screen.dart';
import '../presentation/partner_dashboard_screen/partner_dashboard_screen.dart';
import '../presentation/partner_navigation_screen/partner_navigation_screen.dart';
import '../presentation/subscription_plan_screen/subscription_plan_screen.dart';
import '../presentation/job_chat_screen/job_chat_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String splashScreen = '/';
  static const String homeScreen = '/home-screen';
  static const String signUpLoginScreen = '/sign-up-login-screen';
  static const String liveTrackingScreen = '/live-tracking-screen';
  static const String technicianJobQueueScreen = '/technician-job-queue-screen';
  static const String preCheckoutScreen = '/pre-checkout-screen';
  static const String paymentScreen = '/payment-screen';
  static const String bookingConfirmationScreen =
      '/booking-confirmation-screen';
  static const String orderConfirmationScreen = '/order-confirmation-screen';
  static const String homeownerProfileScreen = '/homeowner-profile-screen';
  static const String notificationsScreen = '/notifications-screen';
  static const String aiDiagnosisScreen = '/ai-diagnosis-screen';
  static const String roleSelectionScreen = '/role-selection-screen';
  static const String partnerDashboardScreen = '/partner-dashboard-screen';
  static const String partnerNavigationScreen = '/partner-navigation-screen';
  static const String subscriptionPlanScreen = '/subscription-plan-screen';
  static const String jobChatScreen = '/job-chat-screen';

  // Partner shell home (entry point for partner bottom nav)
  static const String partnerHomeScreen = '/partner-home-screen';
  static const String partnerJobQueueScreen = '/partner-job-queue-screen';
  static const String partnerProfileScreen = '/partner-profile-screen';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.initial,
  routes: [
    GoRoute(
      path: AppRoutes.initial,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SplashScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    ),
    GoRoute(
      path: AppRoutes.signUpLoginScreen,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SignUpLoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    ),

    // ── Customer Shell (Home repairs / services layout) ──────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppScaffold(navigationShell: navigationShell, isPartner: false);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.homeScreen,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: HomeScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.technicianJobQueueScreen,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: TechnicianJobQueueScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.homeownerProfileScreen,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: HomeownerProfileScreen()),
            ),
          ],
        ),
      ],
    ),

    // ── Partner Shell (Technician Job Queue layout) ──────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppScaffold(navigationShell: navigationShell, isPartner: true);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.partnerHomeScreen,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: TechnicianJobQueueScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.partnerJobQueueScreen,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: TechnicianJobQueueScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.partnerProfileScreen,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: PartnerDashboardScreen()),
            ),
          ],
        ),
      ],
    ),

    GoRoute(
      path: AppRoutes.liveTrackingScreen,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const LiveTrackingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.04),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    ),
    GoRoute(
      path: AppRoutes.preCheckoutScreen,
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return CustomTransitionPage(
          key: state.pageKey,
          child: PreCheckoutScreen(bookingData: extra),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.04),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 280),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.paymentScreen,
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return CustomTransitionPage(
          key: state.pageKey,
          child: PaymentScreen(bookingData: extra),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.04),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 280),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.bookingConfirmationScreen,
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return CustomTransitionPage(
          key: state.pageKey,
          child: BookingConfirmationScreen(paymentData: extra),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.04),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 280),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.orderConfirmationScreen,
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return CustomTransitionPage(
          key: state.pageKey,
          child: OrderConfirmationScreen(orderData: extra),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.04),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 280),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.notificationsScreen,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const NotificationsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.04),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    ),
    GoRoute(
      path: AppRoutes.aiDiagnosisScreen,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const AiDiagnosisScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.04),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    ),
    GoRoute(
      path: AppRoutes.roleSelectionScreen,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const RoleSelectionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    ),
    GoRoute(
      path: AppRoutes.partnerDashboardScreen,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const PartnerDashboardScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    ),
    GoRoute(
      path: AppRoutes.partnerNavigationScreen,
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return CustomTransitionPage(
          key: state.pageKey,
          child: PartnerNavigationScreen(job: extra),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.04),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 280),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.subscriptionPlanScreen,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SubscriptionPlanScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.04),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    ),
    GoRoute(
      path: AppRoutes.jobChatScreen,
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return CustomTransitionPage(
          key: state.pageKey,
          child: JobChatScreen(chatData: extra),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.04),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 280),
        );
      },
    ),
  ],
);
