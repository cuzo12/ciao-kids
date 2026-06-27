/// Practical travel phrases grouped by real situations — the sentences a family
/// actually needs on a trip to Italy. Each phrase is ready to say out loud.
class Phrase {
  const Phrase(this.it, this.en);
  final String it;
  final String en;
}

class PhraseCategory {
  const PhraseCategory(this.title, this.emoji, this.phrases);
  final String title;
  final String emoji;
  final List<Phrase> phrases;
}

abstract final class Phrasebook {
  static const List<PhraseCategory> categories = <PhraseCategory>[
    PhraseCategory('Greetings & Politeness', '👋', <Phrase>[
      Phrase('Ciao!', 'Hi! / Bye!'),
      Phrase('Buongiorno', 'Good morning / Hello'),
      Phrase('Buonasera', 'Good evening'),
      Phrase('Per favore', 'Please'),
      Phrase('Grazie mille', 'Thank you very much'),
      Phrase('Prego', "You're welcome"),
      Phrase('Mi scusi', 'Excuse me (polite)'),
      Phrase('Mi dispiace', "I'm sorry"),
      Phrase('Come sta?', 'How are you? (polite)'),
      Phrase('Piacere!', 'Nice to meet you!'),
      Phrase('Non parlo bene italiano', "I don't speak Italian well"),
      Phrase('Parla inglese?', 'Do you speak English?'),
    ]),
    PhraseCategory('At the Restaurant', '🍽️', <Phrase>[
      Phrase('Un tavolo per quattro, per favore', 'A table for four, please'),
      Phrase('Il menù, per favore', 'The menu, please'),
      Phrase('Vorrei una pizza', 'I would like a pizza'),
      Phrase('Per me un gelato', 'For me, an ice cream'),
      Phrase('Cosa mi consiglia?', 'What do you recommend?'),
      Phrase('Acqua naturale, per favore', 'Still water, please'),
      Phrase('È buonissimo!', "It's delicious!"),
      Phrase('Sono allergico alle noci', "I'm allergic to nuts"),
      Phrase('Il conto, per favore', 'The bill, please'),
      Phrase('Posso pagare con la carta?', 'Can I pay by card?'),
    ]),
    PhraseCategory('Shopping & Money', '🛍️', <Phrase>[
      Phrase('Quanto costa?', 'How much is it?'),
      Phrase('È troppo caro', "It's too expensive"),
      Phrase('Vorrei questo, per favore', 'I would like this one, please'),
      Phrase('Avete una taglia più grande?', 'Do you have a bigger size?'),
      Phrase('Sto solo guardando', "I'm just looking"),
      Phrase('Posso provarlo?', 'Can I try it on?'),
      Phrase('Dove posso pagare?', 'Where can I pay?'),
      Phrase('Un sacchetto, per favore', 'A bag, please'),
    ]),
    PhraseCategory('Directions & Getting Around', '🧭', <Phrase>[
      Phrase("Dov'è il bagno?", 'Where is the bathroom?'),
      Phrase('Dov’è la stazione?', 'Where is the station?'),
      Phrase('Come arrivo al museo?', 'How do I get to the museum?'),
      Phrase('È lontano?', 'Is it far?'),
      Phrase('A destra', 'To the right'),
      Phrase('A sinistra', 'To the left'),
      Phrase('Sempre dritto', 'Straight ahead'),
      Phrase('Un biglietto, per favore', 'One ticket, please'),
      Phrase('A che ora parte il treno?', 'What time does the train leave?'),
      Phrase('Mi sono perso', "I'm lost"),
    ]),
    PhraseCategory('At the Hotel', '🏨', <Phrase>[
      Phrase('Ho una prenotazione', 'I have a reservation'),
      Phrase('Una camera per due notti', 'A room for two nights'),
      Phrase("C'è il wifi?", 'Is there wifi?'),
      Phrase('A che ora è la colazione?', 'What time is breakfast?'),
      Phrase('La chiave, per favore', 'The key, please'),
      Phrase("L'aria condizionata non funziona", 'The air conditioning is not working'),
    ]),
    PhraseCategory('Help & Emergencies', '🆘', <Phrase>[
      Phrase('Aiuto!', 'Help!'),
      Phrase('Mi può aiutare?', 'Can you help me?'),
      Phrase('Chiami un dottore!', 'Call a doctor!'),
      Phrase("Dov'è l'ospedale?", 'Where is the hospital?'),
      Phrase('Ho bisogno di aiuto', 'I need help'),
      Phrase('Non mi sento bene', "I don't feel well"),
      Phrase('Ho perso il mio telefono', 'I lost my phone'),
    ]),
    PhraseCategory('Making Friends', '😊', <Phrase>[
      Phrase('Come ti chiami?', "What's your name?"),
      Phrase('Mi chiamo…', 'My name is…'),
      Phrase('Quanti anni hai?', 'How old are you?'),
      Phrase('Ho dieci anni', "I'm ten years old"),
      Phrase('Di dove sei?', 'Where are you from?'),
      Phrase('Vengo dall’America', "I'm from America"),
      Phrase('Ti piace il calcio?', 'Do you like soccer?'),
      Phrase('Che bello!', 'How nice! / Cool!'),
      Phrase('A dopo!', 'See you later!'),
    ]),
    PhraseCategory('At the Airport', '✈️', <Phrase>[
      Phrase('Ecco il mio passaporto', 'Here is my passport'),
      Phrase("Dov'è l'imbarco?", 'Where is the gate?'),
      Phrase('A che ora è il volo?', 'What time is the flight?'),
      Phrase('Il volo è in ritardo', 'The flight is delayed'),
      Phrase('Dove ritiro i bagagli?', 'Where do I get the luggage?'),
      Phrase('Ho perso la valigia', 'I lost my suitcase'),
      Phrase("Dov'è il taxi?", 'Where is the taxi?'),
    ]),
    PhraseCategory('At the Beach', '🏖️', <Phrase>[
      Phrase('Andiamo in spiaggia!', "Let's go to the beach!"),
      Phrase('Voglio fare il bagno', 'I want to go swimming'),
      Phrase("L'acqua è fredda", 'The water is cold'),
      Phrase('Che bella giornata!', 'What a beautiful day!'),
      Phrase('Mi metto la crema solare', "I'm putting on sunscreen"),
      Phrase('Posso avere un gelato?', 'Can I have an ice cream?'),
      Phrase('Attento alle onde!', 'Watch out for the waves!'),
    ]),
    PhraseCategory('Numbers & Time', '🕒', <Phrase>[
      Phrase('Che ora è?', 'What time is it?'),
      Phrase("È l'una", "It's one o'clock"),
      Phrase('Sono le tre', "It's three o'clock"),
      Phrase('È mezzogiorno', "It's noon"),
      Phrase('È mezzanotte', "It's midnight"),
      Phrase('Quanto costa?', 'How much is it?'),
      Phrase('Cinque euro', 'Five euros'),
      Phrase('A che ora apre?', 'What time does it open?'),
      Phrase('Un momento, per favore', 'One moment, please'),
    ]),
    PhraseCategory('Talk About Your Day', '🌙', <Phrase>[
      Phrase('Oggi sono andato in città', 'Today I went to the city'),
      Phrase('Ho mangiato la pasta', 'I ate pasta'),
      Phrase('Ho visto cose bellissime', 'I saw beautiful things'),
      Phrase('È stato divertente!', 'It was fun!'),
      Phrase('Mi è piaciuto molto', 'I liked it a lot'),
      Phrase('Sono un po’ stanco', "I'm a little tired"),
      Phrase('Domani voglio andare al mare', 'Tomorrow I want to go to the sea'),
      Phrase('Buonanotte!', 'Good night!'),
    ]),
  ];
}
