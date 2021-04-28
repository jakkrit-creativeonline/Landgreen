import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SquareInput extends StatelessWidget {
  const SquareInput(
      {Key key,
      this.hintText = '',
      this.labelText = '',
      this.errorText,
      this.textController,
      this.onChanged,
      this.icon,
      this.validate,
      this.focusNode,
      this.enable = true,
      this.inputType,
      this.autofocus = false,
        this.isObscure = false,
      this.onFieldSubmitted,
      this.onEditingComplete,
        this.maxLine =1,
      this.textInputAction})
      : super(key: key);

  final String hintText;
  final String labelText;
  final String errorText;
  final TextEditingController textController;
  final ValueChanged<String> onChanged;
  final Icon icon;
  final Function validate;
  final FocusNode focusNode;
  final bool enable;
  final TextInputType inputType;
  final Function onFieldSubmitted;
  final Function onEditingComplete;
  final TextInputAction textInputAction;
  final bool autofocus;
  final bool isObscure;
  final int maxLine;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.only(top: 8, right: 10, bottom: 8),
      child: TextFormField(
        onChanged: onChanged,
        focusNode: focusNode,
        obscureText: isObscure,
        enabled: enable,
        autofocus: autofocus,
        keyboardType: inputType,
        onFieldSubmitted: onFieldSubmitted,
        onEditingComplete: onEditingComplete,
        textInputAction: textInputAction,
        decoration: InputDecoration(
            enabledBorder: const OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey, width: 0.0),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey),
            ),
            labelStyle: new TextStyle(color: Colors.green,),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
            contentPadding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
            hintText: hintText,
            labelText: labelText,

        ),
        validator: validate,
        controller: textController,
        maxLines: maxLine,
        maxLengthEnforced: true,

      ),
    );
  }
}
