// File: lib/app/presentation/features/seller/bloc/transaction_state.dart

part of 'transaction_bloc.dart';

abstract class TransactionState {}

class TransaksiAwal extends TransactionState {}

class TransaksiMemuat extends TransactionState {}

class TransaksiTertampil extends TransactionState {
  final List<Order> semuaTransaksi;
  final OrderStatus? filterStatus;

  TransaksiTertampil({
    required this.semuaTransaksi,
    this.filterStatus,
  });

  /// Transaksi yang ditampilkan setelah filter diterapkan.
  List<Order> get transaksiFiltrat => filterStatus == null
      ? semuaTransaksi
      : semuaTransaksi.where((o) => o.status == filterStatus).toList();

  int get jumlahMenunggu =>
      semuaTransaksi.where((o) => o.status == OrderStatus.pending).length;

  double get totalPendapatan => semuaTransaksi
      .where((o) => o.status == OrderStatus.delivered)
      .fold(0, (sum, o) => sum + o.total);
}

class TransaksiGagal extends TransactionState {
  final String pesan;
  TransaksiGagal(this.pesan);
}
