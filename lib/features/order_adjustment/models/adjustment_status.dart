enum AdjustmentStatus {
  pendingCustomer('pending_customer', 'Pending Customer'),
  approved('approved', 'Approved'),
  rejected('rejected', 'Rejected');

  final String value;
  final String label;

  const AdjustmentStatus(this.value, this.label);

  static AdjustmentStatus fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'pending_customer':
        return AdjustmentStatus.pendingCustomer;
      case 'approved':
        return AdjustmentStatus.approved;
      case 'rejected':
        return AdjustmentStatus.rejected;
      default:
        return AdjustmentStatus.pendingCustomer;
    }
  }
}

