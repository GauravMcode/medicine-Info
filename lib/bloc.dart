import 'package:flutter_bloc/flutter_bloc.dart';

class SearchCubit extends Cubit<String?> {
  SearchCubit() : super(null);
  valueChanged(String value) {
    emit(value);
  }
}
