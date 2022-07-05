
class LangModel{
    int _id;
    String _img;
    String _title;

    bool _isSelected = false;


    LangModel(this._id, this._img, this._title, this._isSelected);

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

    bool get isSelected => _isSelected;

    set isSelected(bool value) {
        _isSelected = value;
    }


}