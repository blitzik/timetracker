import 'dart:collection';

abstract class ArchiveScreenState {}


class ArchiveUninitialized extends ArchiveScreenState {}


class ArchiveScreenLoadInProgress extends ArchiveScreenState {}


class ArchiveScreenLoadSuccessful extends ArchiveScreenState {
  final UnmodifiableListView<DateTime> days;
  final bool hasReachedMax;

  ArchiveScreenLoadSuccessful(this.days, this.hasReachedMax);

  ArchiveScreenLoadSuccessful copyWith({
    UnmodifiableListView<DateTime> days,
    bool hasReachedMax
  }) {
    return ArchiveScreenLoadSuccessful(
      days ?? this.days,
      hasReachedMax ?? this.hasReachedMax
    );
  }
}


class ArchiveScreenLoadFailure extends ArchiveScreenState {
  final String errorMessage;

  ArchiveScreenLoadFailure(this.errorMessage);
}