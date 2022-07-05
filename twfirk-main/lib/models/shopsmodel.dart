class ShopsModel{
  int _id;
  String _img;
  String _title;

  ShopsModel(this._id, this._img, this._title);

  String get title => _title;

  set title(String value) {
    _title = value;
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