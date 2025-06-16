import 'dart:async';

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
  
  Future<List<String>> getSmokingEffects() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return const [
      'Zwiększone ryzyko raka płuc, gardła i jamy ustnej',
      'Choroby układu krążenia i zawały serca',
      'Przewlekła obturacyjna choroba płuc (POChP)',
      'Pogorszenie kondycji i wydolności fizycznej',
      'Przedwczesne starzenie się skóry',
      'Obniżona płodność i problemy z potencją',
    ];
  }
}