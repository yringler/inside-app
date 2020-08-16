import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:rxdart/rxdart.dart';

/// Keep track of wether player buttons are already visible, even with global
/// play buttons.
class IsPlayerButtonsShowingBloc extends BlocBase {
  /// True when other media buttons are showing besides for global buttons.
  Stream<bool> get buttonsShowingStream => Rx.combineLatest2<bool, bool, bool>(
      _isPlayerButtonsShowing,
      _isPossibleButtonShowing,
      (isShowing, canShow) => isShowing && canShow);
      
  BehaviorSubject<bool> _isPlayerButtonsShowing = BehaviorSubject.seeded(false);
  BehaviorSubject<bool> _isPossibleButtonShowing = BehaviorSubject.seeded(true);

  void isPlayerButtonsShowing({bool isShowing}) {
    if (isShowing != _isPlayerButtonsShowing.value) {
      _isPlayerButtonsShowing.add(isShowing);
    }
  }

  void isPossiblePlayerButtonsShowing({bool isPossible}) {
    if (isPossible != _isPossibleButtonShowing.value) {
      _isPossibleButtonShowing.add(isPossible);
    }
  }

  @override
  void dispose() {
    _isPlayerButtonsShowing.close();
    _isPossibleButtonShowing.close();
    super.dispose();
  }
}
