import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:rxdart/rxdart.dart';

/// Keep track of wether player buttons are already visible, even with global
/// play buttons.
class IsPlayerButtonsShowingBloc extends BlocBase {
  /// True when global buttons are showing.
  Stream<bool> get globalButtonsShowingStream => Rx.combineLatest2<bool, bool, bool>(
      _isOtherButtonsShowing,
      _canGlobalShow,
      (isOtherShowing, canGlobalShow) => !isOtherShowing && canGlobalShow);
      
  BehaviorSubject<bool> _isOtherButtonsShowing = BehaviorSubject.seeded(false);
  BehaviorSubject<bool> _canGlobalShow = BehaviorSubject.seeded(true);

  void isOtherButtonsShowing({bool? isShowing}) {
    if (isShowing != _isOtherButtonsShowing.value) {
      _isOtherButtonsShowing.add(isShowing!);
    }
  }

  void canGlobalButtonsShow(bool isPossible) {
    if (isPossible != _canGlobalShow.value) {
      _canGlobalShow.add(isPossible);
    }
  }

  @override
  void dispose() {
    _isOtherButtonsShowing.close();
    _canGlobalShow.close();
    super.dispose();
  }
}
