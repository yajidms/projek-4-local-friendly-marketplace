// File: lib/app/presentation/features/seller/bloc/transaction_bloc.dart
//
// BLoC untuk manajemen transaksi / pesanan masuk penjual.
// Menggunakan OrderRepository (abstract interface) dari domain layer.

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/entities/index.dart';
import '../../../../../domain/repositories/order_repository.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final OrderRepository orderRepository;

  TransactionBloc({required this.orderRepository}) : super(TransaksiAwal()) {
    on<MuatTransaksiPenjual>(_onMuat);
    on<PerbaruiStatusTransaksi>(_onPerbaruiStatus);
    on<FilterTransaksiBerdasarkanStatus>(_onFilter);
  }

  Future<void> _onMuat(
    MuatTransaksiPenjual event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransaksiMemuat());
    try {
      final orders = await orderRepository.getOrdersBySeller(event.sellerId);
      emit(TransaksiTertampil(
        semuaTransaksi: orders,
        filterStatus: null,
      ));
    } catch (e) {
      emit(TransaksiGagal('Gagal memuat transaksi: ${e.toString()}'));
    }
  }

  Future<void> _onPerbaruiStatus(
    PerbaruiStatusTransaksi event,
    Emitter<TransactionState> emit,
  ) async {
    final current = state;
    if (current is! TransaksiTertampil) return;
    try {
      await orderRepository.updateOrderStatus(event.orderId, event.status);
      // Reload list setelah update
      final orders =
          await orderRepository.getOrdersBySeller(event.sellerId);
      emit(TransaksiTertampil(
        semuaTransaksi: orders,
        filterStatus: current.filterStatus,
      ));
    } catch (e) {
      emit(TransaksiGagal('Gagal memperbarui status: ${e.toString()}'));
    }
  }

  Future<void> _onFilter(
    FilterTransaksiBerdasarkanStatus event,
    Emitter<TransactionState> emit,
  ) async {
    final current = state;
    if (current is! TransaksiTertampil) return;
    emit(TransaksiTertampil(
      semuaTransaksi: current.semuaTransaksi,
      filterStatus: event.status,
    ));
  }
}
