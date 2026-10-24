import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Data collected across the business signup steps.
///
/// Kept in memory only (the password is never written to disk before the
/// account exists) and cleared once the listing is activated.
class BusinessSignupDraft {
  const BusinessSignupDraft({
    this.legalName = '',
    this.businessName = '',
    this.contactName = '',
    this.contactTitle = '',
    this.email = '',
    this.phone = '',
    this.website = '',
    this.address = '',
    this.description = '',
    this.hours = '',
    this.serviceArea = '',
    this.password = '',
    this.categoryId,
    this.advertisingAddOns = const <String>{},
  });

  /// Name registered with the state / on the lease.
  final String legalName;

  /// Name shown to customers.
  final String businessName;

  final String contactName;
  final String contactTitle;
  final String email;
  final String phone;
  final String website;
  final String address;
  final String description;
  final String hours;
  final String serviceArea;
  final String password;
  final String? categoryId;

  /// Ids from `advertisingProducts` the business asked to be quoted for.
  final Set<String> advertisingAddOns;

  /// True once the business-information step has been completed.
  bool get hasBusinessInfo =>
      businessName.trim().isNotEmpty &&
      categoryId != null &&
      email.trim().isNotEmpty &&
      password.isNotEmpty;

  BusinessSignupDraft copyWith({
    String? legalName,
    String? businessName,
    String? contactName,
    String? contactTitle,
    String? email,
    String? phone,
    String? website,
    String? address,
    String? description,
    String? hours,
    String? serviceArea,
    String? password,
    String? categoryId,
    Set<String>? advertisingAddOns,
  }) {
    return BusinessSignupDraft(
      legalName: legalName ?? this.legalName,
      businessName: businessName ?? this.businessName,
      contactName: contactName ?? this.contactName,
      contactTitle: contactTitle ?? this.contactTitle,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      address: address ?? this.address,
      description: description ?? this.description,
      hours: hours ?? this.hours,
      serviceArea: serviceArea ?? this.serviceArea,
      password: password ?? this.password,
      categoryId: categoryId ?? this.categoryId,
      advertisingAddOns: advertisingAddOns ?? this.advertisingAddOns,
    );
  }
}

class BusinessSignupDraftController extends Notifier<BusinessSignupDraft> {
  @override
  BusinessSignupDraft build() => const BusinessSignupDraft();

  void saveBusinessInfo(BusinessSignupDraft draft) => state = draft;

  void toggleAddOn(String id) {
    final next = state.advertisingAddOns.toSet();
    if (!next.remove(id)) next.add(id);
    state = state.copyWith(advertisingAddOns: next);
  }

  void reset() => state = const BusinessSignupDraft();
}

final businessSignupDraftProvider =
    NotifierProvider<BusinessSignupDraftController, BusinessSignupDraft>(
  BusinessSignupDraftController.new,
);
