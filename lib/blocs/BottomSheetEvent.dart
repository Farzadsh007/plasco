import 'package:plasco/custom_modules/bottom_sheets/content/ChooseCompany.dart';

abstract class BottomSheetEvent {}

class ChooseCompanyEvent extends BottomSheetEvent {
  get contentWidget => ChooseCompanyWidget();
}

class ExitGameEvent extends BottomSheetEvent {}

class SetDayEvent extends BottomSheetEvent {}
