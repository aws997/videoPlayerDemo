import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPick {
  static ColorPick cp=new ColorPick();
Color pickerColor = Color(0xff443a49);
Color currentColor = Color(0xff443a49);
 Future<Color> showPick (context) async{
    // raise the [showDialog] widget
await showDialog(
  builder: (c){
return  AlertDialog(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    title: const Text('Choose Subtitle Color'),
    content: SingleChildScrollView(
      child: BlockPicker(
        pickerColor: pickerColor,
        onColorChanged: (cl){
currentColor=cl;
        },
      ),
      // Use Material color picker:
      //
      // child: MaterialPicker(
      //   pickerColor: pickerColor,
      //   onColorChanged: changeColor,
      //   showLabel: true, // only on portrait mode
      // ),
      //
      // Use Block color picker:
      //
      // child: BlockPicker(
      //   pickerColor: currentColor,
      //   onColorChanged: changeColor,
      // ),
      //
      // child: MultipleChoiceBlockPicker(
      //   pickerColors: currentColors,
      //   onColorsChanged: changeColors,
      // ),
    ),
    actions: <Widget>[
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
          )
        ),
        child: const Text('Select'),
        onPressed: () {
          // setState(() => currentColor = pickerColor);
          Navigator.of(context).pop();
        },
      ),
    ],
  );
  },
  context: context,
  
);
return currentColor;
  }
}