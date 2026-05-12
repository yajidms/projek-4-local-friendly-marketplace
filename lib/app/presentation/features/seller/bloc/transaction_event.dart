// File: lib/app/presentation/features/seller/bloc/transaction_event.dart

part of 'transaction_bloc.dart';

abstract class TransactionEvent {}

/// Muat semua transaksi milik penjual [sellerId].
class MuatTransaksiPenjual extends TransactionEvent {
  final String sellerId;
  MuatTransaksiPenjual({required this.sellerId});
}

/// Perbarui status pesanan [orderId].
class PerbaruiStatusTransaksi extends TransactionEvent {
  final String orderId;
  final String sellerId;
  final OrderStatus status;
  PerbaruiStatusTransaksi({
    required this.orderId,
    required this.sellerId,
    required this.status,
  });
}

/// Filter tampilan berdasarkan [status]. Null = tampil semua.
class FilterTransaksiBerdasarkanStatus extends TransactionEvent {
  final OrderStatus? status;
  FilterTransaksiBerdasarkanStatus({this.status});
}
