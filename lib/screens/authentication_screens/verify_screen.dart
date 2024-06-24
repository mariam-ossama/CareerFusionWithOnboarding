


/*import 'package:career_fusion/screens/account_screen.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:pinput/pin_put/pin_put.dart';
//import 'package:pinput/pinput.dart';

class VerifyPage extends StatelessWidget {
   const VerifyPage({super.key});



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.white,
      appBar: AppBar(
        title: const Text('CareerFusion',
        style: TextStyle(color: Colors.black),),
        backgroundColor: const Color.fromARGB(217,217,217,217),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            const Spacer(flex: 1,),
            const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 1),
              child: Text('Almost there',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.normal,
                fontFamily: 'Montserrat-VariableFont_wght'
              ),),
            ),
              ),
            const SizedBox(height: 30,),
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 1),
                child: Text('Please enter the 6-digit code sent to your email ************@gmail.com for verification.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Montserrat-VariableFont_wght'
                ),),
              ),
            ),
            SizedBox(height: 40,),
            Form(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(241,241,241,241),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 50,
                  width: 50,
                  child: TextFormField(
                    onChanged: (value) {
                      if(value.length==1){
                        FocusScope.of(context).nextFocus();
                      }
                    },
                    onSaved: (pin1) {},
                    style: Theme.of(context).textTheme.headlineSmall,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(1),
                      FilteringTextInputFormatter.digitsOnly
                    ],
                  ),
                ),
                //////////////////
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(241,241,241,241),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 50,
                  width: 50,
                  child: TextFormField(
                    onChanged: (value) {
                      if(value.length==1){
                        FocusScope.of(context).nextFocus();
                      }
                    },
                    onSaved: (pin1) {},
                    style: Theme.of(context).textTheme.headlineSmall,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(1),
                      FilteringTextInputFormatter.digitsOnly
                    ],
                  ),
                ),
                ///////////////////////
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(241,241,241,241),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 50,
                  width: 50,
                  child: TextFormField(
                    onChanged: (value) {
                      if(value.length==1){
                        FocusScope.of(context).nextFocus();
                      }
                    },
                    onSaved: (pin1) {},
                    style: Theme.of(context).textTheme.headlineSmall,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(1),
                      FilteringTextInputFormatter.digitsOnly
                    ],
                  ),
                ),
                ////////////////////////////////
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(241,241,241,241),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 50,
                  width: 50,
                  child: TextFormField(
                    onChanged: (value) {
                      if(value.length==1){
                        FocusScope.of(context).nextFocus();
                      }
                    },
                    onSaved: (pin1) {},
                    style: Theme.of(context).textTheme.headlineSmall,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(1),
                      FilteringTextInputFormatter.digitsOnly
                    ],
                  ),
                ),
                ///////////////////////////////
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(241,241,241,241),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 50,
                  width: 50,
                  child: TextFormField(
                    onChanged: (value) {
                      if(value.length==1){
                        FocusScope.of(context).nextFocus();
                      }
                    },
                    onSaved: (pin1) {},
                    style: Theme.of(context).textTheme.headlineSmall,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(1),
                      FilteringTextInputFormatter.digitsOnly
                    ],
                  ),
                ),
                /////////////////////////
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(241,241,241,241),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 50,
                  width: 50,
                  child: TextFormField(
                    onChanged: (value) {
                      if(value.length==1){
                        FocusScope.of(context).nextFocus();
                      }
                    },
                    onSaved: (pin1) {},
                    style: Theme.of(context).textTheme.headlineSmall,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(1),
                      FilteringTextInputFormatter.digitsOnly
                    ],
                  ),
                ),
              ],),
            ),
            const SizedBox(height: 30,),
            CustomButton(text: 'VERIFY',onPressed: (){
                    Navigator.push(context,
                    MaterialPageRoute(builder: (context)=>  AccountPage()));
                  }),
                  const SizedBox(height: 30,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Didn’t receive any code?',
                              style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Montserrat-VariableFont_wght'
                              ),),
                              TextButton(onPressed: (){}, 
                              child: const Text('Resend Again',
                              style: TextStyle(
                                fontFamily: 'Montserrat-VariableFont_wght',
                                fontWeight: FontWeight.w500,
                                color:  Color.fromARGB(255, 108, 99, 255),
                              ),)),
                    ],
                  ),
                  const Text('Request new code in (00:30s)',
                  style: TextStyle(
                    fontFamily: 'Montserrat-VariableFont_wght',
                  ),),
                  const Spacer(flex: 5,),

                  Row(
                    children: [
                      const SizedBox(width: 30,),
                      InkWell(
                      onTap: () {
                        Navigator.pop(context,'VerifyPage');
                      },
                      child: Container(
                      width: 56,
                      height: 56,
                      decoration:const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                      ),
                      child: const Icon(
                      Icons.navigate_before,
                      color: Colors.white,
                      ),
                      ),
                      ),
                    ],
                  ),
                  const Spacer(flex: 1,),
          ],
        ),
      )
    );
  }
}*/
