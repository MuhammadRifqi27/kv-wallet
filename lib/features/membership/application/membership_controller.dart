import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../data/models/membership_plan_model.dart';
import '../../../data/models/membership_status_model.dart';

final membershipPlansProvider = FutureProvider.autoDispose<List<MembershipPlan>>((ref) {
  return ref.read(membershipRepositoryProvider).getPlans();
});

final membershipStatusProvider = FutureProvider.autoDispose<MembershipStatus>((ref) {
  return ref.read(membershipRepositoryProvider).getStatus();
});
