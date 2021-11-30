import 'package:flutter/material.dart';
import 'package:now8/screens/common.dart';

class WelcomeScreenBody extends StatelessWidget {
  const WelcomeScreenBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(40.0),
        child: ListView(children: [
          Text("Welcome to now8!",
              style: Theme.of(context).textTheme.headline4!,
              textAlign: TextAlign.center),
          Container(
              margin: const EdgeInsets.only(top: 40),
              child: Text(
                "now8 is a public transport app that provides "
                "improved vehicle arrival time estimations "
                "using Machine Learning.",
                style: Theme.of(context).textTheme.headline6!,
              ))
        ]));
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ScreenTemplate(
      body: WelcomeScreenBody(),
      appBarTitle: "now8",
    );
  }
}
