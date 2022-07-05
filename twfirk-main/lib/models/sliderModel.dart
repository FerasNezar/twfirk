class SliderModel{
  String img;

  SliderModel.fromJson(Map<String,dynamic>parsedJson){
    this.img = parsedJson['url'];
  }
}