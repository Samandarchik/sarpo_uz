class Salary {
  final int? advance;
  final String? advanceDescription;
  final int? amount;
  final int? bonus;
  final String? bonusDescription;
  final int? fine;
  final String? fineDescription;

  Salary({
    this.advance,
    this.advanceDescription,
    this.amount,
    this.bonus,
    this.bonusDescription,
    this.fine,
    this.fineDescription,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (advance != null) data['advance'] = advance;
    if (advanceDescription != null) data['advance_description'] = advanceDescription;
    if (amount != null) data['amount'] = amount;
    if (bonus != null) data['bonus'] = bonus;
    if (bonusDescription != null) data['bonus_description'] = bonusDescription;
    if (fine != null) data['fine'] = fine;
    if (fineDescription != null) data['fine_description'] = fineDescription;
    
    return data;
  }
}
