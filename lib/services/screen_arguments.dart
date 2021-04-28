class ScreenArguments {
  final int userId;
  final int levelId;
  final int editStatus;
  final int billId;
  final bool isBillOnline;
  final Map contractInfo;
  final int contractId;
  final int receiptId;
  final int customerId;
  final int trailId;
  final String receiptNumber;
  final int docId;

  ScreenArguments(
      {this.contractId,
      this.receiptId,
      this.customerId,
      this.userId,
      this.levelId,
      this.editStatus,
      this.billId,
      this.isBillOnline,
      this.contractInfo,
      this.trailId,
        this.receiptNumber,
        this.docId,
      });
}
