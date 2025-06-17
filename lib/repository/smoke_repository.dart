import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SmokeData {
  final bool? isSmoker;
  final int? cigarettesPerDay;
  final int? yearsSmoked;
  final bool? hasHealthIssues;
  final bool? wantsToQuit;
  final DateTime? quitDate;
  final bool? awarenessOfEffects;
  final String? comments;

  const SmokeData({
    this.isSmoker,
    this.cigarettesPerDay,
    this.yearsSmoked,
    this.hasHealthIssues,
    this.wantsToQuit,
    this.quitDate,
    this.awarenessOfEffects,
    this.comments,
  });
}

class SmokeRepository {
  Future<bool> submitFormData(SmokeData data) async {
    await Future.delayed(const Duration(seconds: 1));
    
    return true;
  }
  
  Future<List<String>> getSmokingEffects(AppLocalizations l10n) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return [
      l10n.effectLungCancer,
      l10n.effectCardiovascular,
      l10n.effectCOPD,
      l10n.effectPhysicalCondition,
      l10n.effectSkinAging,
      l10n.effectFertility,
    ];
  }
}