import 'dart:collection';

abstract class ArchiveScreenState {}


class ArchiveScreenLoadInProgress extends ArchiveScreenState {}


class ArchiveScreenLoadSuccessful extends ArchiveScreenState {
  final UnmodifiableListView<DateTime> days;

  ArchiveScreenLoadSuccessful(this.days);
}


class ArchiveScreenLoadFailure extends ArchiveScreenState {
  final String errorMessage;

  ArchiveScreenLoadFailure(this.errorMessage);
}