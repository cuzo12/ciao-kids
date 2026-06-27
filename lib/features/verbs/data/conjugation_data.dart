/// Present-tense conjugations of the most useful Italian verbs — the engine of
/// real sentences ("I want…", "I have…", "can I…?"). Forms are ordered
/// io, tu, lui/lei, noi, voi, loro.
class Verb {
  const Verb(this.infinitive, this.english, this.forms);
  final String infinitive;
  final String english; // e.g. 'to have'
  final List<String> forms; // 6 present-tense forms
}

abstract final class Conjugations {
  static const List<String> persons = <String>['io', 'tu', 'lui/lei', 'noi', 'voi', 'loro'];
  static const List<String> personsEn = <String>['I', 'you', 'he/she', 'we', 'you all', 'they'];

  static const List<Verb> verbs = <Verb>[
    Verb('essere', 'to be', <String>['sono', 'sei', 'è', 'siamo', 'siete', 'sono']),
    Verb('avere', 'to have', <String>['ho', 'hai', 'ha', 'abbiamo', 'avete', 'hanno']),
    Verb('volere', 'to want', <String>['voglio', 'vuoi', 'vuole', 'vogliamo', 'volete', 'vogliono']),
    Verb('potere', 'can / to be able', <String>['posso', 'puoi', 'può', 'possiamo', 'potete', 'possono']),
    Verb('dovere', 'must / to have to', <String>['devo', 'devi', 'deve', 'dobbiamo', 'dovete', 'devono']),
    Verb('andare', 'to go', <String>['vado', 'vai', 'va', 'andiamo', 'andate', 'vanno']),
    Verb('fare', 'to do / make', <String>['faccio', 'fai', 'fa', 'facciamo', 'fate', 'fanno']),
    Verb('mangiare', 'to eat', <String>['mangio', 'mangi', 'mangia', 'mangiamo', 'mangiate', 'mangiano']),
    Verb('bere', 'to drink', <String>['bevo', 'bevi', 'beve', 'beviamo', 'bevete', 'bevono']),
    Verb('venire', 'to come', <String>['vengo', 'vieni', 'viene', 'veniamo', 'venite', 'vengono']),
    Verb('dire', 'to say', <String>['dico', 'dici', 'dice', 'diciamo', 'dite', 'dicono']),
    Verb('parlare', 'to speak', <String>['parlo', 'parli', 'parla', 'parliamo', 'parlate', 'parlano']),
  ];

  /// Every conjugated form, for building quiz distractors.
  static List<String> get allForms =>
      <String>[for (final Verb v in verbs) ...v.forms];
}
