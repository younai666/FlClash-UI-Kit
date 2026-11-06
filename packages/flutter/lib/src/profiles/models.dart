// ignore_for_file: prefer_initializing_formals
// Host-owned profile models, controller, and InheritedNotifier scope
// (adapted from FlClash lib/models/profile.dart, lib/enum/enum.dart,
// lib/views/profiles/edit.dart, and lib/providers/actions/profiles.dart,
// commit be84736605527034689c95bf27828ff27d912c5e). GPL-3.0.

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

import '../dashboard/profile_model.dart';
import '../data.dart';
import '../dialogs.dart';
import '../input/limits.dart';
import '../iterable.dart';
import '../localizations.dart';
import '../proxies/models.dart';
import '../string.dart';

const profilesStoreKey = PageStorageKey<String>('profiles');
const defaultUpdateDuration = Duration(days: 1);
const profileListEquality = ListEquality<Profile>();

int _nextGeneratedProfileId = 1000;

enum ProfileType { file, url, custom }

const _unsetProfileField = Object();

@immutable
class Profile {
  final int id;
  final String? label;
  final String? currentGroupName;
  final String url;
  final String? ageSecretKey;
  final DateTime? lastUpdateDate;
  final Duration autoUpdateDuration;
  final SubscriptionInfo? subscriptionInfo;
  final bool autoUpdate;
  final Map<String, String> selectedMap;
  final Set<String> unfoldSet;
  final int? order;
  final ProfileType type;

  const Profile({
    required this.id,
    this.label,
    this.currentGroupName,
    this.url = '',
    this.ageSecretKey,
    this.lastUpdateDate,
    this.autoUpdateDuration = defaultUpdateDuration,
    this.subscriptionInfo,
    this.autoUpdate = true,
    this.selectedMap = const {},
    this.unfoldSet = const {},
    this.order,
    this.type = ProfileType.file,
  });

  factory Profile.normal({String? label, String url = ''}) {
    return Profile(
      label: label,
      url: url,
      id: _nextGeneratedProfileId++,
      type: url.isEmpty ? ProfileType.file : ProfileType.url,
      autoUpdateDuration: defaultUpdateDuration,
    );
  }

  factory Profile.custom({required String label}) {
    return Profile(
      label: label,
      id: _nextGeneratedProfileId++,
      type: ProfileType.custom,
      autoUpdate: false,
      autoUpdateDuration: defaultUpdateDuration,
    );
  }

  Profile copyWith({
    int? id,
    Object? label = _unsetProfileField,
    Object? currentGroupName = _unsetProfileField,
    String? url,
    Object? ageSecretKey = _unsetProfileField,
    Object? lastUpdateDate = _unsetProfileField,
    Duration? autoUpdateDuration,
    Object? subscriptionInfo = _unsetProfileField,
    bool? autoUpdate,
    Map<String, String>? selectedMap,
    Set<String>? unfoldSet,
    Object? order = _unsetProfileField,
    ProfileType? type,
  }) {
    return Profile(
      id: id ?? this.id,
      label: identical(label, _unsetProfileField)
          ? this.label
          : label as String?,
      currentGroupName: identical(currentGroupName, _unsetProfileField)
          ? this.currentGroupName
          : currentGroupName as String?,
      url: url ?? this.url,
      ageSecretKey: identical(ageSecretKey, _unsetProfileField)
          ? this.ageSecretKey
          : ageSecretKey as String?,
      lastUpdateDate: identical(lastUpdateDate, _unsetProfileField)
          ? this.lastUpdateDate
          : lastUpdateDate as DateTime?,
      autoUpdateDuration: autoUpdateDuration ?? this.autoUpdateDuration,
      subscriptionInfo: identical(subscriptionInfo, _unsetProfileField)
          ? this.subscriptionInfo
          : subscriptionInfo as SubscriptionInfo?,
      autoUpdate: autoUpdate ?? this.autoUpdate,
      selectedMap: selectedMap ?? this.selectedMap,
      unfoldSet: unfoldSet ?? this.unfoldSet,
      order: identical(order, _unsetProfileField) ? this.order : order as int?,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Profile &&
          other.id == id &&
          other.label == label &&
          other.currentGroupName == currentGroupName &&
          other.url == url &&
          other.ageSecretKey == ageSecretKey &&
          other.lastUpdateDate == lastUpdateDate &&
          other.autoUpdateDuration == autoUpdateDuration &&
          other.subscriptionInfo == subscriptionInfo &&
          other.autoUpdate == autoUpdate &&
          mapEquals(other.selectedMap, selectedMap) &&
          setEquals(other.unfoldSet, unfoldSet) &&
          other.order == order &&
          other.type == type;

  @override
  int get hashCode => Object.hash(
        id,
        label,
        currentGroupName,
        url,
        ageSecretKey,
        lastUpdateDate,
        autoUpdateDuration,
        subscriptionInfo,
        autoUpdate,
        Object.hashAll(selectedMap.entries),
        Object.hashAll(unfoldSet),
        order,
        type,
      );
}

extension ProfileExt on Profile {
  String get defaultLabel {
    if (url.isNotEmpty) {
      final name = url.urlFileName;
      if (name.isNotEmpty) return name;
    }
    return id.toString();
  }

  String get realLabel => label ?? defaultLabel;

  String get updatingKey => 'profile_$id';

  DashboardProfile toDashboardProfile({String? extensionLabel}) {
    return DashboardProfile(
      label: realLabel,
      type: switch (type) {
        ProfileType.url => DashboardProfileType.url,
        ProfileType.file => DashboardProfileType.file,
        ProfileType.custom => DashboardProfileType.custom,
      },
      subscriptionInfo: subscriptionInfo,
      lastUpdateDate: lastUpdateDate,
      extensionLabel: extensionLabel,
    );
  }
}

String? validateKitProfileName(BuildContext context, String? value) {
  if (value == null || value.isEmpty) {
    return KitLocalizations.of(context).profileNameNullValidationDesc;
  }
  return null;
}

Future<void> renameKitProfile(
  BuildContext context,
  Profile profile, {
  bool selectAll = false,
}) async {
  final l = KitLocalizations.of(context);
  final value = await showFloatingDialog<String>(
    context: context,
    child: InputDialog(
      title: l.rename,
      value: profile.label ?? '',
      selectAll: selectAll,
      labelText: l.name,
      inputFormatters: TextInputLimits.limit(TextInputLimits.name),
      validator: (text) => validateKitProfileName(context, text),
    ),
  );
  if (value == null || value == profile.label || !context.mounted) {
    return;
  }
  await ProfilesScope.read(context).putProfile(profile.copyWith(label: value));
}

typedef PhoneLinkSession = ({
  Uri address,
  Future<String?> link,
  Future<void> Function() close,
});

class ProfilesController extends ChangeNotifier {
  ProfilesController({
    List<Profile> profiles = const [],
    int? currentProfileId,
    bool isLoading = false,
    Set<String> updatingKeys = const {},
    Map<int, int> profileGroupsCounts = const {},
    ViewMode? viewModeOverride,
    bool? isDesktop,
    bool? isAndroid,
    this.isTV = false,
    this.onSelectProfile,
    this.onPutProfile,
    this.onReorderProfiles,
    this.onDeleteProfile,
    this.providerUsers,
    this.onUpdateProfile,
    this.onUpdateProfiles,
    this.onPreviewProfile,
    this.onExtendProfile,
    this.onEditCustomProfile,
    this.onEditProfile,
    this.onExportProfile,
    this.onAddFromFile,
    this.onScanQrCode,
    this.onAddFromLink,
    this.onAddFromLinks,
    this.onAddCustomProfile,
    this.startPhoneLinkReceiver,
  }) : _profiles = List<Profile>.unmodifiable(profiles),
       _currentProfileId = currentProfileId,
       _isLoading = isLoading,
       _updatingKeys = Set<String>.unmodifiable(updatingKeys),
       _profileGroupsCounts = Map<int, int>.unmodifiable(profileGroupsCounts),
       _viewModeOverride = viewModeOverride,
       isDesktop =
           isDesktop ??
           (defaultTargetPlatform == TargetPlatform.windows ||
               defaultTargetPlatform == TargetPlatform.linux ||
               defaultTargetPlatform == TargetPlatform.macOS),
       isAndroid =
           isAndroid ?? (defaultTargetPlatform == TargetPlatform.android);

  List<Profile> _profiles;
  int? _currentProfileId;
  bool _isLoading;
  Set<String> _updatingKeys;
  Map<int, int> _profileGroupsCounts;
  final ViewMode? _viewModeOverride;
  final bool isDesktop;
  final bool isAndroid;
  final bool isTV;

  final ValueChanged<int>? onSelectProfile;
  final FutureOr<void> Function(Profile profile)? onPutProfile;
  final FutureOr<void> Function(List<Profile> profiles)? onReorderProfiles;
  final FutureOr<void> Function(int id)? onDeleteProfile;
  final Future<List<Profile>> Function(Profile profile)? providerUsers;
  final Future<UpdatingMessage?> Function(Profile profile)? onUpdateProfile;
  final Future<List<UpdatingMessage>> Function()? onUpdateProfiles;
  final FutureOr<void> Function(BuildContext context, Profile profile)?
      onPreviewProfile;
  final FutureOr<void> Function(BuildContext context, Profile profile)?
      onExtendProfile;
  final FutureOr<void> Function(BuildContext context, Profile profile)?
      onEditCustomProfile;
  final FutureOr<void> Function(BuildContext context, Profile profile)?
      onEditProfile;
  final Future<bool> Function(Profile profile)? onExportProfile;
  final FutureOr<void> Function()? onAddFromFile;
  final FutureOr<String?> Function()? onScanQrCode;
  final FutureOr<void> Function(
    String url, {
    String? label,
    String ageSecretKey,
  })? onAddFromLink;
  final FutureOr<void> Function(List<String> urls)? onAddFromLinks;
  final FutureOr<void> Function(String name)? onAddCustomProfile;
  final Future<PhoneLinkSession?> Function()? startPhoneLinkReceiver;

  List<Profile> get profiles => _profiles;
  int? get currentProfileId => _currentProfileId;
  bool get isLoading => _isLoading;
  Set<String> get updatingKeys => _updatingKeys;
  Map<int, int> get profileGroupsCounts => _profileGroupsCounts;
  ViewMode? get viewModeOverride => _viewModeOverride;

  ViewMode viewModeOf(BuildContext context) =>
      _viewModeOverride ?? getViewMode(ViewScope.sizeOf(context).width);

  bool isUpdating(String key) => _updatingKeys.contains(key);

  int? groupsCountOf(int profileId) => _profileGroupsCounts[profileId];

  void setProfiles(List<Profile> next) {
    if (profileListEquality.equals(_profiles, next)) return;
    _profiles = List<Profile>.unmodifiable(next);
    notifyListeners();
  }

  void selectProfile(int id) {
    if (_currentProfileId == id) return;
    _currentProfileId = id;
    notifyListeners();
    onSelectProfile?.call(id);
  }

  void setLoading(bool loading) {
    if (_isLoading == loading) return;
    _isLoading = loading;
    notifyListeners();
  }

  void setUpdatingKeys(Set<String> keys) {
    if (setEquals(_updatingKeys, keys)) return;
    _updatingKeys = Set<String>.unmodifiable(keys);
    notifyListeners();
  }

  void setProfileGroupsCounts(Map<int, int> counts) {
    if (mapEquals(_profileGroupsCounts, counts)) return;
    _profileGroupsCounts = Map<int, int>.unmodifiable(counts);
    notifyListeners();
  }

  Future<void> putProfile(Profile profile) async {
    final next = [
      for (final item in _profiles)
        if (item.id == profile.id) profile else item,
      if (!_profiles.any((item) => item.id == profile.id)) profile,
    ];
    _profiles = List<Profile>.unmodifiable(next);
    notifyListeners();
    await onPutProfile?.call(profile);
  }

  Future<void> reorder(List<Profile> next) async {
    _profiles = List<Profile>.unmodifiable(next);
    notifyListeners();
    await onReorderProfiles?.call(_profiles);
  }

  Future<List<Profile>> checkProviderUsers(Profile profile) async {
    return await (providerUsers?.call(profile) ?? Future.value(const []));
  }

  Future<void> deleteProfile(int id) async {
    _profiles = List<Profile>.unmodifiable(
      _profiles.where((item) => item.id != id),
    );
    if (_currentProfileId == id) {
      _currentProfileId = _profiles.firstOrNull?.id;
    }
    notifyListeners();
    await onDeleteProfile?.call(id);
  }

  Future<List<UpdatingMessage>> updateAllProfiles() async {
    if (onUpdateProfiles != null) {
      return await onUpdateProfiles!();
    }
    final failures = <UpdatingMessage>[];
    final remoteProfiles = _profiles
        .where((p) => p.type == ProfileType.url)
        .toList();
    for (final profile in remoteProfiles) {
      final failure = await updateSingleProfile(profile);
      if (failure != null) failures.add(failure);
    }
    return failures;
  }

  Future<UpdatingMessage?> updateSingleProfile(Profile profile) async {
    final key = profile.updatingKey;
    if (_updatingKeys.contains(key)) return null;
    _updatingKeys = Set<String>.unmodifiable({..._updatingKeys, key});
    notifyListeners();
    try {
      if (onUpdateProfile != null) {
        return await onUpdateProfile!(profile);
      }
      await putProfile(profile.copyWith(lastUpdateDate: DateTime.now()));
      return null;
    } finally {
      _updatingKeys = Set<String>.unmodifiable(
        _updatingKeys.where((k) => k != key),
      );
      notifyListeners();
    }
  }

  Future<void> addProfileFromFile() async {
    await onAddFromFile?.call();
  }

  Future<String?> scanQrCode() async {
    return await onScanQrCode?.call();
  }

  Future<void> addProfileFromLink(
    String url, {
    String? label,
    String ageSecretKey = '',
  }) async {
    if (onAddFromLink != null) {
      await onAddFromLink!(url, label: label, ageSecretKey: ageSecretKey);
      return;
    }
    final profile = Profile.normal(label: label, url: url).copyWith(
      ageSecretKey: ageSecretKey.isEmpty ? null : ageSecretKey,
      lastUpdateDate: DateTime.now(),
    );
    await putProfile(profile);
    _currentProfileId ??= profile.id;
    notifyListeners();
  }

  Future<void> addProfilesFromLinks(List<String> urls) async {
    if (onAddFromLinks != null) {
      await onAddFromLinks!(urls);
      return;
    }
    for (final url in urls) {
      await addProfileFromLink(url);
    }
  }

  Future<void> addCustomProfile(String name) async {
    if (onAddCustomProfile != null) {
      await onAddCustomProfile!(name);
      return;
    }
    final profile = Profile.custom(label: name).copyWith(
      lastUpdateDate: DateTime.now(),
    );
    await putProfile(profile);
    _currentProfileId ??= profile.id;
    notifyListeners();
  }
}

class ProfilesScope extends InheritedNotifier<ProfilesController> {
  const ProfilesScope({
    super.key,
    required ProfilesController controller,
    required super.child,
  }) : super(notifier: controller);

  static ProfilesController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ProfilesScope>();
    if (scope == null || scope.notifier == null) {
      throw FlutterError('ProfilesScope not found above context.');
    }
    return scope.notifier!;
  }

  static ProfilesController read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<ProfilesScope>();
    if (scope == null || scope.notifier == null) {
      throw FlutterError('ProfilesScope not found above context.');
    }
    return scope.notifier!;
  }

  static ProfilesController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ProfilesScope>()?.notifier;
  }
}

extension ProfilesReorderExt on List<Profile> {
  Profile? getProfile(int id) => firstWhereOrNull((item) => item.id == id);

  List<Profile> reordered(int oldIndex, int newIndex) =>
      copyAndReorder(oldIndex, newIndex);
}
