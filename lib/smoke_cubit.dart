import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'repository/smoke_repository.dart';

class SmokeState extends Equatable {
  final bool? isSmoker;
  final int? cigarettesPerDay;
  final int? yearsSmoked;
  final bool? hasHealthIssues;
  final bool? wantsToQuit;
  final DateTime? quitDate;
  final bool? awarenessOfEffects;
  final String? comments;
  final bool formSubmitted;
  final bool isLoading;
  final List<String> smokingEffects;
  final String? error;

  const SmokeState({
    this.isSmoker,
    this.cigarettesPerDay,
    this.yearsSmoked,
    this.hasHealthIssues,
    this.wantsToQuit,
    this.quitDate,
    this.awarenessOfEffects,
    this.comments,
    this.formSubmitted = false,
    this.isLoading = false,
    this.smokingEffects = const [],
    this.error,
  });

  SmokeState copyWith({
    bool? isSmoker,
    int? cigarettesPerDay,
    int? yearsSmoked,
    bool? hasHealthIssues,
    bool? wantsToQuit,
    DateTime? quitDate,
    bool? awarenessOfEffects,
    String? comments,
    bool? formSubmitted,
    bool? isLoading,
    List<String>? smokingEffects,
    String? error,
  }) => SmokeState(
    isSmoker: isSmoker ?? this.isSmoker,
    cigarettesPerDay: cigarettesPerDay ?? this.cigarettesPerDay,
    yearsSmoked: yearsSmoked ?? this.yearsSmoked,
    hasHealthIssues: hasHealthIssues ?? this.hasHealthIssues,
    wantsToQuit: wantsToQuit ?? this.wantsToQuit,
    quitDate: quitDate ?? this.quitDate,
    awarenessOfEffects: awarenessOfEffects ?? this.awarenessOfEffects,
    comments: comments ?? this.comments,
    formSubmitted: formSubmitted ?? this.formSubmitted,
    isLoading: isLoading ?? this.isLoading,
    smokingEffects: smokingEffects ?? this.smokingEffects,
    error: error,
  );
  
  bool get isFormComplete {
    if (isSmoker == true) {
      if (cigarettesPerDay != null && cigarettesPerDay! > 0 &&
          yearsSmoked != null && yearsSmoked! > 0 &&
          hasHealthIssues != null) {
        
        if (hasHealthIssues == true) {
          if (wantsToQuit == true) return quitDate != null;
          if (wantsToQuit == false) return comments != null && comments!.isNotEmpty;
          return false;
        } else {
          if (awarenessOfEffects == true) return comments != null && comments!.isNotEmpty;
          if (awarenessOfEffects == false) return true;
          return false;
        }
      }
      return false;
    } else if (isSmoker == false) {
      if (awarenessOfEffects == true) return comments != null && comments!.isNotEmpty;
      if (awarenessOfEffects == false) return true;
    }
    return false;
  }
  
  bool get showCommentsInput {
    if (isSmoker == true) {
      if (hasHealthIssues == true) return wantsToQuit == false;
      if (hasHealthIssues == false) return awarenessOfEffects == true;
    }
    return isSmoker == false && awarenessOfEffects == true;
  }

  String get commentsHintText {
    if (isSmoker == true) {
      if (hasHealthIssues == true) {
        return 'Wyjaśnij dlaczego nie chcesz rzucić palenia pomimo problemów zdrowotnych...';
      } else {
        return 'Wyjaśnij dlaczego nadal palisz pomimo świadomości szkodliwości...';
      }
    }
    return 'Wpisz tutaj swoje uwagi...';
  }
  
  @override
  List<Object?> get props => [
    isSmoker, cigarettesPerDay, yearsSmoked, hasHealthIssues, 
    wantsToQuit, quitDate, awarenessOfEffects, comments, formSubmitted,
    isLoading, smokingEffects, error
  ];
}

class SmokeCubit extends Cubit<SmokeState> {
  final SmokeRepository _repository;

  SmokeCubit(this._repository) : super(const SmokeState()) {
    _loadSmokingEffects();
  }

  Future<void> _loadSmokingEffects() async {
    try {
      emit(state.copyWith(isLoading: true));
      final effects = await _repository.getSmokingEffects();
      emit(state.copyWith(smokingEffects: effects, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: 'Błąd ładowania: ${e.toString()}', isLoading: false));
    }
  }

  void setSmoker(bool value) => emit(state.copyWith(isSmoker: value));
  void setCigarettesPerDay(int value) => emit(state.copyWith(cigarettesPerDay: value));
  void setYearsSmoked(int value) => emit(state.copyWith(yearsSmoked: value));
  void setHasHealthIssues(bool value) => emit(state.copyWith(hasHealthIssues: value));
  void setWantsToQuit(bool value) => emit(state.copyWith(wantsToQuit: value));
  void setQuitDate(DateTime value) => emit(state.copyWith(quitDate: value));
  void setAwarenessOfEffects(bool value) => emit(state.copyWith(awarenessOfEffects: value));
  void setComments(String value) => emit(state.copyWith(comments: value));
  
  Future<void> submitForm() async {
    if (!state.isFormComplete) return;
    
    try {
      emit(state.copyWith(isLoading: true));
      
      final data = SmokeData(
        isSmoker: state.isSmoker,
        cigarettesPerDay: state.cigarettesPerDay,
        yearsSmoked: state.yearsSmoked,
        hasHealthIssues: state.hasHealthIssues,
        wantsToQuit: state.wantsToQuit,
        quitDate: state.quitDate,
        awarenessOfEffects: state.awarenessOfEffects,
        comments: state.comments,
      );
      
      await _repository.submitFormData(data);
      emit(state.copyWith(formSubmitted: true, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: 'Błąd wysyłania: ${e.toString()}', isLoading: false));
    }
  }
  
  void resetForm() {
    emit(const SmokeState());
    _loadSmokingEffects();
  }
}