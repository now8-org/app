import 'package:flutter/material.dart';
import 'package:now8/screens/common.dart';

class WelcomeScreenBody extends StatelessWidget {
  const WelcomeScreenBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(40.0),
        child: ListView(children: [
          SelectableText("Welcome to now8!",
              style: Theme.of(context).textTheme.headline4,
              textAlign: TextAlign.center),
          Container(
              margin: const EdgeInsets.only(top: 40),
              child: SelectableText(
                "now8 (no wait) is a public transport app that provides "
                "improved vehicle arrival time estimations "
                "using Machine Learning.",
                style: Theme.of(context).textTheme.bodyText1,
              )),
          Card(
              margin: const EdgeInsets.only(top: 40.0),
              child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(
                          "Features",
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SelectableText(
                              "• Support for Madrid (Spain).\n"
                              "• Fuzzy search for stop names and codes.\n",
                              style: Theme.of(context).textTheme.bodyText1,
                            ))
                      ]))),
        ]));
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenTemplate(
      body: const WelcomeScreenBody(),
      appBarTitle: "now8",
    );
  }
}
