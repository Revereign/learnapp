import 'package:flutter_bloc/flutter_bloc.dart';

enum ParentDashboardMenu {
  registerChild,
  viewProgress,
  editProfile,
  viewMaterials,
}

class ParentDashboardCubit extends Cubit<ParentDashboardMenu> {
  ParentDashboardCubit() : super(ParentDashboardMenu.registerChild);

  void selectMenu(ParentDashboardMenu menu) => emit(menu);
}
