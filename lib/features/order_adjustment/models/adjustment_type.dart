enum AdjustmentType {
  quantityChange('quantity_change', 'Quantity Change'),
  replace('replace', 'Ganti Menu'),
  cancel('cancel', 'Batalkan Item');

  final String value;
  final String label;

  const AdjustmentType(this.value, this.label);

  static AdjustmentType fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'quantity_change':
        return AdjustmentType.quantityChange;
      case 'replace':
        return AdjustmentType.replace;
      case 'cancel':
        return AdjustmentType.cancel;
      default:
        return AdjustmentType.quantityChange;
    }
  }
}

