import 'package:flutter/material.dart';

class UiHelper{
  static customtextfeild(TextEditingController controller,String text,IconData icondata,bool toHide){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25,vertical: 15),
      child: TextField(
        controller: controller,
        obscureText: toHide,
        decoration: InputDecoration(
          hintText: text,
          suffixIcon: Icon(icondata),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25))
        ),
      ),
    );
  }
  static custombutton(VoidCallback voidcallback,String text){
    return SizedBox(
      height: 50,
      width: 200,
      child: ElevatedButton(
        onPressed: (){
          voidcallback();
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          backgroundColor: const Color.fromARGB(255, 220, 92, 243),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.black,fontSize: 20),
        ),
      ),
    );
  }
  
  static customalertbox(BuildContext context,String text){
    return showDialog(
      context: context, 
      builder:(BuildContext context){
        return AlertDialog(
          alignment: Alignment.bottomCenter,
          title: Text(text),
        );
      }
    );
  }
}
