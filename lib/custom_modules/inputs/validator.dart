abstract class Validator {
  int minimumLength;

  Validator(this.minimumLength);

  bool hasError(String input);

  String getError();
}
class DropDownValidator   {
  DropDownValidator();

  bool hasError(String input) {
    return input==null || input.isEmpty;
  }

  String getError() {
    return 'یک مورد را انتخاب نمایید!';
  }
}

class NameValidator extends Validator {
  NameValidator(int minimumLength) : super(minimumLength);

  @override
  bool hasError(String input) {
    return input.length < minimumLength;
  }

  @override
  String getError() {
    return 'نام را وارد نمایید!';
  }
}
class FamilyValidator extends Validator {
  FamilyValidator(int minimumLength) : super(minimumLength);

  @override
  bool hasError(String input) {
    return input.length < minimumLength;
  }

  @override
  String getError() {
    return 'نام خانوادگی را وارد نمایید!';
  }
}
class MobileValidator extends Validator {
  MobileValidator(int minimumLength) : super(minimumLength);

  @override
  bool hasError(String input) {
    return input.length < minimumLength;
  }

  @override
  String getError() {
    return 'شماره تلفن همراه صحیح نیست!';
  }
}
class NationalCodeValidator extends Validator {
  NationalCodeValidator(int minimumLength) : super(minimumLength);

  @override
  bool hasError(String input) {
    if(input.length != minimumLength){
      return true;
    }else{
      if ( input== "0000000000" || input== "1111111111" ||input== "22222222222" ||input== "33333333333" ||
          input== "4444444444" ||input== "5555555555" ||input== "6666666666" ||input== "7777777777" ||
          input== "8888888888" ||input== "9999999999"  ){
        return true;
      }else {
        var c = int.parse(input.substring(9, 10));
        var s = 0;
        for (var i = 0; i < 9; i++)
          s += int.parse(input.substring(i, i + 1)) * (10 - i);
        s = s % 11;
        if ((s < 2 && c == s) || (s >= 2 && c == (11 - s))) {
          return false;
        } else {
          return true;
        }
      }
    }

  }

  @override
  String getError() {
    return 'کد ملی اشتباه است!';
  }
}

class LocationNameValidator extends Validator {
  LocationNameValidator(int minimumLength) : super(minimumLength);

  @override
  bool hasError(String input) {
    return input.length < minimumLength;
  }

  @override
  String getError() {
    return 'نام مکان را وارد نمایید!';
  }
}
class GroupNameValidator extends Validator {
  GroupNameValidator(int minimumLength) : super(minimumLength);

  @override
  bool hasError(String input) {
    return input.length < minimumLength;
  }

  @override
  String getError() {
    return 'نام گروه را وارد نمایید!';
  }
}
class LocationCategoryNameValidator extends Validator {
  LocationCategoryNameValidator(int minimumLength) : super(minimumLength);

  @override
  bool hasError(String input) {
    return input.length < minimumLength;
  }

  @override
  String getError() {
    return 'نام ناحیه را وارد نمایید!';
  }
}
class AnswerValidator extends Validator {
  AnswerValidator(int minimumLength) : super(minimumLength);

  @override
  bool hasError(String input) {
    return input.length < minimumLength;
  }

  @override
  String getError() {
    return 'پاسخ را وارد نمایید!';
  }
}
class ActionTitleValidator extends Validator {
  ActionTitleValidator(int minimumLength) : super(minimumLength);

  @override
  bool hasError(String input) {
    return input.length < minimumLength;
  }

  @override
  String getError() {
    return 'شرح اقدام را وارد نمایید!';
  }
}
class AnomalyTitleValidator extends Validator {
  AnomalyTitleValidator(int minimumLength) : super(minimumLength);

  @override
  bool hasError(String input) {
    return input.length < minimumLength;
  }

  @override
  String getError() {
    return 'شرح آنومالی را وارد نمایید!';
  }
}
class CompanyNameValidator extends Validator {
  CompanyNameValidator(int minimumLength) : super(minimumLength);

  @override
  bool hasError(String input) {
    return input.length < minimumLength;
  }

  @override
  String getError() {
    return 'نام کارگاه را وارد نمایید!';
  }
}
class CompanyProjectNameValidator extends Validator {
  CompanyProjectNameValidator(int minimumLength) : super(minimumLength);

  @override
  bool hasError(String input) {
    return input.length < minimumLength;
  }

  @override
  String getError() {
    return 'نام پروژه را وارد نمایید!';
  }
}
class PhoneValidator extends Validator {
  PhoneValidator(int minimumLength) : super(minimumLength);

  @override
  bool hasError(String input) {
    return input.length < minimumLength;
  }

  @override
  String getError() {
    return 'تلفن را وارد نمایید!';
  }
}
class OTPValidator extends Validator {
  OTPValidator(int minimumLength) : super(minimumLength);

  @override
  bool hasError(String input) {
    return input.length < minimumLength;
  }

  @override
  String getError() {
    return 'کد پیامک شده را وارد نمایید!';
  }
}