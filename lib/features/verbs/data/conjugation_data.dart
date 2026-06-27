/// Conjugations of the most useful Italian verbs.
///
/// [forms] is the present tense; [past] is the passato prossimo ("I ate, I
/// went…"), the everyday past used to talk about your day. Both are ordered
/// io, tu, lui/lei, noi, voi, loro. Forms with "/a" mean girls/feminine add -a.
class Verb {
  const Verb(this.infinitive, this.english, this.forms, this.past);
  final String infinitive;
  final String english; // e.g. 'to have'
  final List<String> forms; // present tense
  final List<String> past; // passato prossimo
}

abstract final class Conjugations {
  static const List<String> persons = <String>['io', 'tu', 'lui/lei', 'noi', 'voi', 'loro'];
  static const List<String> personsEn = <String>['I', 'you', 'he/she', 'we', 'you all', 'they'];

  static const List<Verb> verbs = <Verb>[
    Verb('essere', 'to be',
        <String>['sono', 'sei', 'è', 'siamo', 'siete', 'sono'],
        <String>['sono stato/a', 'sei stato/a', 'è stato/a', 'siamo stati/e', 'siete stati/e', 'sono stati/e']),
    Verb('avere', 'to have',
        <String>['ho', 'hai', 'ha', 'abbiamo', 'avete', 'hanno'],
        <String>['ho avuto', 'hai avuto', 'ha avuto', 'abbiamo avuto', 'avete avuto', 'hanno avuto']),
    Verb('volere', 'to want',
        <String>['voglio', 'vuoi', 'vuole', 'vogliamo', 'volete', 'vogliono'],
        <String>['ho voluto', 'hai voluto', 'ha voluto', 'abbiamo voluto', 'avete voluto', 'hanno voluto']),
    Verb('potere', 'can / to be able',
        <String>['posso', 'puoi', 'può', 'possiamo', 'potete', 'possono'],
        <String>['ho potuto', 'hai potuto', 'ha potuto', 'abbiamo potuto', 'avete potuto', 'hanno potuto']),
    Verb('dovere', 'must / to have to',
        <String>['devo', 'devi', 'deve', 'dobbiamo', 'dovete', 'devono'],
        <String>['ho dovuto', 'hai dovuto', 'ha dovuto', 'abbiamo dovuto', 'avete dovuto', 'hanno dovuto']),
    Verb('andare', 'to go',
        <String>['vado', 'vai', 'va', 'andiamo', 'andate', 'vanno'],
        <String>['sono andato/a', 'sei andato/a', 'è andato/a', 'siamo andati/e', 'siete andati/e', 'sono andati/e']),
    Verb('fare', 'to do / make',
        <String>['faccio', 'fai', 'fa', 'facciamo', 'fate', 'fanno'],
        <String>['ho fatto', 'hai fatto', 'ha fatto', 'abbiamo fatto', 'avete fatto', 'hanno fatto']),
    Verb('mangiare', 'to eat',
        <String>['mangio', 'mangi', 'mangia', 'mangiamo', 'mangiate', 'mangiano'],
        <String>['ho mangiato', 'hai mangiato', 'ha mangiato', 'abbiamo mangiato', 'avete mangiato', 'hanno mangiato']),
    Verb('bere', 'to drink',
        <String>['bevo', 'bevi', 'beve', 'beviamo', 'bevete', 'bevono'],
        <String>['ho bevuto', 'hai bevuto', 'ha bevuto', 'abbiamo bevuto', 'avete bevuto', 'hanno bevuto']),
    Verb('vedere', 'to see',
        <String>['vedo', 'vedi', 'vede', 'vediamo', 'vedete', 'vedono'],
        <String>['ho visto', 'hai visto', 'ha visto', 'abbiamo visto', 'avete visto', 'hanno visto']),
    Verb('dire', 'to say',
        <String>['dico', 'dici', 'dice', 'diciamo', 'dite', 'dicono'],
        <String>['ho detto', 'hai detto', 'ha detto', 'abbiamo detto', 'avete detto', 'hanno detto']),
    Verb('parlare', 'to speak',
        <String>['parlo', 'parli', 'parla', 'parliamo', 'parlate', 'parlano'],
        <String>['ho parlato', 'hai parlato', 'ha parlato', 'abbiamo parlato', 'avete parlato', 'hanno parlato']),
  ];

  /// Every present-tense form, for building quiz distractors.
  static List<String> get allForms =>
      <String>[for (final Verb v in verbs) ...v.forms];
}
