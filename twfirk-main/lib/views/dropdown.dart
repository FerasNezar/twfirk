import 'package:Akwad/models/langModel.dart';
import 'package:Akwad/utils/constants.dart' as Constants;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dropdown extends StatefulWidget {
  List<LangModel> langModels;
  Function(String) callBack;

  Dropdown(this.langModels, this.callBack);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AppState(langModels, callBack);
  }
}

class AppState extends State<Dropdown> {
  List<LangModel> langModels;
  LangModel dropdownValue;
  Function(String) callBack;

  AppState(this.langModels, this.callBack) {
    dropdownValue = langModels[0];
    for (var m in langModels) {
      if (m.isSelected) {
        dropdownValue = m;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        width: 280.0,
        decoration: BoxDecoration(
            borderRadius: BorderRadiusGeometry.lerp(
                BorderRadius.circular(32.0), BorderRadius.circular(32.0), 32.0),
            color: Colors.white),
        child: Padding(
            padding: EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 4.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<LangModel>(
                isExpanded: true,
                value: dropdownValue,
                icon: Icon(Icons.keyboard_arrow_down),
                iconSize: 24,
                elevation: 16,
                iconDisabledColor: Colors.black,
                iconEnabledColor: Colors.blue,
                style: TextStyle(
                  fontSize: 19.0,
                  color: Colors.black,
                  fontFamily: "Poppins",
                ),
                onChanged: changeLang,
                items: langModels
                    .map<DropdownMenuItem<LangModel>>((LangModel value) {
                  return DropdownMenuItem<LangModel>(
                    value: value,
                    child: Row(
                      children: <Widget>[
                        if (value.title == "English" || value.title == "Arabic")
                          Image(
                            width: 30.0,
                            height: 30.0,
                            image: AssetImage(value.img),
                          )
                        else
                          Image.network(
                            value.img,
                            width: 30.0,
                            height: 30.0,
                          ),
                        Container(
                          margin: EdgeInsets.fromLTRB(16.0, 0, 0, 0),
                        ),
                        if (langModels.isNotEmpty) Text(value.title)
                      ],
                    ),
                  );
                }).toList(),
              ),
            )));
  }

  changeLang(LangModel model) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (model.title == "English") {
      prefs.setString("lang", "en");
      Constants.Constants.appLang = "en";
      callBack("en");
    } else if (model.title == "Arabic") {
      prefs.setString("lang", "ar");
      Constants.Constants.appLang = "ar";
      callBack("ar");
    } else {
      prefs.setString("country", model.title);
      callBack("");
    }
    setState(() {
      dropdownValue = model;
    });
  }
}
