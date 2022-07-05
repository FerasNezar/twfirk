class CouponsModel {
  int _id;
  String _img;
  int _discount;
  String _desc;
  String _code;
  String _link;

  CouponsModel(
      this._id, this._img, this._discount, this._desc, this._code, this._link);

  String get link => _link;

  set link(String value) {
    _link = value;
  }

  String get code => _code;

  set code(String value) {
    _code = value;
  }

  String get desc => _desc;

  set desc(String value) {
    _desc = value;
  }

  int get discount => _discount;

  set discount(int value) {
    _discount = value;
  }

  String get img => _img;

  set img(String value) {
    _img = value;
  }

  int get id => _id;

  set id(int value) {
    _id = value;
  }


}
