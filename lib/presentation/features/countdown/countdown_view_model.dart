import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:launch_tracker_app/domain/entities/launch.dart';
import 'package:launch_tracker_app/domain/repositories/launch_repository.dart';
import 'package:launch_tracker_app/domain/services/share_service.dart';
import 'package:launch_tracker_app/presentation/common/view_model/view_model.dart';

@injectable
class CountdownViewModel extends ViewModel {
  CountdownViewModel(
    @factoryParam this.launchId,
    this._launchRepository,
    this._shareService,
  ) {
    _timeLeftBeforeLaunch.addListener(_updateTimeLeftValues);
    _initCounterStream();
    _checkFavorite();
    _loadLaunch();
  }

  final String launchId;
  final LaunchRepository _launchRepository;
  final ShareService _shareService;

  final ValueNotifier<Duration?> _timeLeftBeforeLaunch = ValueNotifier(null);
  final ValueNotifier<Launch?> launch = ValueNotifier(null);
  final ValueNotifier<int?> daysLeft = ValueNotifier(null);
  final ValueNotifier<int?> hoursLeft = ValueNotifier(null);
  final ValueNotifier<int?> minutesLeft = ValueNotifier(null);
  final ValueNotifier<int?> secondsLeft = ValueNotifier(null);
  final ValueNotifier<bool> isFavorite = ValueNotifier(false);

  void shareLaunch() {
    if (launch.value != null) {
      _shareService.shareLaunch(launch.value!);
    }
  }

  Future<void> refreshLaunch() async => _loadLaunch();

  void toggleFavorite() {
    isFavorite.value
        ? _launchRepository.removeFromFavorite(launchId)
        : _launchRepository.addToFavorite(launchId);
    isFavorite.value = !isFavorite.value;
  }

  Future<void> _loadLaunch() async {
    loadingState.value = LoadingState.loading;

    return _launchRepository.getLaunch(launchId).then(
          (value) => value.fold((l) {
            loadingState.value = LoadingState.error;
          }, (loadedLaunch) {
            launch.value = loadedLaunch;
            _updateTimeLeft();
            loadingState.value = LoadingState.success;

          }),
        );
  }

  Future<void> _checkFavorite() async => _launchRepository.favoritesStream.forEach((favorites) {
        isFavorite.value = favorites.contains(launchId);
        _updateTimeLeft();
        loadingState.value = LoadingState.success;
      });

  void _initCounterStream() {
    Stream.periodic(const Duration(seconds: 1))
        .listen((event) => _updateTimeLeft());
  }

  void _updateTimeLeft() {
    _timeLeftBeforeLaunch.value =
        launch.value?.launchDateTime.difference(DateTime.now());
  }

  void _updateTimeLeftValues() {
    final timeLeft = _timeLeftBeforeLaunch.value;
    if (timeLeft != null) {
      daysLeft.value = timeLeft.inDays;
      hoursLeft.value = timeLeft.inHours - (timeLeft.inDays * 24);
      minutesLeft.value = timeLeft.inMinutes - (timeLeft.inHours * 60);
      secondsLeft.value = timeLeft.inSeconds - (timeLeft.inMinutes * 60);
    }
  }

  @override
  void dispose() {
    _timeLeftBeforeLaunch.dispose();
    launch.dispose();
    daysLeft.dispose();
    hoursLeft.dispose();
    minutesLeft.dispose();
    secondsLeft.dispose();
    isFavorite.dispose();

    super.dispose();
  }
}
